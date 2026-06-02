import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';

/// Genel onay dialog'u. [title] zorunlu; [body] isteğe bağlı.
/// Onaylanırsa `true`, iptal edilirse `false` döner.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? body,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: body != null ? Text(body) : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel ?? l10n.cancel),
        ),
        TextButton(
          style: destructive
              ? TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmLabel ?? l10n.confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
