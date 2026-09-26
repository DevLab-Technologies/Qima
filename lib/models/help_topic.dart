import 'package:flutter/material.dart';

/// One numbered "how to use it" step inside a [HelpTopic]: an icon, a bold
/// short title, and one explanatory sentence.
class HelpStep {
  final IconData icon;
  final String title;
  final String body;

  const HelpStep({required this.icon, required this.title, required this.body});
}

/// The content of one page's help sheet (spec "Help on every page"): what
/// the page does, and a short numbered how-to. Every [HelpTopic] is built
/// from localized strings by a `for*` factory in `help_topics.dart` — this
/// class itself carries no localization logic, so the same generic
/// [HelpSheet] widget can render any page's topic from one data shape
/// instead of a bespoke sheet per screen.
class HelpTopic {
  final String title;
  final String summary;
  final List<HelpStep> steps;

  /// Optional line shown under the steps (used by the Widgets topic's
  /// refresh-interval note).
  final String? footnote;

  const HelpTopic({
    required this.title,
    required this.summary,
    required this.steps,
    this.footnote,
  });
}
