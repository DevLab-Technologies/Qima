import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/hijri_date.dart';
import '../models/zakat.dart';
import '../theme/design_system.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';

/// Asks for the hawl start in the user's chosen calendar and returns it as
/// a local Gregorian day (null when cancelled). Never accepts a day after
/// today: a hawl can't have started in the future.
Future<DateTime?> pickHawlStart(
  BuildContext context, {
  required HawlCalendar calendar,
  DateTime? initial,
  DateTime? now,
}) async {
  final today = _day(now ?? DateTime.now());
  final start = initial == null || initial.isAfter(today) ? today : _day(initial);
  final hijriToday = HijriDate.fromGregorian(today);
  if (calendar == HawlCalendar.hijri && hijriToday != null) {
    return showDialog<DateTime>(
      context: context,
      builder: (_) => _HijriPickerDialog(initial: HijriDate.fromGregorian(start) ?? hijriToday, today: hijriToday),
    );
  }
  final picked = await showDatePicker(
    context: context,
    initialDate: start,
    firstDate: HijriDate.firstSupportedDay,
    lastDate: today,
  );
  return picked == null ? null : _day(picked);
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Day / month / year dropdowns in the Umm al-Qura calendar. The day list
/// follows the selected month's real length (29 or 30), and a day that no
/// longer exists after changing month or year clamps to the month's last
/// day instead of producing an invalid date.
class _HijriPickerDialog extends StatefulWidget {
  final HijriDate initial;
  final HijriDate today;

  const _HijriPickerDialog({required this.initial, required this.today});

  @override
  State<_HijriPickerDialog> createState() => _HijriPickerDialogState();
}

class _HijriPickerDialogState extends State<_HijriPickerDialog> {
  /// How far back the year list reaches. Thirty years covers anyone setting
  /// up the reminder today, and keeps the menu short.
  static const int _yearsBack = 30;

  late int _year = widget.initial.year;
  late int _month = widget.initial.month;
  late int _day = widget.initial.day;

  HijriDate get _selected => HijriDate(_year, _month, _day);

  bool get _isFuture => _selected.compareTo(widget.today) > 0;

  void _set({int? year, int? month, int? day}) {
    setState(() {
      _year = year ?? _year;
      _month = month ?? _month;
      _day = day ?? _day;
      final length = HijriDate.daysInMonth(_year, _month) ?? 29;
      if (_day > length) _day = length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final length = HijriDate.daysInMonth(_year, _month) ?? 29;
    final firstYear = (widget.today.year - _yearsBack).clamp(HijriDate.firstSupportedYear, widget.today.year);
    final gregorian = _selected.toGregorian();

    return AlertDialog(
      title: Text(l10n.zakatHawlPickerTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month gets a full row: "Jumada al-Akhirah" doesn't fit a third
          // of a dialog.
          _dropdown<int>(
            label: l10n.zakatHawlPickerMonth,
            value: _month,
            items: [for (var m = 1; m <= 12; m++) m],
            text: (m) => hijriMonthName(l10n, m),
            onChanged: (m) => _set(month: m),
          ),
          const SizedBox(height: DS.spaceSM),
          Row(
            children: [
              Expanded(
                child: _dropdown<int>(
                  label: l10n.zakatHawlPickerDay,
                  value: _day,
                  items: [for (var d = 1; d <= length; d++) d],
                  text: (d) => '$d',
                  onChanged: (d) => _set(day: d),
                ),
              ),
              const SizedBox(width: DS.spaceSM),
              Expanded(
                child: _dropdown<int>(
                  label: l10n.zakatHawlPickerYear,
                  value: _year,
                  items: [for (var y = widget.today.year; y >= firstYear; y--) y],
                  text: (y) => '$y',
                  onChanged: (y) => _set(year: y),
                ),
              ),
            ],
          ),
          const SizedBox(height: DS.spaceSM),
          Text(
            _isFuture
                ? l10n.zakatHawlPickerFuture
                : gregorian == null
                    ? ''
                    : l10n.zakatHawlPickerGregorian(dateWithYear(context, gregorian)),
            style: TextStyle(color: _isFuture ? colors.down : colors.textTertiary, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: DS.spaceLG, vertical: 14)),
          onPressed: _isFuture || gregorian == null ? null : () => Navigator.of(context).pop(gregorian),
          child: Text(l10n.commonDone),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) text,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: [for (final item in items) DropdownMenuItem<T>(value: item, child: Text(text(item), overflow: TextOverflow.ellipsis))],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
