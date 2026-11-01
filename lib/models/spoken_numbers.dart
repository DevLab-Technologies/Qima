/// Turns numbers said in words into digits ("twenty one grams" → "21
/// grams", "واحد وعشرين جرام" → "21 جرام") so dictated text reads like
/// typed text before it reaches the field and the parser (v4 phase 4).
///
/// Only runs of number words change; every other word is left exactly as
/// recognized. Recognizers mostly emit digits already, so this is the
/// fallback for when they don't.
class SpokenNumbers {
  SpokenNumbers._();

  static const Map<String, int> _englishUnits = {
    'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5, 'six': 6, 'seven': 7, 'eight': 8,
    'nine': 9, 'ten': 10, 'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15,
    'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19, 'twenty': 20, 'thirty': 30,
    'forty': 40, 'fifty': 50, 'sixty': 60, 'seventy': 70, 'eighty': 80, 'ninety': 90,
  };

  static const Map<String, int> _arabicUnits = {
    'صفر': 0,
    'واحد': 1, 'واحده': 1, 'وحده': 1,
    'اثنين': 2, 'اثنان': 2, 'اتنين': 2, 'اثنتين': 2,
    'ثلاثه': 3, 'ثلاث': 3, 'تلاته': 3, 'تلات': 3,
    'اربعه': 4, 'اربع': 4,
    'خمسه': 5, 'خمس': 5,
    'سته': 6, 'ست': 6,
    'سبعه': 7, 'سبع': 7,
    'ثمانيه': 8, 'ثماني': 8, 'ثمان': 8, 'تمانيه': 8,
    'تسعه': 9, 'تسع': 9,
    'عشره': 10, 'عشر': 10,
    'احدعشر': 11, 'حداشر': 11, 'اثناعشر': 12, 'اطناشر': 12, 'اتناشر': 12,
    'عشرين': 20, 'عشرون': 20,
    'ثلاثين': 30, 'ثلاثون': 30, 'تلاتين': 30,
    'اربعين': 40, 'اربعون': 40,
    'خمسين': 50, 'خمسون': 50,
    'ستين': 60, 'ستون': 60,
    'سبعين': 70, 'سبعون': 70,
    'ثمانين': 80, 'ثمانون': 80, 'تمانين': 80,
    'تسعين': 90, 'تسعون': 90,
    'ميه': 100, 'مائه': 100, 'مئه': 100,
    'ميتين': 200, 'مئتين': 200, 'مائتين': 200, 'مئتان': 200, 'مائتان': 200,
    'ثلاثمائه': 300, 'ثلاثميه': 300, 'تلتميه': 300, 'اربعمائه': 400, 'اربعميه': 400, 'خمسمائه': 500,
    'خمسميه': 500, 'ستمائه': 600, 'ستميه': 600, 'سبعمائه': 700, 'سبعميه': 700, 'ثمانمائه': 800,
    'ثمنميه': 800, 'تسعمائه': 900, 'تسعميه': 900,
  };

  static const Map<String, int> _arabicScales = {
    'الف': 1000, 'الاف': 1000, 'آلاف': 1000, 'ألف': 1000, 'الفين': 2000, 'ألفين': 2000,
    'مليون': 1000000, 'ملايين': 1000000,
  };

  /// [text] with each run of number words replaced by its value.
  static String toDigits(String text) {
    final tokens = RegExp(r'\S+|\s+').allMatches(text).map((m) => m[0]!).toList();
    final out = StringBuffer();
    var i = 0;
    while (i < tokens.length) {
      final run = tokens[i].trim().isEmpty ? null : _readRun(tokens, i);
      if (run == null) {
        out.write(tokens[i]);
        i++;
        continue;
      }
      out.write(_format(run.value));
      i = run.end;
    }
    return out.toString();
  }

  static String _format(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toString();

  /// The longest run of number words starting at token [start], with the
  /// token index after it. Whitespace tokens between words belong to the run.
  static ({double value, int end})? _readRun(List<String> tokens, int start) {
    var total = 0.0;
    var current = 0.0;
    var end = start;
    var any = false;
    var i = start;
    while (i < tokens.length) {
      final token = tokens[i];
      if (token.trim().isEmpty) {
        i++;
        continue;
      }
      final word = _bare(token);
      // "and" / و only joins numbers when one follows.
      final joined = word.startsWith('و') && word.length > 1 && _value(word.substring(1)) != null;
      final value = joined ? _value(word.substring(1)) : _value(word);
      if (value != null) {
        if (value.$2) {
          // A scale: "twenty thousand", "خمس آلاف", or "ألف" alone.
          total += (current == 0 ? 1 : current) * value.$1;
          current = 0;
        } else if (value.$1 == 100 && current > 0 && current < 10) {
          current *= 100;
        } else {
          current += value.$1;
        }
        any = true;
        i++;
        end = i;
        continue;
      }
      if (any && (word == 'and' || word == 'و')) {
        i++;
        continue;
      }
      if (any && (word == 'half' || word == 'نص' || word == 'ونص' || word == 'نصف' || word == 'ونصف')) {
        current += 0.5;
        i++;
        end = i;
        continue;
      }
      if (any && word == 'a' && i + 2 < tokens.length && _bare(tokens[i + 2]) == 'half') {
        i++;
        continue;
      }
      break;
    }
    if (!any) return null;
    return (value: total + current, end: end);
  }

  /// (value, isScale) for a number word, or null.
  static (double, bool)? _value(String word) {
    final english = _englishUnits[word];
    if (english != null) return (english.toDouble(), false);
    if (word == 'hundred') return (100, false);
    if (word == 'thousand') return (1000, true);
    if (word == 'million') return (1000000, true);
    final scale = _arabicScales[word];
    if (scale != null) {
      // ألفين is two thousand on its own.
      return scale == 2000 ? (2000, false) : (scale.toDouble(), true);
    }
    final arabic = _arabicUnits[_foldArabic(word)];
    if (arabic != null) return (arabic.toDouble(), false);
    return null;
  }

  static final RegExp _edges = RegExp(r'^[^a-z0-9\u00C0-\u024F\u0600-\u06FF]+|[^a-z0-9\u00C0-\u024F\u0600-\u06FF]+$');

  /// Lower-cased, without surrounding punctuation.
  static String _bare(String token) => token.toLowerCase().replaceAll(_edges, '');

  /// Hamza forms to bare alef and ta marbuta to ha, as people spell them.
  static String _foldArabic(String word) => word
      .replaceAll(RegExp('[أإآ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(' ', '');
}
