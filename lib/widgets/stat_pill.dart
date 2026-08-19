import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Small labeled metric tile, matching `StatPill.swift`.
class StatPill extends StatelessWidget {
  final String title;
  final String value;
  final Color? tint;

  const StatPill({super.key, required this.title, required this.value, this.tint});

  @override
  Widget build(BuildContext context) {
    return DSTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: DS.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: tint ?? DS.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
