import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/asset.dart';
import '../models/market_hours.dart';
import '../theme/qima_colors.dart';

/// "Market closed · opens Mon 16:30" or "Market open · closes 23:00" for
/// [instrument], in the device's time. Nothing for a market that never
/// closes or one the symbol doesn't name.
class MarketStatusLine extends StatelessWidget {
  final Instrument instrument;
  final DateTime now;

  const MarketStatusLine({super.key, required this.instrument, required this.now});

  @override
  Widget build(BuildContext context) {
    final status = MarketHours.statusOf(instrument, now);
    if (status == null || (status.open && status.next == null)) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final next = status.next;
    final text = next == null
        ? l10n.marketClosedLong
        : status.open
            ? l10n.marketOpenCloses(_when(context, next.toLocal(), now))
            : l10n.marketClosedOpens(_when(context, next.toLocal(), now));
    return Row(
      key: ValueKey('market:${status.open ? 'open' : 'closed'}'),
      children: [
        Icon(status.open ? Icons.schedule : Icons.bedtime_outlined, size: 14, color: colors.textTertiary),
        const SizedBox(width: 4),
        Expanded(child: Text(text, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textTertiary, fontSize: 12))),
      ],
    );
  }

  /// "16:30" today, "Mon 16:30" this week, "Nov 16, 16:30" beyond.
  static String _when(BuildContext context, DateTime time, DateTime now) {
    final locale = Localizations.localeOf(context).toString();
    final today = DateTime(now.year, now.month, now.day);
    final days = DateTime(time.year, time.month, time.day).difference(today).inDays;
    final format = days == 0 ? DateFormat.Hm(locale) : days < 7 ? DateFormat.E(locale).add_Hm() : DateFormat.MMMd(locale).add_Hm();
    return format.format(time);
  }
}

/// A small "Closed" mark for a price row while an instrument's market is
/// shut: spans to end the row's detail line with, so a narrow row cuts it
/// short rather than overflowing.
class MarketClosedMark {
  const MarketClosedMark._();

  static bool closed(Instrument instrument, DateTime now) => MarketHours.statusOf(instrument, now)?.open == false;

  static List<InlineSpan> spans(BuildContext context) {
    final colors = context.colors;
    return [
      const TextSpan(text: ' · '),
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(Icons.bedtime_outlined, key: const ValueKey('marketClosed'), size: 12, color: colors.textTertiary),
      ),
      TextSpan(text: ' ${AppLocalizations.of(context)!.marketClosed}'),
    ];
  }
}
