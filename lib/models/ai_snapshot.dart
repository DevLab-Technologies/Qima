import 'book.dart';
import 'book_account.dart';
import 'book_entry.dart';
import 'money.dart';
import 'money_settings.dart';

/// One holding as an AI app sees it: what it is and what it is worth in the
/// snapshot's currency. Quantities and lots stay in Qima.
class AiHolding {
  final String symbol;
  final String assetClass;
  final double value;
  final double cost;

  const AiHolding({required this.symbol, required this.assetClass, required this.value, required this.cost});

  Map<String, dynamic> toJson() => {'symbol': symbol, 'class': assetClass, 'value': value, 'cost': cost};

  factory AiHolding.fromJson(Map<String, dynamic> json) => AiHolding(
        symbol: json['symbol'] as String,
        assetClass: json['class'] as String? ?? '',
        value: (json['value'] as num).toDouble(),
        cost: (json['cost'] as num?)?.toDouble() ?? 0,
      );
}

/// The copy of the books that Qima's desktop app writes for AI apps when the
/// person turns on "Let AI apps read Qima", and that the `qima-mcp` helper
/// reads. Nothing else crosses: the helper never opens Qima's own files.
///
/// Built through [AiSnapshot.build], which leaves out what an AI app has no
/// need for and the person may not expect to share: the last digits of
/// account, IBAN and card numbers, account notes, a bank message's raw
/// merchant text, imported-file hashes, learned rules and message senders.
class AiSnapshot {
  /// Bumped when a field changes meaning; the helper refuses a newer one.
  static const int schema = 1;

  final DateTime writtenAt;
  final String baseCurrency;
  final FXRates rates;
  final List<BookAccount> accounts;
  final List<BookEntry> entries;
  final List<RecurringPayment> planned;
  final Map<String, int> budgets;
  final String? budgetCurrency;

  /// Holdings at the prices Qima last had, in [baseCurrency]; null when the
  /// prices were not loaded yet, so a reader can say so instead of showing 0.
  final double? holdingsValue;
  final List<AiHolding> holdings;

  const AiSnapshot({
    required this.writtenAt,
    required this.baseCurrency,
    required this.rates,
    required this.accounts,
    required this.entries,
    this.planned = const [],
    this.budgets = const {},
    this.budgetCurrency,
    this.holdingsValue,
    this.holdings = const [],
  });

  /// The snapshot of the person's books, with the private fields dropped.
  factory AiSnapshot.build({
    required DateTime now,
    required String baseCurrency,
    required FXRates rates,
    required Iterable<BookAccount> accounts,
    required Iterable<BookEntry> entries,
    required Iterable<RecurringPayment> planned,
    required MoneySettings settings,
    double? holdingsValue,
    List<AiHolding> holdings = const [],
  }) =>
      AiSnapshot(
        writtenAt: now,
        baseCurrency: baseCurrency,
        rates: rates,
        accounts: [for (final a in accounts) a.copyWith(note: '', statementRefs: const [])],
        entries: [for (final e in entries) _withoutRawMerchant(e)],
        planned: List.of(planned),
        budgets: Map.of(settings.budgets),
        budgetCurrency: settings.budgetCurrency,
        holdingsValue: holdingsValue,
        holdings: holdings,
      );

  static BookEntry _withoutRawMerchant(BookEntry e) => e.rawMerchant.isEmpty
      ? e
      : BookEntry(
          id: e.id,
          date: e.date,
          postedDate: e.postedDate,
          template: e.template,
          status: e.status,
          baseCurrency: e.baseCurrency,
          lines: e.lines,
          merchant: e.merchant,
          note: e.note,
          source: e.source,
        );

  Book get book => Book(accounts, entries);

  Map<String, dynamic> toJson() => {
        'schema': schema,
        'writtenAt': writtenAt.toUtc().toIso8601String(),
        'baseCurrency': baseCurrency,
        'rates': {
          'base': rates.base,
          'rates': rates.rates,
          'updatedAt': rates.updatedAt.toUtc().toIso8601String(),
        },
        'accounts': [for (final a in accounts) a.toJson()],
        'entries': [for (final e in entries) e.toJson()],
        'planned': [for (final p in planned) p.toJson()],
        'budgets': budgets,
        if (budgetCurrency != null) 'budgetCurrency': budgetCurrency,
        if (holdingsValue != null) 'holdingsValue': holdingsValue,
        'holdings': [for (final h in holdings) h.toJson()],
      };

  /// Reads a snapshot. Throws [FormatException] for one written by a newer
  /// Qima, so the helper can ask the person to update it.
  factory AiSnapshot.fromJson(Map<String, dynamic> json) {
    final version = json['schema'] as int? ?? 0;
    if (version > schema) {
      throw FormatException('This snapshot was written by a newer Qima (format $version); update the helper.');
    }
    final r = (json['rates'] as Map).cast<String, dynamic>();
    List<Map<String, dynamic>> list(String key) =>
        [for (final e in (json[key] as List? ?? const [])) (e as Map).cast<String, dynamic>()];
    return AiSnapshot(
      writtenAt: DateTime.parse(json['writtenAt'] as String),
      baseCurrency: json['baseCurrency'] as String,
      rates: FXRates(
        base: r['base'] as String,
        rates: (r['rates'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
        updatedAt: DateTime.parse(r['updatedAt'] as String),
      ),
      accounts: [for (final a in list('accounts')) BookAccount.fromJson(a)],
      entries: [for (final e in list('entries')) BookEntry.fromJson(e)],
      planned: [for (final p in list('planned')) RecurringPayment.fromJson(p)],
      budgets: (json['budgets'] as Map? ?? const {}).map((k, v) => MapEntry(k as String, v as int)),
      budgetCurrency: json['budgetCurrency'] as String?,
      holdingsValue: (json['holdingsValue'] as num?)?.toDouble(),
      holdings: [for (final h in list('holdings')) AiHolding.fromJson(h)],
    );
  }
}
