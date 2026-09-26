import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/help_sheet.dart';
import '../theme/help_topics.dart';

/// The question-mark-in-circle help entry point placed as the FIRST
/// trailing action in every full-screen page's app bar (spec "Help on
/// every page"): a fixed 48×48 hit target, tooltip/semantic label "Help",
/// opening [HelpSheet] for [topic] when tapped.
class HelpButton extends StatelessWidget {
  final HelpTopicId topic;

  const HelpButton({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        icon: const Icon(Icons.help_outline),
        tooltip: l10n.helpButtonTooltip,
        onPressed: () => HelpSheet.show(context, topic: topic),
      ),
    );
  }
}
