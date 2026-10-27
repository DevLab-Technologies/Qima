import 'package:equatable/equatable.dart';

import 'asset.dart';
import 'asset_group.dart';
import 'hijri_date.dart';
import 'holding.dart';
import 'money.dart';

/// Which metal the nisab threshold is priced against. Both weights are
/// FINE metal (24K gold, pure silver) — the classical 20 mithqal and 200
/// dirham, as most contemporary bodies express them.
enum NisabBasis {
  gold(85, 'metal.XAU'),
  silver(595, 'metal.XAG');

  final double fineGrams;
  final String instrumentID;

  const NisabBasis(this.fineGrams, this.instrumentID);

  NisabBasis get other => this == NisabBasis.gold ? NisabBasis.silver : NisabBasis.gold;

  static NisabBasis fromName(String? name) =>
      NisabBasis.values.firstWhere((b) => b.name == name, orElse: () => ZakatSettings.defaultBasis);
}

/// Which calendar the hawl (the zakat year) is counted in. Hijri is the
/// default: the hawl is a lunar year, about 11 days shorter than a
/// Gregorian one.
enum HawlCalendar {
  hijri,
  gregorian;

  static HawlCalendar fromName(String? name) =>
      HawlCalendar.values.firstWhere((c) => c.name == name, orElse: () => HawlCalendar.hijri);
}

/// The user's zakat choices. Synced across devices like the base currency
/// (see `Preferences.zakatSettings`) and carried in backups.
///
/// Qima computes; it does not rule. Every default here is a common
/// contemporary position, and every one of them is the user's to change.
class ZakatSettings extends Equatable {
  static const NisabBasis defaultBasis = NisabBasis.gold;

  /// Metals, crypto and cash count by default. Equities are off: whether a
  /// long-term shareholding is zakatable on its full market value, on its
  /// zakatable assets only, or not at all differs between scholars.
  static const Set<AssetGroup> defaultClasses = {AssetGroup.metals, AssetGroup.crypto, AssetGroup.cash};

  final NisabBasis basis;
  final Set<AssetGroup> includedClasses;

  /// Per-asset exceptions to [includedClasses], keyed by instrument id:
  /// `true` forces an asset in, `false` leaves it out (e.g. gold jewelry
  /// worn every day, for those who follow the view that it is exempt).
  final Map<String, bool> holdingOverrides;

  final HawlCalendar calendar;

  /// The day the user's wealth first reached nisab — the start of their
  /// first hawl. Local calendar day; null until the user sets one.
  final DateTime? hawlStart;

  /// Whether to post a notification on the day a hawl completes.
  final bool remind;

  const ZakatSettings({
    this.basis = defaultBasis,
    this.includedClasses = defaultClasses,
    this.holdingOverrides = const {},
    this.calendar = HawlCalendar.hijri,
    this.hawlStart,
    this.remind = false,
  });

  bool includes(Instrument instrument) =>
      holdingOverrides[instrument.id] ?? includedClasses.contains(AssetGroup.of(instrument.assetClass));

  ZakatSettings copyWith({
    NisabBasis? basis,
    Set<AssetGroup>? includedClasses,
    Map<String, bool>? holdingOverrides,
    HawlCalendar? calendar,
    DateTime? hawlStart,
    bool clearHawlStart = false,
    bool? remind,
  }) {
    return ZakatSettings(
      basis: basis ?? this.basis,
      includedClasses: includedClasses ?? this.includedClasses,
      holdingOverrides: holdingOverrides ?? this.holdingOverrides,
      calendar: calendar ?? this.calendar,
      hawlStart: clearHawlStart ? null : (hawlStart ?? this.hawlStart),
      remind: remind ?? this.remind,
    );
  }

  /// Flips one asset in or out. An override that lands back on what the
  /// asset's class would give anyway is dropped, so the map only ever holds
  /// real exceptions and a later class toggle still applies to it.
  ZakatSettings toggleHolding(Instrument instrument) {
    final next = !includes(instrument);
    final classDefault = includedClasses.contains(AssetGroup.of(instrument.assetClass));
    final overrides = Map<String, bool>.of(holdingOverrides);
    if (next == classDefault) {
      overrides.remove(instrument.id);
    } else {
      overrides[instrument.id] = next;
    }
    return copyWith(holdingOverrides: overrides);
  }

  ZakatSettings toggleClass(AssetGroup assetGroup) {
    final classes = Set<AssetGroup>.of(includedClasses);
    if (!classes.remove(assetGroup)) classes.add(assetGroup);
    return copyWith(includedClasses: classes);
  }

  Map<String, dynamic> toJson() => {
        'basis': basis.name,
        'classes': [for (final c in AssetGroup.values) if (includedClasses.contains(c)) c.name],
        'overrides': holdingOverrides,
        'calendar': calendar.name,
        if (hawlStart != null) 'hawlStart': _dayString(hawlStart!),
        'remind': remind,
      };

  /// Tolerant by design: settings arrive from other devices and from
  /// backups, possibly written by a newer version. Anything unreadable falls
  /// back to its default instead of discarding the whole object.
  factory ZakatSettings.fromJson(Map<String, dynamic> json) {
    final rawClasses = json['classes'];
    final classes = rawClasses is List
        ? rawClasses.whereType<String>().map(AssetGroup.fromName).whereType<AssetGroup>().toSet()
        : defaultClasses;
    final rawOverrides = json['overrides'];
    final overrides = <String, bool>{};
    if (rawOverrides is Map) {
      rawOverrides.forEach((key, value) {
        if (key is String && value is bool) overrides[key] = value;
      });
    }
    final rawStart = json['hawlStart'];
    final parsedStart = rawStart is String ? DateTime.tryParse(rawStart) : null;
    return ZakatSettings(
      basis: NisabBasis.fromName(_string(json['basis'])),
      includedClasses: classes,
      holdingOverrides: overrides,
      calendar: HawlCalendar.fromName(_string(json['calendar'])),
      hawlStart: parsedStart == null ? null : DateTime(parsedStart.year, parsedStart.month, parsedStart.day),
      remind: json['remind'] == true,
    );
  }

  static String? _string(Object? value) => value is String ? value : null;

  /// Stored as a bare `yyyy-MM-dd` calendar day, never an instant: a hawl
  /// date picked in Riyadh must read as the same day on a device set to
  /// London.
  static String _dayString(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [basis, includedClasses, holdingOverrides, calendar, hawlStart, remind];
}

/// Where the user is in their zakat year, counted from
/// [ZakatSettings.hawlStart] in [ZakatSettings.calendar].
class HawlSchedule extends Equatable {
  /// The most recent anniversary on or before today (null during the first
  /// year, when no hawl has completed yet).
  final DateTime? lastCompleted;

  /// The next anniversary strictly after today, or today itself when a hawl
  /// completes today.
  final DateTime next;

  /// Whole days from today to [next] (0 when it completes today).
  final int daysUntilNext;

  const HawlSchedule({required this.lastCompleted, required this.next, required this.daysUntilNext});

  bool get completesToday => daysUntilNext == 0;

  /// Null when no hawl start is set, or the start can't be projected (a
  /// Hijri anniversary past the end of the Umm al-Qura table).
  static HawlSchedule? of(ZakatSettings settings, DateTime now) {
    final start = settings.hawlStart;
    if (start == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(start.year, start.month, start.day);
    // A start date in the future is just "the first hawl hasn't begun yet":
    // its first completion is still one year after it.
    DateTime? previous;
    for (var k = 1; k < 200; k++) {
      final anniversary = anniversaryOf(startDay, k, settings.calendar);
      if (anniversary == null) return null;
      if (!anniversary.isBefore(today)) {
        // Calendar-day difference, immune to DST hour shifts.
        final days = DateTime.utc(anniversary.year, anniversary.month, anniversary.day)
            .difference(DateTime.utc(today.year, today.month, today.day))
            .inDays;
        final lastCompleted = days == 0 ? anniversary : previous;
        return HawlSchedule(lastCompleted: lastCompleted, next: anniversary, daysUntilNext: days);
      }
      previous = anniversary;
    }
    return null;
  }

  /// The [years]-th anniversary of [start]. Hijri anniversaries go through
  /// the Umm al-Qura table; a start outside the table falls back to
  /// Gregorian rather than failing. Gregorian 29 February clamps to 28
  /// February in common years.
  static DateTime? anniversaryOf(DateTime start, int years, HawlCalendar calendar) {
    if (calendar == HawlCalendar.hijri) {
      final hijri = HijriDate.fromGregorian(start);
      if (hijri != null) return hijri.addYears(years)?.toGregorian();
    }
    final year = start.year + years;
    final lastDay = DateTime(year, start.month + 1, 0).day;
    return DateTime(year, start.month, start.day > lastDay ? lastDay : start.day);
  }

  @override
  List<Object?> get props => [lastCompleted, next, daysUntilNext];
}

/// Why an asset contributes nothing to the zakatable base.
enum ZakatExclusion {
  /// Its class is switched off in settings.
  classOff,

  /// The user left this asset out specifically.
  holdingOff,

  /// No live price yet, so it can't be valued. Counted as soon as one
  /// arrives.
  noPrice,
}

/// One held asset as the zakat screen lists it.
class ZakatLine extends Equatable {
  final Instrument instrument;
  final AssetGroup assetGroup;

  /// Market value in the base currency; null when there is no price yet.
  final Money? value;
  final ZakatExclusion? exclusion;

  /// The lots behind this line, for the "Gold · 142 g" quantity label.
  final List<HoldingLot> lots;

  const ZakatLine({
    required this.instrument,
    required this.assetGroup,
    required this.value,
    required this.exclusion,
    required this.lots,
  });

  bool get counts => exclusion == null;

  @override
  List<Object?> get props => [instrument, assetGroup, value, exclusion, lots];
}

enum NisabStatus {
  /// Nothing held at all.
  noHoldings,

  /// The nisab metal has no price yet, so the threshold is unknown.
  thresholdUnknown,
  below,
  above,
}

/// A point-in-time zakat calculation: what counts, the threshold today, and
/// what's due. Pure and synchronous; recomputed whenever prices or holdings
/// change.
///
/// Assessed on today's values only — the common practice of valuing wealth
/// on the day the hawl completes. Whether wealth dipped below nisab during
/// the year is not tracked.
class ZakatAssessment extends Equatable {
  static const double rate = 0.025;

  final List<ZakatLine> lines;
  final Money base;
  final Money? threshold;

  /// The threshold the other basis would give today, for the "Silver basis
  /// would be …" comparison line.
  final Money? otherThreshold;
  final Money due;
  final NisabStatus status;
  final NisabBasis basis;

  const ZakatAssessment({
    required this.lines,
    required this.base,
    required this.threshold,
    required this.otherThreshold,
    required this.due,
    required this.status,
    required this.basis,
  });

  /// True when an otherwise-counted asset has no price yet, so [base] (and
  /// possibly [status]) may be understated.
  bool get hasUnpricedHoldings => lines.any((l) => l.exclusion == ZakatExclusion.noPrice);

  static ZakatAssessment compute({
    required List<HoldingLot> lots,
    required ZakatSettings settings,
    required FXRates rates,
    required String baseCurrency,
    required double? Function(String instrumentID) latestUSD,
    required Instrument? Function(String instrumentID) resolve,
  }) {
    final byInstrument = <String, List<HoldingLot>>{};
    for (final lot in lots) {
      (byInstrument[lot.instrumentID] ??= []).add(lot);
    }

    final lines = <ZakatLine>[];
    double base = 0;
    for (final entry in byInstrument.entries) {
      final instrument = resolve(entry.key);
      if (instrument == null) continue;
      final valuation = HoldingValuation.aggregate(
        lots: entry.value,
        rates: rates,
        displayCurrency: baseCurrency,
        latestUSD: latestUSD,
      );
      final included = settings.includes(instrument);
      final ZakatExclusion? exclusion;
      if (!included) {
        exclusion = settings.holdingOverrides[instrument.id] == false ? ZakatExclusion.holdingOff : ZakatExclusion.classOff;
      } else if (valuation == null) {
        exclusion = ZakatExclusion.noPrice;
      } else {
        exclusion = null;
        base += valuation.value.amount;
      }
      lines.add(ZakatLine(
        instrument: instrument,
        assetGroup: AssetGroup.of(instrument.assetClass),
        value: valuation?.value,
        exclusion: exclusion,
        lots: entry.value,
      ));
    }

    // Counted assets first, largest first; then everything left out.
    lines.sort((a, b) {
      if (a.counts != b.counts) return a.counts ? -1 : 1;
      return (b.value?.amount ?? -1).compareTo(a.value?.amount ?? -1);
    });

    final threshold = thresholdFor(settings.basis, rates: rates, baseCurrency: baseCurrency, latestUSD: latestUSD);
    final otherThreshold =
        thresholdFor(settings.basis.other, rates: rates, baseCurrency: baseCurrency, latestUSD: latestUSD);

    final NisabStatus status;
    if (lines.isEmpty) {
      status = NisabStatus.noHoldings;
    } else if (threshold == null) {
      status = NisabStatus.thresholdUnknown;
    } else if (base >= threshold.amount && base > 0) {
      status = NisabStatus.above;
    } else {
      status = NisabStatus.below;
    }

    return ZakatAssessment(
      lines: lines,
      base: Money(base, baseCurrency),
      threshold: threshold,
      otherThreshold: otherThreshold,
      due: Money(status == NisabStatus.above ? base * rate : 0, baseCurrency),
      status: status,
      basis: settings.basis,
    );
  }

  /// Today's nisab for [basis] in [baseCurrency]: the fine weight times the
  /// metal's live per-gram price. Null when that metal has no price yet.
  static Money? thresholdFor(
    NisabBasis basis, {
    required FXRates rates,
    required String baseCurrency,
    required double? Function(String instrumentID) latestUSD,
  }) {
    final perOunceUSD = latestUSD(basis.instrumentID);
    if (perOunceUSD == null || perOunceUSD <= 0) return null;
    final perGramUSD = perOunceUSD * PriceUnit.gram.multiplier;
    final toBase = rates.rate(baseCurrency) ?? 1;
    return Money(basis.fineGrams * perGramUSD * toBase, baseCurrency);
  }

  @override
  List<Object?> get props => [lines, base, threshold, otherThreshold, due, status, basis];
}
