import 'book.dart';
import 'book_account.dart';
import 'money.dart';
import 'net_worth.dart';
import 'zakat.dart';

/// One part of zakat on the balance sheet: a selection of its lines.
enum ZakatPart {
  /// Holdings counted by the zakat settings (metals, crypto, cash...).
  holdings,

  /// Cash and bank accounts.
  cash,

  /// Money people owe the person, expected back.
  owedToYou,

  /// Assets the person marked "Held for sale", at their value.
  heldForSale,

  /// Debts due now: card balances and money owed to people. Deducted.
  debtsDue,
}

/// Zakat over the whole balance sheet (Flow 7): the holdings the zakat
/// settings count, plus cash, money owed to the person and assets held for
/// sale, less debts due. Loans are not deducted in full: only what is due
/// now counts, and Qima doesn't know a loan's schedule, so they are left out
/// and the screen says so.
class ZakatOnBook {
  final String currency;
  final Map<ZakatPart, double> parts;
  final Money? threshold;
  final Set<String> missingRates;

  const ZakatOnBook({required this.currency, required this.parts, required this.threshold, required this.missingRates});

  double get base {
    var total = 0.0;
    parts.forEach((p, v) => total += p == ZakatPart.debtsDue ? -v : v);
    return total < 0 ? 0 : total;
  }

  bool get thresholdKnown => threshold != null;
  bool get above => threshold != null && base > 0 && base >= threshold!.amount;
  double get due => above ? base * ZakatAssessment.rate : 0;

  static ZakatOnBook of({required Book book, required ZakatAssessment holdings, required String currency, required FXRates rates}) {
    final missing = <String>{};
    double sum(bool Function(BookAccount) test) {
      var total = 0.0;
      for (final a in book.accounts.values) {
        if (!a.side.onBalanceSheet || !test(a)) continue;
        final b = book.balanceOf(a.id);
        if (b <= 0) continue;
        final v = NetWorthSummary.inCurrency(b, a.currency!, currency, rates);
        if (v == null) {
          missing.add(a.currency!);
        } else {
          total += v;
        }
      }
      return total;
    }

    return ZakatOnBook(
      currency: currency,
      parts: {
        ZakatPart.holdings: holdings.base.amount,
        ZakatPart.cash: sum((a) => a.type == AccountType.cash || a.type == AccountType.debit),
        ZakatPart.owedToYou: sum((a) => a.type == AccountType.receivable),
        ZakatPart.heldForSale: sum((a) => a.type == AccountType.asset && a.heldForSale),
        ZakatPart.debtsDue: sum((a) => a.type == AccountType.credit || a.type == AccountType.payable),
      },
      threshold: holdings.threshold,
      missingRates: missing,
    );
  }
}
