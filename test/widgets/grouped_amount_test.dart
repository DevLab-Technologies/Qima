import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/theme/money_labels.dart';
import 'package:qima/widgets/money_widgets.dart';

void main() {
  const f = GroupedAmountFormatter();

  /// Types [typed] after [before] (caret at the end), as a keyboard would.
  TextEditingValue type(String before, String typed) {
    final old = TextEditingValue(text: before, selection: TextSelection.collapsed(offset: before.length));
    final text = before + typed;
    return f.formatEditUpdate(old, TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length)));
  }

  test('groups the whole part as it is typed', () {
    var v = const TextEditingValue();
    for (final key in '1250000'.split('')) {
      v = type(v.text, key);
    }
    expect(v.text, '1,250,000');
    expect(v.selection.end, v.text.length);
    expect(type('1,250', '.').text, '1,250.');
    expect(type('1,250.', '5').text, '1,250.5');
    expect(type('999', '9').text, '9,999');
  });

  test('a comma typed from a comma decimal key starts the decimals', () {
    expect(type('1,250', ',').text, '1,250.');
    expect(type('1,250.5', ',').text, '1,250.5');
  });

  test('Arabic digits and separators', () {
    expect(type('', '١٢٥٠٫٥').text, '1,250.5');
  });

  test('deleting keeps the caret after the same digit', () {
    // "1,250|,000" → backspace on the 0 before the caret.
    const old = TextEditingValue(text: '1,250,000', selection: TextSelection.collapsed(offset: 5));
    final v = f.formatEditUpdate(old, const TextEditingValue(text: '1,25,000', selection: TextSelection.collapsed(offset: 4)));
    expect(v.text, '125,000');
    expect(v.text.substring(0, v.selection.end), '125');
  });

  test('field text from the book is grouped and reads back the same', () {
    expect(minorFieldText(125050, 'SAR'), '1,250.50');
    expect(minorFieldText(-3800000, 'SAR'), '-38,000.00');
    expect(minorFieldText(1500, 'KWD'), '1.500');
    expect(parseMinor(minorFieldText(123456789, 'SAR'), 'SAR'), 123456789);
    expect(groupedAmount('1,250.5'), '1,250.5');
  });
}
