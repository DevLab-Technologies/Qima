import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import '../theme/qima_colors.dart';

/// Small labeled metric tile, matching `StatPill.swift`.
class StatPill extends StatelessWidget {
  final String title;
  final String value;
  final Color? tint;

  const StatPill({super.key, required this.title, required this.value, this.tint});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DSTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          // One line, shrunk to fit: a long amount (or a currency symbol
          // like "ج.م") must never wrap inside a narrow tile.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: tint ?? colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
