import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/watch_card.dart';
import '../theme/strings.dart';
import 'instrument_detail_screen.dart';

/// Finishes an add-instrument flow (from [CardConfigScreen] or
/// [CustomTickerScreen]): lands on the new card's detail screen with the
/// watchlist directly underneath it on the stack — not back through every
/// intermediate add-flow screen — then surfaces a confirmation snackbar.
///
/// [created] and [customInstrumentID] come straight from
/// `AppCubit.addCard`'s result and (for a freshly-created custom ticker) the
/// `isCustom` check the caller made *before* calling `addCustomTicker` — see
/// each call site for why that ordering matters.
///
/// Synchronous (no `await` inside): callers already gate this on
/// `context.mounted` right after their own last `await`, and doing all of
/// the Navigator/ScaffoldMessenger lookups and the push/snackbar in one
/// synchronous pass means there's no further `await` gap in which the
/// widget could be disposed out from under this call.
void completeAdd(
  BuildContext context,
  WatchCard card, {
  required bool created,
  String? customInstrumentID,
}) {
  // Captured before any `await`/navigation below invalidates this context —
  // both a Navigator and a ScaffoldMessenger are tied to the widget tree
  // position they're looked up from, and `pushAndRemoveUntil` tears down
  // everything above the watchlist, including whatever `context` this was
  // resolved from.
  final cubit = context.read<AppCubit>();
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final name = displayLabel(context, card.instrument?.nameKey ?? card.instrumentID);

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => InstrumentDetailScreen(card: card)),
    (route) => route.isFirst,
  );

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(created ? l10n.addedToWatchlist(name) : l10n.alreadyInWatchlist(name)),
      action: created
          ? SnackBarAction(
              label: l10n.commonUndo,
              onPressed: () {
                cubit.undoAdd(card, customInstrumentID: customInstrumentID);
                navigator.maybePop();
              },
            )
          : null,
    ),
  );
}
