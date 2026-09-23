import 'package:flutter_test/flutter_test.dart';
import 'package:qima/theme/strings.dart';

void main() {
  const lri = '\u2066', pdi = '\u2069';

  test('positive figures get a plus sign and are isolated left-to-right', () {
    expect(signedFigure('6.42%', isUp: true), '$lri+6.42%$pdi');
  });

  test('negative figures keep their formatted minus and get no plus', () {
    expect(signedFigure(r'-$214.80', isUp: false), '$lri-\$214.80$pdi');
  });
}
