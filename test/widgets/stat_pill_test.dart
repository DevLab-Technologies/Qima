import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/models/money.dart';
import 'package:qima/theme/app_theme.dart';
import 'package:qima/widgets/stat_pill.dart';

void main() {
  testWidgets('a long amount stays on one line in a narrow tile', (tester) async {
    final value = const Money(1612892.46, 'EGP').formatted();
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.dark),
      home: Scaffold(
        body: Center(child: SizedBox(width: 110, child: StatPill(title: 'Value', value: value))),
      ),
    ));

    final text = find.text(value);
    expect(tester.takeException(), isNull);
    expect(tester.widget<Text>(text).maxLines, 1);
    // Scaled down to fit the tile rather than wrapped onto a second line.
    final rendered = tester.renderObject<RenderParagraph>(text);
    expect(rendered.didExceedMaxLines, isFalse);
    expect(tester.getSize(find.byType(StatPill)).width, lessThanOrEqualTo(110));
  });
}
