import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../l10n/app_localizations.dart';
import '../models/spoken_numbers.dart';
import '../services/dictation_service.dart';
import '../theme/qima_colors.dart';

/// The mic in the Add field (v4 phase 4), in one of four states: ready,
/// listening, unavailable for this language, or turned off in Settings.
/// What it hears goes into the field as text, with number words as digits,
/// so the field and the parser treat it exactly like typing.
class DictationButton extends StatefulWidget {
  /// Called with the text so far while listening, and once more at the end.
  final ValueChanged<String> onText;

  const DictationButton({super.key, required this.onText});

  @override
  State<DictationButton> createState() => _DictationButtonState();
}

class _DictationButtonState extends State<DictationButton> {
  DictationAvailability? _availability;
  String? _checkedTag;
  StreamSubscription<DictationEvent>? _session;

  DictationService get _service => context.read<AppCubit>().dictation;

  String get _tag => dictationLocaleTag(Localizations.localeOf(context));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tag = _tag;
    if (tag != _checkedTag) {
      _checkedTag = tag;
      _check(tag);
    }
  }

  Future<void> _check(String tag) async {
    final availability = await _service.availability(tag);
    if (mounted && tag == _checkedTag) setState(() => _availability = availability);
  }

  @override
  void dispose() {
    if (_session != null) {
      _session!.cancel();
      _service.stop();
    }
    super.dispose();
  }

  void _toggle() {
    if (_session != null) {
      _service.stop();
      return;
    }
    switch (_availability) {
      case DictationAvailability.available:
        _start();
      case DictationAvailability.denied:
        _explain(AppLocalizations.of(context)!.dictationDenied);
      case DictationAvailability.unsupported || null:
        _explain(AppLocalizations.of(context)!.dictationUnsupported);
    }
  }

  void _start() {
    setState(() {
      _session = _service.listen(_tag).listen(
        (event) {
          switch (event) {
            case DictationPartial(:final text):
              widget.onText(SpokenNumbers.toDigits(text));
            case DictationFinal(:final text):
              widget.onText(SpokenNumbers.toDigits(text));
            case DictationFailed(:final denied):
              if (denied && mounted) {
                setState(() => _availability = DictationAvailability.denied);
                _explain(AppLocalizations.of(context)!.dictationDenied);
              }
          }
        },
        onDone: () {
          if (mounted) setState(() => _session = null);
        },
      );
    });
  }

  void _explain(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(persist: false, content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final listening = _session != null;
    final (icon, color, tooltip) = switch (_availability) {
      _ when listening => (Icons.stop_circle, colors.brand, l10n.dictationStop),
      DictationAvailability.available => (Icons.mic_none, colors.textSecondary, l10n.dictationStart),
      DictationAvailability.denied => (Icons.mic_off, colors.textTertiary, l10n.dictationDenied),
      _ => (Icons.mic_none, colors.textTertiary.withValues(alpha: 0.5), l10n.dictationUnsupported),
    };
    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: tooltip,
      onPressed: _toggle,
    );
  }
}
