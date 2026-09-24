import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qima/l10n/app_localizations.dart';
import 'package:qima/widgets/confirm_delete_dialog.dart';

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: home),
    );

/// A button that opens the dialog and records what it resolved to.
class _Opener extends StatelessWidget {
  final ValueChanged<bool> onResult;

  const _Opener({required this.onResult});

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: () async => onResult(
          await confirmDelete(context, title: 'Delete this lot?', message: 'Gone for good.', confirmLabel: 'Delete'),
        ),
        child: const Text('open'),
      );
}

/// A swipe-to-delete list wired the same way as the watchlist and lot lists.
class _SwipeList extends StatefulWidget {
  const _SwipeList();

  @override
  State<_SwipeList> createState() => _SwipeListState();
}

class _SwipeListState extends State<_SwipeList> {
  final items = ['Gold', 'Silver'];

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          for (final item in items)
            Dismissible(
              key: ValueKey(item),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => confirmDelete(context, title: 'Remove $item?', message: 'Sure?', confirmLabel: 'Remove'),
              onDismissed: (_) => setState(() => items.remove(item)),
              child: ListTile(title: Text(item)),
            ),
        ],
      );
}

void main() {
  testWidgets('confirm resolves true', (tester) async {
    bool? result;
    await tester.pumpWidget(_app(_Opener(onResult: (r) => result = r)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this lot?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('cancel resolves false', (tester) async {
    bool? result;
    await tester.pumpWidget(_app(_Opener(onResult: (r) => result = r)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('tapping outside resolves false', (tester) async {
    bool? result;
    await tester.pumpWidget(_app(_Opener(onResult: (r) => result = r)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('cancel button follows the app language', (tester) async {
    await tester.pumpWidget(_app(_Opener(onResult: (_) {}), locale: const Locale('ar')));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('إلغاء'), findsOneWidget);
  });

  testWidgets('a swipe keeps the row until the delete is confirmed', (tester) async {
    await tester.pumpWidget(_app(const _SwipeList()));

    await tester.drag(find.text('Gold'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Remove Gold?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Gold'), findsOneWidget, reason: 'cancelling slides the row back');

    await tester.drag(find.text('Gold'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Gold'), findsNothing);
    expect(find.text('Silver'), findsOneWidget);
  });
}
