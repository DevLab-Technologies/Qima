import 'package:equatable/equatable.dart';

import 'asset.dart';

/// Where an instrument trades, for its opening hours.
enum Market {
  /// Crypto: never closes.
  always,

  /// NYSE and Nasdaq, 09:30 to 16:00 New York time, US holidays closed.
  us,
  london,
  xetra,
  tokyo,
  tadawul,
  egx,
  uae,
  qatar,
  kuwait,

  /// Metals futures: Sunday 18:00 to Friday 17:00 New York time, with an
  /// hour's break each day at 17:00.
  metals,

  /// Currencies: Sunday 17:00 to Friday 17:00 New York time.
  fx,
}

/// Whether a market is open at a moment, and when that changes.
class MarketStatus extends Equatable {
  final bool open;

  /// When it closes if [open], when it opens if not; null for a market
  /// that never closes.
  final DateTime? next;

  const MarketStatus({required this.open, this.next});

  @override
  List<Object?> get props => [open, next];
}

/// Opening hours from each exchange's published regular session. Gulf and
/// Egyptian public holidays follow the moon and are announced late, so on
/// those days a market can read open while it is shut; the price's own time
/// still shows when it last traded.
class MarketHours {
  const MarketHours._();

  /// The market [instrument] trades on; null when its symbol doesn't say.
  static Market? marketOf(Instrument instrument) {
    switch (instrument.assetClass) {
      case AssetClass.crypto:
        return Market.always;
      case AssetClass.metal:
        return Market.metals;
      case AssetClass.fiat:
        return Market.fx;
      case AssetClass.stock:
      case AssetClass.indices:
        final source = instrument.sourceSymbol.toUpperCase();
        const indices = {
          '^GSPC': Market.us, '^DJI': Market.us, '^IXIC': Market.us, '^RUT': Market.us, '^NDX': Market.us, //
          '^FTSE': Market.london, '^GDAXI': Market.xetra, '^N225': Market.tokyo,
          '^TASI.SR': Market.tadawul, '^CASE30': Market.egx,
        };
        if (indices[source] case final m?) return m;
        final dot = source.lastIndexOf('.');
        if (dot < 0) return source.startsWith('^') ? null : Market.us;
        return switch (source.substring(dot + 1)) {
          'SR' => Market.tadawul,
          'CA' => Market.egx,
          'AE' || 'AD' || 'DU' => Market.uae,
          'QA' => Market.qatar,
          'KW' => Market.kuwait,
          'L' => Market.london,
          'DE' || 'F' => Market.xetra,
          'T' => Market.tokyo,
          _ => null,
        };
    }
  }

  /// Whether [instrument]'s market is open at [now]; null when its market is
  /// unknown.
  static MarketStatus? statusOf(Instrument instrument, DateTime now) {
    final market = marketOf(instrument);
    return market == null ? null : status(market, now);
  }

  static MarketStatus status(Market market, DateTime now) {
    if (market == Market.always) return const MarketStatus(open: true);
    final at = now.toUtc();
    final local = at.add(_offset(market, at));
    // Sessions from yesterday to two weeks ahead, joined where one runs into
    // the next (metals and currencies run across midnight).
    final spans = <(DateTime, DateTime)>[];
    for (var d = -1; d <= 14; d++) {
      final day = DateTime.utc(local.year, local.month, local.day + d);
      if (_holiday(market, day)) continue;
      for (final (from, to) in _sessions(market, day.weekday)) {
        final start = _toUtc(market, day, from), end = _toUtc(market, day, to);
        if (spans.isNotEmpty && !start.isAfter(spans.last.$2)) {
          spans.last = (spans.last.$1, end);
        } else {
          spans.add((start, end));
        }
      }
    }
    for (final (start, end) in spans) {
      if (at.isBefore(start)) return MarketStatus(open: false, next: start);
      if (at.isBefore(end)) return MarketStatus(open: true, next: end);
    }
    return const MarketStatus(open: false);
  }

  // Minutes after local midnight.
  static const _sun = DateTime.sunday, _mon = DateTime.monday, _thu = DateTime.thursday, _fri = DateTime.friday;

  static List<(int, int)> _sessions(Market market, int weekday) {
    bool between(int a, int b) => a <= b ? weekday >= a && weekday <= b : weekday >= a || weekday <= b;
    final monFri = between(_mon, _fri), sunThu = between(_sun, _thu);
    return switch (market) {
      Market.always => const [(0, 1440)],
      Market.us => monFri ? const [(570, 960)] : const [],
      Market.london => monFri ? const [(480, 990)] : const [],
      Market.xetra => monFri ? const [(540, 1050)] : const [],
      Market.tokyo => monFri ? const [(540, 690), (750, 930)] : const [],
      Market.tadawul => sunThu ? const [(600, 900)] : const [],
      Market.egx => sunThu ? const [(600, 870)] : const [],
      Market.uae => monFri ? const [(600, 900)] : const [],
      Market.qatar => sunThu ? const [(570, 795)] : const [],
      Market.kuwait => sunThu ? const [(540, 760)] : const [],
      Market.metals => switch (weekday) {
          _sun => const [(1080, 1440)],
          _fri => const [(0, 1020)],
          DateTime.saturday => const [],
          _ => const [(0, 1020), (1080, 1440)],
        },
      Market.fx => switch (weekday) {
          _sun => const [(1020, 1440)],
          _fri => const [(0, 1020)],
          DateTime.saturday => const [],
          _ => const [(0, 1440)],
        },
    };
  }

  /// [day] (a local date) at [minutes] past its midnight, in UTC.
  static DateTime _toUtc(Market market, DateTime day, int minutes) {
    final wall = DateTime.utc(day.year, day.month, day.day).add(Duration(minutes: minutes));
    final guess = wall.subtract(_standard(market));
    return wall.subtract(_offset(market, guess));
  }

  static Duration _standard(Market market) => Duration(
        hours: switch (market) {
          Market.us || Market.metals || Market.fx => -5,
          Market.london => 0,
          Market.xetra => 1,
          Market.egx => 2,
          Market.tadawul || Market.qatar || Market.kuwait => 3,
          Market.uae => 4,
          Market.tokyo => 9,
          Market.always => 0,
        },
      );

  /// The market's offset from UTC at the instant [utc], summer time included.
  static Duration _offset(Market market, DateTime utc) {
    final standard = _standard(market);
    final y = utc.year;
    final summer = switch (market) {
      // Second Sunday of March 02:00 to first Sunday of November 02:00.
      Market.us || Market.metals || Market.fx =>
        !utc.isBefore(_nthSunday(y, 3, 2).add(const Duration(hours: 7))) && utc.isBefore(_nthSunday(y, 11, 1).add(const Duration(hours: 6))),
      // Last Sunday of March to last Sunday of October, 01:00 UTC.
      Market.london || Market.xetra =>
        !utc.isBefore(_last(y, 3, DateTime.sunday).add(const Duration(hours: 1))) && utc.isBefore(_last(y, 10, DateTime.sunday).add(const Duration(hours: 1))),
      // Egypt: the last Friday of April to the end of the last Thursday of October.
      Market.egx => y >= 2023 &&
          !utc.isBefore(_last(y, 4, DateTime.friday).subtract(const Duration(hours: 2))) &&
          utc.isBefore(_last(y, 10, DateTime.thursday).add(const Duration(hours: 21))),
      _ => false,
    };
    return summer ? standard + const Duration(hours: 1) : standard;
  }

  static DateTime _nthSunday(int year, int month, int n) {
    final first = DateTime.utc(year, month, 1);
    return first.add(Duration(days: (DateTime.sunday - first.weekday) % 7 + 7 * (n - 1)));
  }

  static DateTime _last(int year, int month, int weekday) {
    final last = DateTime.utc(year, month + 1, 0);
    return last.subtract(Duration(days: (last.weekday - weekday) % 7));
  }

  static bool _holiday(Market market, DateTime day) => switch (market) {
        Market.us => _usHoliday(day),
        Market.london || Market.xetra => (day.month == 12 && (day.day == 25 || day.day == 26)) || (day.month == 1 && day.day == 1) || _isEasterBreak(day),
        Market.metals || Market.fx => (day.month == 12 && day.day == 25) || (day.month == 1 && day.day == 1),
        Market.tokyo => (day.month == 1 && day.day <= 3) || (day.month == 12 && day.day == 31),
        _ => false,
      };

  /// NYSE full-day holidays, a weekend date moved to the nearest weekday.
  static bool _usHoliday(DateTime day) {
    final y = day.year;
    DateTime observed(DateTime d) => switch (d.weekday) {
          DateTime.saturday => d.subtract(const Duration(days: 1)),
          DateTime.sunday => d.add(const Duration(days: 1)),
          _ => d,
        };
    DateTime nth(int month, int weekday, int n) {
      final first = DateTime.utc(y, month, 1);
      return first.add(Duration(days: (weekday - first.weekday) % 7 + 7 * (n - 1)));
    }

    final holidays = [
      // New Year's Day moves to Monday, never back into December.
      if (DateTime.utc(y, 1, 1).weekday != DateTime.saturday) observed(DateTime.utc(y, 1, 1)),
      nth(1, DateTime.monday, 3),
      nth(2, DateTime.monday, 3),
      _easter(y).subtract(const Duration(days: 2)),
      _last(y, 5, DateTime.monday),
      if (y >= 2022) observed(DateTime.utc(y, 6, 19)),
      observed(DateTime.utc(y, 7, 4)),
      nth(9, DateTime.monday, 1),
      nth(11, DateTime.thursday, 4),
      observed(DateTime.utc(y, 12, 25)),
    ];
    return holidays.any((h) => h.month == day.month && h.day == day.day);
  }

  /// Good Friday or Easter Monday.
  static bool _isEasterBreak(DateTime day) {
    final easter = _easter(day.year);
    return [easter.subtract(const Duration(days: 2)), easter.add(const Duration(days: 1))].any((d) => d.month == day.month && d.day == day.day);
  }

  /// Western Easter Sunday (anonymous Gregorian algorithm).
  static DateTime _easter(int y) {
    final a = y % 19, b = y ~/ 100, c = y % 100, d = b ~/ 4, e = b % 4;
    final f = (b + 8) ~/ 25, g = (b - f + 1) ~/ 3, h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4, k = c % 4, l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31, dayOf = (h + l - 7 * m + 114) % 31 + 1;
    return DateTime.utc(y, month, dayOf);
  }
}
