import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/app_cubit.dart';
import '../blocs/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/holding_transaction.dart';
import '../models/instrument_catalog.dart';
import '../models/money.dart';
import '../services/csv/csv_import.dart';
import '../services/csv/csv_reader.dart';
import '../theme/design_system.dart';
import '../theme/help_topics.dart';
import '../theme/masking.dart';
import '../theme/qima_colors.dart';
import '../theme/strings.dart';
import '../widgets/help_button.dart';
import '../widgets/section_header.dart';
import 'currency_picker.dart';
import 'holdings_screen.dart';

enum _Step { mapping, preview, done }

/// Imports transactions from a spreadsheet (v3, Figma "Import from CSV"):
/// match the file's columns to fields, preview every row with what's wrong
/// with the ones that can't be read, import the rest, and undo the whole
/// import in one tap.
class CsvImportScreen extends StatefulWidget {
  final String fileName;
  final String text;

  const CsvImportScreen({super.key, required this.fileName, required this.text});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  late final CsvTable _table = CsvReader.parse(widget.text);
  late CsvMapping _mapping;
  _Step _step = _Step.mapping;
  CsvImportPlan? _plan;
  List<String> _importedIds = const [];
  bool _onlyProblems = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _mapping = CsvImporter.autoMap(_table, fallbackCurrency: context.read<AppCubit>().state.baseCurrency);
  }

  void _buildPlan() {
    final state = context.read<AppCubit>().state;
    setState(() {
      _plan = CsvImporter.plan(
        _table,
        _mapping,
        existing: state.transactions,
        availableCurrencies: state.rates.availableCurrencies,
        now: DateTime.now(),
      );
      _onlyProblems = false;
      _step = _Step.preview;
    });
  }

  Future<void> _import() async {
    final plan = _plan;
    if (plan == null || _busy) return;
    setState(() => _busy = true);
    final ids = await context.read<AppCubit>().importTransactions(plan.ready);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _importedIds = ids;
      _step = _Step.done;
    });
  }

  Future<void> _undo() async {
    setState(() => _busy = true);
    await context.read<AppCubit>().undoImport(_importedIds);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.csvImportUndone(_importedIds.length))));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.csvImportTitle),
          automaticallyImplyLeading: _step != _Step.done,
          actions: const [HelpButton(topic: HelpTopicId.importPreview)],
        ),
        body: switch (_step) {
          _Step.mapping => _mappingStep(context),
          _Step.preview => _previewStep(context),
          _Step.done => _doneStep(context),
        },
      ),
    );
  }

  // -------------------------------------------------------------------
  // Step 1: columns
  // -------------------------------------------------------------------

  Widget _mappingStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final cubit = context.read<AppCubit>();
    final dateColumn = _mapping[CsvField.date];
    final ambiguousDates = dateColumn != null && CsvImporter.hasAmbiguousDates(_table, dateColumn);

    if (_table.body.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(DS.spaceMD),
        children: [
          DSCard(child: Text(l10n.csvImportEmptyFile, style: TextStyle(color: colors.textSecondary))),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(DS.spaceMD),
      children: [
        DSCard(
          child: Row(
            children: [
              Icon(Icons.table_chart_outlined, color: colors.brandText),
              const SizedBox(width: DS.spaceSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.fileName,
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                    Text(l10n.csvImportRowCount(_table.body.length), style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DS.spaceLG),
        SectionHeader(l10n.csvImportColumnsSection),
        DSCard(
          child: Column(
            children: [
              for (final field in _fieldOrder)
                _FieldRow(
                  label: _fieldLabel(l10n, field),
                  required: _required.contains(field),
                  value: _mapping[field],
                  header: _table.header,
                  sample: _table.body.first,
                  notInFile: l10n.csvImportNotInFile,
                  onChanged: (column) => setState(() => _mapping = _mapping.withColumn(field, column)),
                ),
            ],
          ),
        ),
        const SizedBox(height: DS.spaceSM),
        Text(l10n.csvImportColumnsFooter, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
        const SizedBox(height: DS.spaceLG),
        SectionHeader(l10n.csvImportOptionsSection),
        DSCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.csvImportFallbackCurrency, style: TextStyle(color: colors.textPrimary)),
                subtitle: Text(l10n.csvImportFallbackCurrencySubtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                trailing: Text(_mapping.fallbackCurrency, style: TextStyle(color: colors.textSecondary)),
                onTap: () async {
                  final selected = await CurrencyPicker.show(
                    context,
                    selected: _mapping.fallbackCurrency,
                    currencies: cubit.state.rates.availableCurrencies,
                  );
                  if (selected != null) setState(() => _mapping = _mapping.copyWith(fallbackCurrency: selected));
                },
              ),
              if (ambiguousDates) ...[
                Divider(color: colors.hairline),
                Text(l10n.csvImportDateOrder, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                const SizedBox(height: 4),
                SegmentedButton<DateOrder>(
                  segments: [
                    ButtonSegment(value: DateOrder.dayFirst, label: Text(l10n.csvImportDayFirst)),
                    ButtonSegment(value: DateOrder.monthFirst, label: Text(l10n.csvImportMonthFirst)),
                  ],
                  selected: {_mapping.dateOrder},
                  onSelectionChanged: (s) => setState(() => _mapping = _mapping.copyWith(dateOrder: s.first)),
                  style: DS.segmentedButtonStyle(colors, colors.brand),
                ),
              ],
              Divider(color: colors.hairline),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.csvImportDecimalComma, style: TextStyle(color: colors.textPrimary)),
                subtitle: Text(l10n.csvImportDecimalCommaSubtitle, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                value: _mapping.decimalComma,
                activeThumbColor: colors.onBrand,
                activeTrackColor: colors.brand,
                onChanged: (v) => setState(() => _mapping = _mapping.copyWith(decimalComma: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: DS.spaceLG),
        if (!_mapping.isUsable)
          Padding(
            padding: const EdgeInsets.only(bottom: DS.spaceSM),
            child: Text(l10n.csvImportNeedsColumns, style: TextStyle(color: colors.down, fontSize: 13)),
          ),
        FilledButton(
          onPressed: _mapping.isUsable ? _buildPlan : null,
          child: Text(l10n.csvImportReview),
        ),
      ],
    );
  }

  static const _fieldOrder = [
    CsvField.date,
    CsvField.type,
    CsvField.asset,
    CsvField.symbol,
    CsvField.quantity,
    CsvField.unit,
    CsvField.karat,
    CsvField.unitPrice,
    CsvField.total,
    CsvField.fee,
    CsvField.currency,
    CsvField.note,
  ];

  static const _required = {CsvField.date, CsvField.quantity};

  // -------------------------------------------------------------------
  // Step 2: preview
  // -------------------------------------------------------------------

  Widget _previewStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final plan = _plan!;
    final rows = _onlyProblems ? plan.rows.where((r) => !r.ready).toList() : plan.rows;
    final hidden = context.read<AppCubit>().state.hideBalances;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(DS.spaceMD),
            children: [
              DSCard(
                child: Row(
                  children: [
                    _count(colors, l10n.csvImportReadyCount, plan.readyCount, colors.up),
                    _count(colors, l10n.csvImportDuplicateCount, plan.duplicateCount, colors.textSecondary),
                    _count(colors, l10n.csvImportProblemCount, plan.problemCount, colors.down),
                  ],
                ),
              ),
              const SizedBox(height: DS.spaceSM),
              if (plan.problemCount + plan.duplicateCount > 0) ...[
                Text(l10n.csvImportSkipNote, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                const SizedBox(height: DS.spaceSM),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(l10n.csvImportShowAll)),
                    ButtonSegment(value: true, label: Text(l10n.csvImportShowProblems)),
                  ],
                  selected: {_onlyProblems},
                  onSelectionChanged: (s) => setState(() => _onlyProblems = s.first),
                  style: DS.segmentedButtonStyle(colors, colors.brand),
                ),
                const SizedBox(height: DS.spaceSM),
              ],
              DSCard(
                padding: const EdgeInsets.symmetric(horizontal: DS.spaceMD, vertical: DS.spaceXS),
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) Divider(color: colors.hairline, height: 1),
                      _RowTile(row: rows[i], hidden: hidden),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DS.spaceMD, DS.spaceXS, DS.spaceMD, DS.spaceMD),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : () => setState(() => _step = _Step.mapping),
                  child: Text(l10n.csvImportBackToColumns),
                ),
                const SizedBox(width: DS.spaceSM),
                Expanded(
                  child: FilledButton(
                    onPressed: plan.readyCount == 0 || _busy ? null : _import,
                    child: Text(l10n.csvImportConfirm(plan.readyCount)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _count(QimaColors colors, String label, int value, Color tint) => Expanded(
        child: Column(
          children: [
            Text('$value', style: TextStyle(color: tint, fontSize: 22, fontWeight: FontWeight.w800)),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: colors.textTertiary, fontSize: 12)),
          ],
        ),
      );

  // -------------------------------------------------------------------
  // Step 3: done
  // -------------------------------------------------------------------

  Widget _doneStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(DS.spaceMD),
        children: [
          DSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, color: colors.up, size: 32),
                const SizedBox(height: DS.spaceSM),
                Text(l10n.csvImportDoneTitle(_importedIds.length),
                    style: TextStyle(color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: DS.spaceXS),
                Text(l10n.csvImportDoneMessage, style: TextStyle(color: colors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: DS.spaceLG),
          FilledButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: Text(l10n.commonDone)),
          const SizedBox(height: DS.spaceSM),
          OutlinedButton.icon(
            onPressed: _busy ? null : _undo,
            icon: const Icon(Icons.undo),
            label: Text(l10n.csvImportUndo),
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final bool required;
  final int? value;
  final List<String> header;
  final List<String> sample;
  final String notInFile;
  final ValueChanged<int?> onChanged;

  const _FieldRow({
    required this.label,
    required this.required,
    required this.value,
    required this.header,
    required this.sample,
    required this.notInFile,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    String option(int i) {
      final name = header[i].isEmpty ? '#${i + 1}' : header[i];
      final example = i < sample.length && sample[i].isNotEmpty ? ' · ${sample[i]}' : '';
      return '$name$example';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(required ? '$label *' : label, style: TextStyle(color: colors.textPrimary)),
          ),
          Expanded(
            flex: 3,
            child: DropdownButton<int?>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(notInFile, style: TextStyle(color: colors.textTertiary))),
                for (var i = 0; i < header.length; i++)
                  DropdownMenuItem<int?>(value: i, child: Text(option(i), overflow: TextOverflow.ellipsis, maxLines: 1)),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  final CsvRowOutcome row;
  final bool hidden;

  const _RowTile({required this.row, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final t = row.transaction;
    final instrument = t == null ? null : InstrumentCatalog.instrument(t.instrumentID);

    final String title;
    final String subtitle;
    if (t != null && instrument != null) {
      final name = displayLabel(context, instrument.nameKey);
      title = t.kind == TransactionKind.fee
          ? '$name · ${Masking.amount(Money(t.fee, t.currency), hidden: hidden)}'
          : '$name · ${quantityWithUnitKaratLabel(context, t.quantity, t.unit, t.karat)}';
      subtitle = transactionDateLabel(context, t.date);
    } else {
      title = row.cells.where((c) => c.isNotEmpty).take(4).join(' · ');
      subtitle = row.problems.map((p) => _problemLabel(l10n, p)).join(' · ');
    }

    final duplicate = row.problems.contains(CsvProblem.duplicate);
    final chipColor = row.ready ? colors.up : (duplicate ? colors.textSecondary : colors.down);
    final chipText = row.ready
        ? (t == null ? '' : transactionKindLabel(l10n, t.kind))
        : (duplicate ? l10n.csvImportDuplicate : l10n.csvImportSkipped);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DS.spaceSM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text('${row.line}', style: TextStyle(color: colors.textTertiary, fontSize: 12)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colors.textPrimary)),
                Text(
                  !row.ready && t != null ? row.problems.map((p) => _problemLabel(l10n, p)).join(' · ') : subtitle,
                  style: TextStyle(color: row.ready || duplicate ? colors.textTertiary : colors.down, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: DS.spaceXS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: chipColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(6)),
            child: Text(chipText, style: TextStyle(color: chipColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

String _fieldLabel(AppLocalizations l10n, CsvField field) => switch (field) {
      CsvField.type => l10n.csvFieldType,
      CsvField.asset => l10n.csvFieldAsset,
      CsvField.symbol => l10n.csvFieldSymbol,
      CsvField.quantity => l10n.csvFieldQuantity,
      CsvField.unit => l10n.csvFieldUnit,
      CsvField.karat => l10n.csvFieldKarat,
      CsvField.unitPrice => l10n.csvFieldUnitPrice,
      CsvField.total => l10n.csvFieldTotal,
      CsvField.fee => l10n.csvFieldFee,
      CsvField.currency => l10n.csvFieldCurrency,
      CsvField.date => l10n.csvFieldDate,
      CsvField.note => l10n.csvFieldNote,
    };

String _problemLabel(AppLocalizations l10n, CsvProblem problem) => switch (problem) {
      CsvProblem.unknownAsset => l10n.csvProblemUnknownAsset,
      CsvProblem.missingQuantity => l10n.csvProblemMissingQuantity,
      CsvProblem.badNumber => l10n.csvProblemBadNumber,
      CsvProblem.missingPrice => l10n.csvProblemMissingPrice,
      CsvProblem.missingDate => l10n.csvProblemMissingDate,
      CsvProblem.badDate => l10n.csvProblemBadDate,
      CsvProblem.futureDate => l10n.csvProblemFutureDate,
      CsvProblem.unknownType => l10n.csvProblemUnknownType,
      CsvProblem.unknownCurrency => l10n.csvProblemUnknownCurrency,
      CsvProblem.unsupportedUnit => l10n.csvProblemUnsupportedUnit,
      CsvProblem.unsupportedKarat => l10n.csvProblemUnsupportedKarat,
      CsvProblem.oversell => l10n.csvProblemOversell,
      CsvProblem.duplicate => l10n.csvProblemDuplicate,
    };
