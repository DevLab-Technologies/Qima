import 'package:equatable/equatable.dart';

import 'holding.dart';
import 'holding_transaction.dart';
import 'money.dart';

/// Amounts in several currencies, kept apart until display: a position
/// bought in SAR and USD has its cost in both, and converting early would
/// freeze one day's exchange rate into the ledger.
class CurrencyAmounts extends Equatable {
  final Map<String, double> byCurrency;

  const CurrencyAmounts([this.byCurrency = const {}]);

  static const CurrencyAmounts zero = CurrencyAmounts();

  bool get isZero => byCurrency.values.every((v) => v.abs() < 1e-9);

  CurrencyAmounts plus(String currency, double amount) {
    if (amount == 0) return this;
    return CurrencyAmounts({...byCurrency, currency: (byCurrency[currency] ?? 0) + amount});
  }

  CurrencyAmounts add(CurrencyAmounts other) {
    var result = this;
    other.byCurrency.forEach((c, v) => result = result.plus(c, v));
    return result;
  }

  CurrencyAmounts scaled(double factor) => CurrencyAmounts({for (final e in byCurrency.entries) e.key: e.value * factor});

  /// The total in [currency] at today's rates — the same live-rate rule
  /// `HoldingValuation.aggregate` uses for cost.
  Money inCurrency(String currency, FXRates rates) {
    final toTarget = rates.rate(currency) ?? 1;
    var total = 0.0;
    byCurrency.forEach((c, v) => total += v / (rates.rate(c) ?? 1) * toTarget);
    return Money(total, currency);
  }

  @override
  List<Object?> get props => [byCurrency];
}

/// A position as it stood right after one transaction — one step of an
/// instrument's [InstrumentPosition.timeline].
class PositionState extends Equatable {
  final DateTime date;

  /// Total fine (or canonical) quantity held.
  final double fineOunces;

  /// Cost basis still open.
  final CurrencyAmounts basis;

  /// Gain or loss realised so far, by sells and fees.
  final CurrencyAmounts realised;

  const PositionState({required this.date, required this.fineOunces, required this.basis, required this.realised});

  @override
  List<Object?> get props => [date, fineOunces, basis, realised];
}

/// What a disposal did, for the transaction list and the sell preview.
class DisposalEffect extends Equatable {
  /// Cost basis that left the position, by currency.
  final CurrencyAmounts basisReleased;

  /// For a sell: net proceeds minus [basisReleased]. Zero for a transfer
  /// out, which realises nothing.
  final CurrencyAmounts realised;

  const DisposalEffect({required this.basisReleased, required this.realised});

  @override
  List<Object?> get props => [basisReleased, realised];
}

/// Everything derived for one instrument.
class InstrumentPosition extends Equatable {
  final String instrumentID;

  /// What's still held, as lots: each acquisition scaled down by every
  /// disposal after it. A lot keeps its own unit, karat, currency and unit
  /// cost, so everything built on lots — valuation, totals, zakat,
  /// allocation, widgets — works unchanged on a ledger.
  final List<HoldingLot> openLots;
  final CurrencyAmounts realised;

  /// One state per transaction, in ledger order.
  final List<PositionState> timeline;

  /// Keyed by transaction id, for sells and transfers out.
  final Map<String, DisposalEffect> disposals;

  /// Disposals that asked for more than was held at the time (only possible
  /// through a sync conflict — the editor refuses it). They're applied as
  /// "everything that was left".
  final Set<String> overdrawn;

  const InstrumentPosition({
    required this.instrumentID,
    required this.openLots,
    required this.realised,
    required this.timeline,
    required this.disposals,
    required this.overdrawn,
  });

  double get fineOunces => timeline.isEmpty ? 0 : timeline.last.fineOunces;

  /// The position as it stood at [instant] — the last state on or before
  /// it — or null before the first transaction.
  PositionState? stateAt(DateTime instant) {
    PositionState? current;
    for (final state in timeline) {
      if (state.date.isAfter(instant)) break;
      current = state;
    }
    return current;
  }

  /// Fine quantity held at [instant].
  double fineOuncesOn(DateTime instant) => stateAt(instant)?.fineOunces ?? 0;

  @override
  List<Object?> get props => [instrumentID, openLots, realised, timeline, disposals, overdrawn];
}

/// Derives positions from transactions using the weighted-average cost
/// method: a disposal of a fraction of what's held releases that same
/// fraction of the open cost basis, whatever was bought when. All maths is
/// on fine content, so karats mix correctly.
class Ledger extends Equatable {
  final Map<String, InstrumentPosition> positions;

  Ledger(this.positions);

  static final Ledger empty = Ledger(const {});

  /// A disposal within this much of everything held counts as everything
  /// (floating-point noise from unit conversions must never strand dust or
  /// flag a full sale as overdrawn).
  static const double _epsilon = 1e-9;

  /// Every open lot across instruments. Built once per ledger, so callers
  /// can compare it by identity to tell whether holdings changed.
  late final List<HoldingLot> openLots = List.unmodifiable([for (final p in positions.values) ...p.openLots]);

  Set<String> get overdrawn => {for (final p in positions.values) ...p.overdrawn};

  /// When the first transaction happened, or null for an empty ledger.
  DateTime? get firstDate {
    DateTime? first;
    for (final p in positions.values) {
      if (p.timeline.isEmpty) continue;
      final d = p.timeline.first.date;
      if (first == null || d.isBefore(first)) first = d;
    }
    return first;
  }

  InstrumentPosition? operator [](String instrumentID) => positions[instrumentID];

  /// The first disposal (in ledger order) that [next] overdraws and the
  /// current ledger didn't — i.e. the sale an edit would break — or null
  /// when the edit is safe. Already-overdrawn rows from a sync conflict
  /// don't block unrelated edits.
  static HoldingTransaction? conflict(Iterable<HoldingTransaction> current, Iterable<HoldingTransaction> next) {
    final before = derive(current).overdrawn;
    final after = derive(next).overdrawn.difference(before);
    if (after.isEmpty) return null;
    return ordered(next).firstWhere((t) => after.contains(t.id));
  }

  static Ledger derive(Iterable<HoldingTransaction> transactions) {
    final byInstrument = <String, List<HoldingTransaction>>{};
    for (final t in transactions) {
      (byInstrument[t.instrumentID] ??= []).add(t);
    }
    return Ledger({for (final e in byInstrument.entries) e.key: _derivePosition(e.key, e.value)});
  }

  /// Ledger order: by calendar day, then acquisitions before fees before
  /// disposals within a day (a same-day buy and sell is a round trip, not a
  /// short sale), then by time, then by id so every device agrees.
  ///
  /// The day comes first, not the instant: rows entered in the editor sit at
  /// midnight while lots from before the ledger carry the time they were
  /// saved, and a sell dated today must still see a buy saved this
  /// afternoon.
  static List<HoldingTransaction> ordered(Iterable<HoldingTransaction> transactions) {
    int rank(TransactionKind k) => k.adds ? 0 : (k == TransactionKind.fee ? 1 : 2);
    DateTime day(DateTime d) {
      final local = d.toLocal();
      return DateTime(local.year, local.month, local.day);
    }

    return transactions.toList()
      ..sort((a, b) {
        final byDay = day(a.date).compareTo(day(b.date));
        if (byDay != 0) return byDay;
        final byKind = rank(a.kind).compareTo(rank(b.kind));
        if (byKind != 0) return byKind;
        final byTime = a.date.compareTo(b.date);
        if (byTime != 0) return byTime;
        return a.id.compareTo(b.id);
      });
  }

  static InstrumentPosition _derivePosition(String instrumentID, List<HoldingTransaction> transactions) {
    // Each acquisition and the fraction of it still held.
    final pieces = <HoldingTransaction>[];
    final remaining = <double>[];
    var realised = CurrencyAmounts.zero;
    final timeline = <PositionState>[];
    final disposals = <String, DisposalEffect>{};
    final overdrawn = <String>{};

    double heldFine() {
      var total = 0.0;
      for (var i = 0; i < pieces.length; i++) {
        total += pieces[i].fineOunces * remaining[i];
      }
      return total;
    }

    CurrencyAmounts openBasis() {
      var basis = CurrencyAmounts.zero;
      for (var i = 0; i < pieces.length; i++) {
        basis = basis.plus(pieces[i].currency, pieces[i].totalCost * remaining[i]);
      }
      return basis;
    }

    for (final t in ordered(transactions)) {
      switch (t.kind) {
        case TransactionKind.buy:
        case TransactionKind.transferIn:
          if (t.quantity > 0) {
            pieces.add(t);
            remaining.add(1);
          }
        case TransactionKind.fee:
          realised = realised.plus(t.currency, -t.fee);
        case TransactionKind.sell:
        case TransactionKind.transferOut:
          final held = heldFine();
          var fraction = held <= _epsilon ? 0.0 : t.fineOunces / held;
          if (t.fineOunces > held * (1 + _epsilon) + _epsilon) {
            overdrawn.add(t.id);
            fraction = held <= _epsilon ? 0 : 1;
          }
          if (fraction > 1 - _epsilon) fraction = 1;
          final released = openBasis().scaled(fraction);
          for (var i = 0; i < remaining.length; i++) {
            remaining[i] *= 1 - fraction;
          }
          var gain = CurrencyAmounts.zero;
          if (t.kind == TransactionKind.sell) {
            gain = gain.plus(t.currency, t.netProceeds).add(released.scaled(-1));
          } else if (t.fee != 0) {
            // A transfer's own fee is a cost of moving it, realised as a loss.
            gain = gain.plus(t.currency, -t.fee);
          }
          realised = realised.add(gain);
          disposals[t.id] = DisposalEffect(basisReleased: released, realised: gain);
      }
      // Never earlier than the state before it: within a day, ledger order
      // can put a midnight sell after an afternoon buy, and the timeline
      // must stay sorted for stateAt and the history walk.
      final date = timeline.isNotEmpty && timeline.last.date.isAfter(t.date) ? timeline.last.date : t.date;
      timeline.add(PositionState(date: date, fineOunces: heldFine(), basis: openBasis(), realised: realised));
    }

    final openLots = <HoldingLot>[
      for (var i = 0; i < pieces.length; i++)
        if (remaining[i] > _epsilon)
          HoldingLot(
            id: pieces[i].id,
            instrumentID: instrumentID,
            quantity: pieces[i].quantity * remaining[i],
            unit: pieces[i].unit,
            // Unchanged by disposals: a proportional release takes cost and
            // quantity down together. Commission is part of the cost.
            // Exactly the entered price when there's no commission, so a
            // migrated lot reads back bit-for-bit.
            unitCost: pieces[i].fee == 0 || pieces[i].quantity == 0
                ? pieces[i].unitPrice
                : pieces[i].totalCost / pieces[i].quantity,
            costCurrency: pieces[i].currency,
            date: pieces[i].date,
            karat: pieces[i].karat,
          ),
    ];

    return InstrumentPosition(
      instrumentID: instrumentID,
      openLots: openLots,
      realised: realised,
      timeline: timeline,
      disposals: disposals,
      overdrawn: overdrawn,
    );
  }

  @override
  List<Object?> get props => [positions];
}
