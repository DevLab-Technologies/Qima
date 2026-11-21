import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qima/blocs/money_cubit.dart';
import 'package:qima/models/money.dart';
import 'package:qima/services/book_store.dart';
import 'package:qima/services/local_file_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../integration_test/store_book_seed.dart';

/// The store screenshots' demo book must stay a valid book as the model
/// changes, in both languages, and must not double up when run again.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final rates = FXRates(base: 'SAR', rates: const {'SAR': 1}, updatedAt: DateTime.utc(2026, 11, 8));

  for (final arabic in [false, true]) {
    test('the demo book balances (${arabic ? 'ar' : 'en'})', () async {
      final dir = await Directory.systemTemp.createTemp('qima_store_book');
      addTearDown(() => dir.delete(recursive: true));
      LocalFileStore.overrideDirectoryForTesting(dir);
      SharedPreferences.setMockInitialValues({});
      var ids = 0;
      final money = MoneyCubit(store: BookStore(), baseCurrency: () => 'SAR', rates: () => rates, newId: () => 'id${++ids}', now: () => DateTime(2026, 11, 8));
      await seedStoreBook(money, arabic: arabic, now: DateTime(2026, 11, 8));
      final book = money.state.book;
      expect(book.issues, isEmpty);
      final entries = book.entries.length;
      expect(entries, greaterThan(40));
      expect(book.netWorth('SAR', rates).amount, greaterThan(0));
      expect(book.balanceOf('shot-card'), greaterThan(0));

      await seedStoreBook(money, arabic: arabic, now: DateTime(2026, 11, 8));
      expect(money.state.book.entries, hasLength(entries));
      await money.close();
    });
  }
}
