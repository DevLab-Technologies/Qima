import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/qima_colors.dart';
import 'help_sheet.dart';

/// "How Qima works" index sheet (spec "Settings gets a Help group"): one row
/// per [HelpTopicId], each opening that topic's [HelpSheet]. Reached from
/// Settings → Help → "How Qima works".
class HelpIndexSheet extends StatelessWidget {
  const HelpIndexSheet({super.key});

  static Future<void> show(BuildContext context) {
    final colors = context.colors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DS.radiusCard)),
      ),
      builder: (sheetContext) => const HelpIndexSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final topics = [
      for (final id in HelpTopicId.values)
        if (id != HelpTopicId.widgets || widgetsSupportedOnThisPlatform) id,
    ];

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceXS, DS.spaceMD, DS.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.helpSheetIndexHeader,
                style: TextStyle(color: colors.textTertiary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.helpIndexIntro,
                style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: DS.spaceMD),
              for (final id in topics)
                _TopicRow(
                  title: helpTopicFor(context, id).title,
                  onTap: () {
                    Navigator.of(context).pop();
                    HelpSheet.show(context, topic: id);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _TopicRow({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: colors.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
      onTap: onTap,
    );
  }
}
