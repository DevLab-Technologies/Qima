import '../models/book_account.dart';
import '../models/book_entry.dart';
import '../models/default_categories.dart';
import '../models/money_settings.dart';
import 'cloud_kv_store.dart';
import 'synced_store.dart';

/// The money ledger on disk: accounts, entries, recurring payments and
/// Money's settings, each a [SyncedStore] synced like every other collection.
///
/// Holdings are not here. They stay in the holdings ledger
/// (`TransactionsStore`) and join the balance sheet at live prices.
class BookStore {
  static const String accountsKey = 'book.accounts';
  static const String entriesKey = 'book.entries';
  static const String recurringKey = 'book.recurring';
  static const String settingsKey = 'money.settings';

  static const List<String> cloudKeys = [accountsKey, entriesKey, recurringKey, settingsKey];

  final SyncedStore<BookAccount> accounts;
  final SyncedStore<BookEntry> entries;
  final SyncedStore<RecurringPayment> recurring;
  final SyncedStore<MoneySettings> settings;

  BookStore({CloudKVStore? cloud})
      : accounts = SyncedStore<BookAccount>(
          filePath: 'book.accounts.json',
          cloudKey: accountsKey,
          itemFromJson: BookAccount.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
          seed: () => const [],
        ),
        entries = SyncedStore<BookEntry>(
          filePath: 'book.entries.json',
          cloudKey: entriesKey,
          itemFromJson: BookEntry.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
          seed: () => const [],
        ),
        recurring = SyncedStore<RecurringPayment>(
          filePath: 'book.recurring.json',
          cloudKey: recurringKey,
          itemFromJson: RecurringPayment.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
          seed: () => const [],
        ),
        settings = SyncedStore<MoneySettings>(
          filePath: 'money.settings.json',
          cloudKey: settingsKey,
          itemFromJson: MoneySettings.fromJson,
          cloud: cloud ?? LocalOnlyCloudKVStore(),
          seed: () => const [],
        );

  /// Adds the default categories that aren't there yet. Fixed ids and
  /// an old timestamp make it safe on every device: a category the person
  /// renamed or archived always wins over the seed.
  Future<List<BookAccount>> loadAccounts() async {
    await accounts.insertMissing([
      for (final (i, a) in DefaultCategories.all.indexed)
        Record<BookAccount>(item: a, order: -1000.0 + i, updatedAt: DateTime.utc(2000)),
    ]);
    return accounts.load();
  }

  Future<MoneySettings> loadSettings() async {
    final list = await settings.load();
    return list.isEmpty ? const MoneySettings() : list.first;
  }
}
