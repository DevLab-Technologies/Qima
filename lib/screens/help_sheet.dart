import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/help_topic.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/qima_colors.dart';
import 'onboarding_tour_screen.dart';

/// The help bottom sheet opened by every [HelpButton] (spec "Help on every
/// page"): a drag handle, a small-caps "ABOUT THIS PAGE" header above the
/// page name, a close button, a one-line summary, a "HOW TO USE IT" label,
/// numbered steps (icon, bold title, one sentence), and a footer
/// "Replay the tour" link. Scrollable so it never overflows on a small or
/// large-text screen.
///
/// Data-driven (spec "One data-driven sheet"): every page supplies a
/// [HelpTopicId] and this single widget renders whatever [HelpTopic] that
/// resolves to — there are no per-page sheet widgets.
class HelpSheet extends StatelessWidget {
  final HelpTopic topic;

  const HelpSheet({super.key, required this.topic});

  static Future<void> show(BuildContext context, {required HelpTopicId topic}) {
    final colors = context.colors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DS.radiusCard)),
      ),
      builder: (sheetContext) => HelpSheet(topic: helpTopicFor(sheetContext, topic)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceXS, DS.spaceMD, DS.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: colors.tileTop, shape: BoxShape.circle),
                    child: Icon(Icons.help_outline, color: colors.brandText, size: 20),
                  ),
                  const SizedBox(width: DS.spaceSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.helpSheetAboutHeader,
                          style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          topic.title,
                          style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.helpSheetCloseTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: DS.spaceSM),
              Text(topic.summary, style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.4)),
              const SizedBox(height: DS.spaceLG),
              Text(
                l10n.helpSheetHowToHeader,
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: DS.spaceSM),
              for (var i = 0; i < topic.steps.length; i++) ...[
                if (i > 0) const SizedBox(height: DS.spaceMD),
                _HelpStepRow(index: i + 1, step: topic.steps[i]),
              ],
              if (topic.footnote != null) ...[
                const SizedBox(height: DS.spaceMD),
                Text(topic.footnote!, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
              ],
              const SizedBox(height: DS.spaceLG),
              Divider(color: colors.hairline),
              const SizedBox(height: DS.spaceXS),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () => _replayTour(context),
                  icon: Icon(Icons.replay, color: colors.brandText, size: 18),
                  label: Text(l10n.onboardingReplayTour, style: TextStyle(color: colors.brandText)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: AlignmentDirectional.centerStart),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _replayTour(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingTourScreen()));
  }
}

class _HelpStepRow extends StatelessWidget {
  final int index;
  final HelpStep step;

  const _HelpStepRow({required this.index, required this.step});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colors.tileTop, shape: BoxShape.circle),
              child: Icon(step.icon, color: colors.textSecondary, size: 18),
            ),
            PositionedDirectional(
              bottom: -2,
              end: -2,
              child: Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.brand, shape: BoxShape.circle),
                child: Text(
                  '$index',
                  style: TextStyle(color: colors.onBrand, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: DS.spaceSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(step.body, style: TextStyle(color: colors.textTertiary, fontSize: 13, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}
