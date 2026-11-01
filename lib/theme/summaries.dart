import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import '../models/instrument_catalog.dart';
import '../models/money.dart';
import '../models/period_summary.dart';
import 'masking.dart';
import 'strings.dart';

/// Gains this small read as "barely moved" rather than a figure.
const double _flatPercent = 0.001;

/// "Over the past month your holdings gained 4,100 EGP (2.1%). Gold moved
/// them most, +3,900 EGP. You recorded 2 transactions." Built from the
/// summary's own figures only.
String periodSummarySentence(
  BuildContext context,
  PeriodSummary summary, {
  required String currency,
  required bool hidden,
}) {
  final l10n = AppLocalizations.of(context)!;
  final sentences = <String>[];
  if (summary.percent.abs() < _flatPercent) {
    sentences.add(l10n.summaryFlat);
  } else {
    final amount = Masking.amount(Money(summary.gainDelta.abs(), currency), hidden: hidden);
    final percent = percentLabel(context, double.parse((summary.percent.abs() * 100).toStringAsFixed(1)));
    sentences.add(summary.isUp ? l10n.summaryUp(amount, percent) : l10n.summaryDown(amount, percent));
    final mover = summary.topMoverID == null ? null : InstrumentCatalog.instrument(summary.topMoverID!);
    if (mover != null) {
      final delta = summary.topMoverDelta;
      sentences.add(l10n.summaryTopMover(
        displayLabel(context, mover.nameKey),
        Masking.signedAmount(Money(delta, currency), hidden: hidden, isUp: delta >= 0),
      ));
    }
  }
  if (summary.transactionCount > 0) sentences.add(l10n.summaryTransactions(summary.transactionCount));
  return sentences.join(' ');
}

/// What a screen reader says for a chart: its dates, start and end, change,
/// and its high and low with their dates. With balances hidden, only the
/// dates and the change.
String chartDescription(BuildContext context, ChartFacts facts, {String? currencyCode, required bool hidden}) {
  final l10n = AppLocalizations.of(context)!;
  String value(double v) => currencyCode != null ? Money(v, currencyCode).formatted() : v.toStringAsFixed(2);
  final percent = facts.percent * 100;
  final change = '${percent >= 0 ? '+' : ''}${percentLabel(context, double.parse(percent.toStringAsFixed(1)))}';
  final from = dateWithYear(context, facts.first.date);
  final to = dateWithYear(context, facts.last.date);
  if (hidden) return l10n.chartDescriptionHidden(from, to, change);
  return l10n.chartDescription(
    from,
    to,
    value(facts.first.value),
    value(facts.last.value),
    change,
    value(facts.high.value),
    dateWithYear(context, facts.high.date),
    value(facts.low.value),
    dateWithYear(context, facts.low.date),
  );
}
