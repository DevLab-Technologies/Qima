import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// Small uppercase caption above a grouped card ("NISAB", "PRIVACY").
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DS.spaceXS, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: context.colors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }
}
