import 'package:equatable/equatable.dart';

import 'asset.dart';

/// A half-open `[start, end)` range of matched characters within a string,
/// used to bold the substring a search query matched.
class MatchRange extends Equatable {
  final int start;
  final int end;

  const MatchRange(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

/// One instrument that matched a search query, with the ranges (in the
/// ORIGINAL, un-normalized display name/symbol) the query matched.
///
/// When neither the name nor the symbol matched, [alias] is the other name
/// that did ("Oro", "دهب") and [aliasRanges] the part of it the query
/// matched, so the row can say why it is there.
class InstrumentMatch extends Equatable {
  final Instrument instrument;
  final List<MatchRange> nameRanges;
  final List<MatchRange> symbolRanges;
  final String? alias;
  final List<MatchRange> aliasRanges;

  const InstrumentMatch({
    required this.instrument,
    this.nameRanges = const [],
    this.symbolRanges = const [],
    this.alias,
    this.aliasRanges = const [],
  });

  @override
  List<Object?> get props => [instrument, nameRanges, symbolRanges, alias, aliasRanges];
}

/// Matches for a single [AssetClass], in catalog order.
class InstrumentSearchGroup extends Equatable {
  final AssetClass assetClass;
  final List<InstrumentMatch> matches;

  const InstrumentSearchGroup({required this.assetClass, required this.matches});

  @override
  List<Object?> get props => [assetClass, matches];
}

/// Filters the instrument catalog (built-in + custom) by localized display
/// name or symbol, case- and diacritic-insensitive — including Arabic, where
/// the search strips tashkeel (short vowel marks) and normalizes alef/ya/ta
/// marbuta variants so e.g. "دولار" matches "الدولار الأمريكي" and "إ"/"ا"
/// are treated the same letter.
///
/// This is a pure function over the data the caller already has — it takes a
/// `displayName` resolver instead of a `BuildContext` so it stays testable
/// without Flutter's widget/localization machinery.
class InstrumentSearch {
  InstrumentSearch._();

  /// Strips combining diacritical marks (U+0300–U+036F, which covers Latin
  /// accents) and Arabic tashkeel/tatweel (U+064B–U+065F, U+0670, U+0640),
  /// then normalizes a handful of Arabic letter variants that are visually
  /// distinct but represent "the same" letter for search purposes (the
  /// various hamza-on-alef forms folding to bare alef, and taa marbuta
  /// folding to haa, matching how people actually type search queries).
  static String _normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0300 && rune <= 0x036F) continue; // Latin combining marks
      if (rune >= 0x064B && rune <= 0x065F) continue; // Arabic tashkeel
      if (rune == 0x0670) continue; // Arabic superscript alef
      if (rune == 0x0640) continue; // Arabic tatweel
      buffer.writeCharCode(_foldArabic(rune));
    }
    return buffer.toString().toLowerCase();
  }

  static int _foldArabic(int rune) {
    switch (rune) {
      case 0x0622: // ALEF WITH MADDA ABOVE
      case 0x0623: // ALEF WITH HAMZA ABOVE
      case 0x0625: // ALEF WITH HAMZA BELOW
      case 0x0671: // ALEF WASLA
        return 0x0627; // ALEF
      case 0x0629: // TEH MARBUTA
        return 0x0647; // HEH
      case 0x0649: // ALEF MAKSURA
        return 0x064A; // YEH
      default:
        return rune;
    }
  }

  /// Finds every non-overlapping occurrence of [normalizedQuery] within
  /// [normalizedTarget], reported as ranges against [original] (same length
  /// as the normalized string — folding never changes codepoint count here,
  /// since every fold above is a 1:1 rune substitution and every strip
  /// removes whole runes symmetrically between normalized/original... except
  /// stripped marks, which is why we index by rune position, not byte
  /// offset).
  static List<MatchRange> _matchRanges(String original, String normalizedQuery) {
    if (normalizedQuery.isEmpty) return const [];
    // Build the normalized string alongside a map from each of its rune
    // positions back to the corresponding rune position in `original`, so
    // ranges found in normalized space can be translated back correctly even
    // though diacritics were removed.
    final normalizedRunes = <int>[];
    final backMap = <int>[];
    final originalRunes = original.runes.toList();
    for (var i = 0; i < originalRunes.length; i++) {
      final rune = originalRunes[i];
      if (rune >= 0x0300 && rune <= 0x036F) continue;
      if (rune >= 0x064B && rune <= 0x065F) continue;
      if (rune == 0x0670) continue;
      if (rune == 0x0640) continue;
      normalizedRunes.add(_foldArabic(rune));
      backMap.add(i);
    }
    final normalizedTarget = String.fromCharCodes(normalizedRunes).toLowerCase();
    // toLowerCase() can change length for a few codepoints (rare, but
    // possible for some scripts); fall back to a straightforward substring
    // search on the rune list directly, which sidesteps that entirely for
    // the ASCII/Arabic queries this app deals with, and only falls short in
    // exotic cases where highlighting is best-effort anyway.
    if (normalizedTarget.length != normalizedRunes.length) {
      return _matchRangesSimple(original, normalizedQuery);
    }

    final ranges = <MatchRange>[];
    var searchStart = 0;
    while (searchStart <= normalizedTarget.length - normalizedQuery.length) {
      final index = normalizedTarget.indexOf(normalizedQuery, searchStart);
      if (index == -1) break;
      final startRune = backMap[index];
      final endRune = index + normalizedQuery.length - 1 < backMap.length
          ? backMap[index + normalizedQuery.length - 1] + 1
          : originalRunes.length;
      ranges.add(MatchRange(startRune, endRune));
      searchStart = index + normalizedQuery.length;
    }
    return ranges;
  }

  /// Fallback matcher used only when rune-precise back-mapping isn't safe
  /// (see above): matches on the fully-normalized string and reports the
  /// range against that same normalized string, which is still correct to
  /// highlight as long as the caller renders the normalized text — in
  /// practice this path is effectively unreachable for the scripts Qima
  /// supports, so it's a defensive fallback rather than a real code path.
  static List<MatchRange> _matchRangesSimple(String original, String normalizedQuery) {
    final normalizedTarget = _normalize(original);
    final ranges = <MatchRange>[];
    var searchStart = 0;
    while (true) {
      final index = normalizedTarget.indexOf(normalizedQuery, searchStart);
      if (index == -1) break;
      ranges.add(MatchRange(index, index + normalizedQuery.length));
      searchStart = index + normalizedQuery.length;
    }
    return ranges;
  }

  /// Filters [instruments] by [query] against each one's [displayName] and
  /// symbol, then its [aliases] (names in other languages, everyday words)
  /// when neither matched, grouped by asset class in catalog order (the same order
  /// [instruments] was passed in). Instruments with no match in either field
  /// are dropped; a blank/whitespace-only query is not a special case here —
  /// callers should show the plain unfiltered catalog UI themselves when the
  /// query is empty (see `AddInstrumentScreen`).
  static List<InstrumentSearchGroup> search(
    List<Instrument> instruments,
    String query, {
    required String Function(Instrument) displayName,
    Iterable<String> Function(Instrument)? aliases,
  }) {
    final normalizedQuery = _normalize(query.trim());
    if (normalizedQuery.isEmpty) return const [];

    final byClass = <AssetClass, List<InstrumentMatch>>{};
    for (final instrument in instruments) {
      final name = displayName(instrument);
      final nameRanges = _matchRanges(name, normalizedQuery);
      final symbolRanges = _matchRanges(instrument.symbol, normalizedQuery);
      InstrumentMatch? match;
      if (nameRanges.isNotEmpty || symbolRanges.isNotEmpty) {
        match = InstrumentMatch(instrument: instrument, nameRanges: nameRanges, symbolRanges: symbolRanges);
      } else if (aliases != null) {
        match = _aliasMatch(instrument, aliases(instrument), normalizedQuery);
      }
      if (match == null) continue;
      byClass.putIfAbsent(instrument.assetClass, () => []).add(match);
    }

    final groups = <InstrumentSearchGroup>[];
    for (final assetClass in AssetClass.values) {
      final matches = byClass[assetClass];
      if (matches == null || matches.isEmpty) continue;
      groups.add(InstrumentSearchGroup(assetClass: assetClass, matches: matches));
    }
    return groups;
  }

  /// The alias that best explains the match: one the query starts, then
  /// the shortest, so "دول" shows "دولار" rather than a longer phrase.
  static InstrumentMatch? _aliasMatch(Instrument instrument, Iterable<String> aliases, String normalizedQuery) {
    ({String alias, List<MatchRange> ranges, bool prefix})? best;
    for (final alias in aliases) {
      final ranges = _matchRanges(alias, normalizedQuery);
      if (ranges.isEmpty) continue;
      final prefix = ranges.first.start == 0;
      final better = best == null ||
          (prefix && !best.prefix) ||
          (prefix == best.prefix && alias.length < best.alias.length);
      if (better) best = (alias: alias, ranges: ranges, prefix: prefix);
    }
    if (best == null) return null;
    return InstrumentMatch(instrument: instrument, alias: best.alias, aliasRanges: best.ranges);
  }
}
