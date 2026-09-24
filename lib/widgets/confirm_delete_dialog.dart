import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/qima_colors.dart';

/// Asks the user to confirm a destructive action before it happens.
/// Resolves to `true` only when the destructive button is tapped;
/// Cancel, the back gesture and tapping outside all resolve to `false`.
///
/// Used by every swipe-to-delete and delete button, since a swipe is easy
/// to trigger by accident and deletes can't be undone.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: context.colors.down),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
