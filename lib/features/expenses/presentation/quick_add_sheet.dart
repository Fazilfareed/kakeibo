import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/date/local_date.dart';
import '../../../core/db/app_database.dart';
import '../../../core/money/amount_input.dart';
import '../../../core/money/currency_format.dart';
import '../../../core/pillars/pillar_style.dart';
import '../../../core/pillars/pillars_provider.dart';
import '../../guide/domain/guide_state.dart';
import '../../guide/presentation/coach_marks.dart';
import '../../periods/data/period_providers.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/expense_providers.dart';
import '../data/expense_repository.dart';

/// Opens the quick-add sheet. Pass [editing] to edit an existing expense.
Future<void> showQuickAddSheet(BuildContext context, {Expense? editing}) {
  HapticFeedback.lightImpact();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Motion.sheet,
      reverseDuration: Motion.sheetExit,
      curve: Motion.sheetCurve,
    ),
    builder: (_) => QuickAddSheet(editing: editing),
  );
}

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, this.editing});

  final Expense? editing;

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _amountKey = GlobalKey(debugLabel: 'coach-amount');
  final _pillarsKey = GlobalKey(debugLabel: 'coach-pillar-grid');

  late AmountInput _amount;
  int? _pillarId;
  String? _note;
  late DateTime _date;
  Mood? _mood;
  int? _paymentMethodId;
  bool _refund = false;
  List<String> _recentNotes = const [];
  bool _saving = false;

  bool get _isEdit => widget.editing != null;
  bool get _canSave => _amount.cents > 0 && _pillarId != null && !_saving;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _amount = e == null ? const AmountInput.empty() : AmountInput.fromCents(e.amount);
    _pillarId = e?.pillarId;
    _note = e?.note;
    _date = e == null ? LocalDate.dateOnly(DateTime.now()) : LocalDate.parse(e.date);
    _mood = Mood.fromName(e?.mood);
    _paymentMethodId = e?.paymentMethodId;
    _refund = e?.type == 'refund';
    ref.read(expenseRepositoryProvider).recentNotes().then((notes) {
      if (mounted) setState(() => _recentNotes = notes);
    });
  }

  void _key(String k) {
    final next = k == 'back' ? _amount.backspace() : _amount.append(k);
    if (next.raw != _amount.raw) setState(() => _amount = next);
  }

  void _pickPillar(int id) {
    HapticFeedback.selectionClick();
    setState(() => _pillarId = id);
  }

  Future<void> _editNote() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _NoteDialog(initial: _note ?? ''),
    );
    if (!mounted || result == null) return;
    setState(() => _note = result.trim().isEmpty ? null : result.trim());
  }

  Future<void> _pickDate(Period period) async {
    final start = LocalDate.parse(period.startDate);
    final end = LocalDate.parse(period.endDate);
    final today = LocalDate.dateOnly(DateTime.now());
    final last = today.isBefore(end) ? today : end;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(last) ? last : _date,
      firstDate: start,
      lastDate: last,
      helpText: 'Date of this expense',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    final repo = ref.read(expenseRepositoryProvider);
    final draft = ExpenseDraft(
      pillarId: _pillarId!,
      amount: _amount.cents,
      date: LocalDate.format(_date),
      note: _note,
      mood: _refund ? null : _mood,
      paymentMethodId: _paymentMethodId,
      isRefund: _refund,
    );
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final view = View.of(context);
    final textDirection = Directionality.of(context);
    final money = ref.read(moneyFormatterProvider).formatCents(draft.amount);
    final pillarName =
        (ref.read(pillarsProvider).value ?? const <Pillar>[])
            .where((p) => p.id == draft.pillarId)
            .firstOrNull
            ?.name ??
        '';
    try {
      if (_isEdit) {
        await repo.update(widget.editing!.id, draft);
      } else {
        final id = await repo.add(draft);
        // Replace any older message so the newest save is the one shown.
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Saved $money to $pillarName'),
            // Snack bars with an action persist by default; Undo lasts 4 s (MASTER.md §7.11).
            persist: false,
            action: SnackBarAction(label: 'Undo', onPressed: () => repo.softDelete(id)),
          ),
        );
      }
      HapticFeedback.lightImpact();
      SemanticsService.sendAnnouncement(
        view,
        _isEdit
            ? 'Expense updated'
            : _refund
            ? 'Refund of $money added to $pillarName'
            : 'Saved $money to $pillarName',
        textDirection,
      );
      navigator.pop();
      if (_isEdit) {
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(const SnackBar(content: Text('Expense updated')));
      }
    } on NoPeriodForDateException {
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text("That date isn't in a planned month yet.")),
      );
    } on Object catch (e, st) {
      // PRD §8.2: say so, keep the sheet open, and log it (NFR-12).
      Logger('expenses').severe('Saving an expense failed', e, st);
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(const SnackBar(content: Text("Couldn't save. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // FR-95: the guided first expense.
    if (!_isEdit) {
      CoachMarks.maybeShow(context, ref, CoachScreen.quickAdd, [
        CoachStep(
          target: _amountKey,
          title: 'How much?',
          body: 'Type the amount on the number pad below. No keyboard needed.',
        ),
        CoachStep(
          target: _pillarsKey,
          title: 'Which pillar?',
          body:
              'Ask: do I need it? Needs for essentials, Wants for nice-to-haves, Culture for '
              'books and outings, Unexpected for surprises. Then tap Save.',
        ),
      ]);
    }
    final period = ref.watch(currentPeriodProvider).value;
    final pillars = ref.watch(pillarsProvider).value ?? const <Pillar>[];
    final methods = ref.watch(paymentMethodsProvider).value ?? const <PaymentMethod>[];
    final format = ref.watch(currencyFormatProvider);
    final today = LocalDate.dateOnly(DateTime.now());
    final dateLabel = _date == today
        ? 'Today'
        : _date == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : DateFormat('EEE, d MMM').format(_date);
    final method = methods.where((m) => m.id == _paymentMethodId).firstOrNull;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, Space.s3),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _refund
                          ? (_isEdit ? 'Edit refund' : 'Add refund')
                          : (_isEdit ? 'Edit expense' : 'Add expense'),
                      style: context.text.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Space.s2),
                    KeyedSubtree(
                      key: _amountKey,
                      child: _AmountDisplay(input: _amount, format: format),
                    ),
                    const SizedBox(height: Space.s4),
                    KeyedSubtree(
                      key: _pillarsKey,
                      child: _PillarGrid(
                        pillars: pillars,
                        selectedId: _pillarId,
                        onPick: _pickPillar,
                      ),
                    ),
                    const SizedBox(height: Space.s4),
                    Wrap(
                      spacing: Space.s2,
                      runSpacing: Space.s2,
                      children: [
                        _OptionChip(
                          icon: Symbols.edit_note_rounded,
                          label: _note ?? 'Add note',
                          selected: _note != null,
                          onTap: _editNote,
                        ),
                        if (period != null)
                          _OptionChip(
                            icon: Symbols.calendar_today_rounded,
                            label: dateLabel,
                            onTap: () => _pickDate(period),
                          ),
                        PopupMenuButton<int?>(
                          tooltip: 'Payment method',
                          onSelected: (id) => setState(() => _paymentMethodId = id),
                          itemBuilder: (_) => [
                            const PopupMenuItem<int?>(value: null, child: Text('Not set')),
                            for (final m in methods)
                              PopupMenuItem<int?>(value: m.id, child: Text(m.name)),
                          ],
                          child: _OptionChip(
                            icon: Symbols.account_balance_wallet_rounded,
                            label: method?.name ?? 'Payment',
                            selected: method != null,
                          ),
                        ),
                        // FR-28: money back lowers its pillar's spending.
                        _OptionChip(
                          icon: Symbols.undo_rounded,
                          label: 'Refund',
                          selected: _refund,
                          onTap: () => setState(() => _refund = !_refund),
                        ),
                      ],
                    ),
                    if (_note == null && _recentNotes.isNotEmpty) ...[
                      const SizedBox(height: Space.s2),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final n in _recentNotes)
                              Padding(
                                padding: const EdgeInsets.only(right: Space.s2),
                                child: ActionChip(
                                  label: Text(n),
                                  onPressed: () => setState(() => _note = n),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (_refund) ...[
                      const SizedBox(height: Space.s3),
                      Text(
                        'Choose the pillar of the original spend. This lowers its total.',
                        style: context.text.bodySmall,
                      ),
                    ],
                    if (!_refund) ...[
                      const SizedBox(height: Space.s3),
                      Text('How do you feel about it?', style: context.text.bodySmall),
                      const SizedBox(height: Space.s2),
                      Wrap(
                        spacing: Space.s2,
                        children: [
                          for (final m in Mood.values)
                            ChoiceChip(
                              avatar: Icon(_moodIcon(m), size: 18),
                              label: Text(m.label),
                              selected: _mood == m,
                              showCheckmark: false,
                              onSelected: (s) => setState(() => _mood = s ? m : null),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: Space.s3),
                  ],
                ),
              ),
            ),
            _Keypad(onKey: _key, onClear: () => setState(() => _amount = _amount.clear())),
            const SizedBox(height: Space.s3),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
                child: Text(
                  _pillarId == null
                      ? 'Choose a pillar'
                      : _amount.cents == 0
                      ? 'Enter an amount'
                      : _isEdit
                      ? 'Save changes'
                      : 'Save',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _moodIcon(Mood m) => switch (m) {
    Mood.worth => Symbols.sentiment_satisfied_rounded,
    Mood.neutral => Symbols.sentiment_neutral_rounded,
    Mood.regret => Symbols.sentiment_dissatisfied_rounded,
  };
}

/// The typed amount, grouped as you type, with a blinking caret.
class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.input, required this.format});

  final AmountInput input;
  final CurrencyFormat format;

  static final _grouping = NumberFormat('#,##0', 'en_US');

  String get _typed {
    if (input.isEmpty) return '0';
    final parts = input.raw.split('.');
    final major = _grouping.format(int.parse(parts[0].isEmpty ? '0' : parts[0]));
    return parts.length > 1 ? '$major.${parts[1]}' : major;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.moneyText.displayMoney.copyWith(
      fontSize: 44,
      color: input.isEmpty ? c.ink3 : c.ink,
    );
    final symbol = Text(
      format.symbol,
      style: style.copyWith(fontSize: 22, color: c.ink2, fontWeight: FontWeight.w500),
    );
    final gap = SizedBox(width: format.space ? Space.s2 : 0);
    return Semantics(
      liveRegion: true,
      label: 'Amount ${input.isEmpty ? 'empty' : _typed}',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (format.position == SymbolPosition.before) ...[symbol, gap],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_typed, style: style, maxLines: 1),
            ),
          ),
          const _Caret(),
          if (format.position == SymbolPosition.after) ...[gap, symbol],
        ],
      ),
    );
  }
}

class _Caret extends StatefulWidget {
  const _Caret();

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _blink.stop();
    } else if (!_blink.isAnimating) {
      _blink.repeat();
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _blink,
        builder: (context, _) => Opacity(
          opacity: _blink.value < 0.5 ? 1 : 0,
          child: Container(
            width: 2,
            height: 40,
            margin: const EdgeInsets.only(left: 2),
            color: context.colors.ink,
          ),
        ),
      ),
    );
  }
}

/// 2 × 2 grid of large pillar tiles (required before saving).
class _PillarGrid extends StatelessWidget {
  const _PillarGrid({required this.pillars, required this.selectedId, required this.onPick});

  final List<Pillar> pillars;
  final int? selectedId;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final onAccent = Theme.of(context).brightness == Brightness.light ? Colors.white : c.bg;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: Space.s2,
      crossAxisSpacing: Space.s2,
      childAspectRatio: 2.6,
      children: [
        for (final p in pillars)
          Builder(
            builder: (context) {
              final accent = PillarStyle.color(c, p.id);
              final selected = p.id == selectedId;
              return Semantics(
                button: true,
                selected: selected,
                label: p.name,
                onTap: () => onPick(p.id),
                excludeSemantics: true,
                child: Material(
                  color: selected ? accent : c.container(accent),
                  borderRadius: BorderRadius.circular(Radii.md),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onPick(p.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s3),
                      child: Row(
                        children: [
                          Icon(
                            PillarStyle.icon(p.id),
                            size: 26,
                            color: selected ? onAccent : accent,
                            fill: selected ? 1 : 0,
                          ),
                          const SizedBox(width: Space.s2),
                          Expanded(
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleMedium?.copyWith(
                                color: selected ? onAccent : accent,
                              ),
                            ),
                          ),
                          if (selected) Icon(Symbols.check_rounded, size: 20, color: onAccent),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({required this.icon, required this.label, this.selected = false, this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.bg : c.ink;
    final chip = Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: Space.s3),
      decoration: BoxDecoration(
        color: selected ? c.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: selected ? c.ink : c.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: Space.s1),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelLarge?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return Semantics(
      button: true,
      child: InkWell(borderRadius: BorderRadius.circular(Radii.sm), onTap: onTap, child: chip),
    );
  }
}

/// Custom numeric keypad, so the system keyboard never covers the sheet.
class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey, required this.onClear});

  final ValueChanged<String> onKey;
  final VoidCallback onClear;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'back'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final keyStyle = context.moneyText.moneyM.copyWith(fontSize: 22);
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: Space.s2,
        crossAxisSpacing: Space.s2,
        childAspectRatio: 2.2,
        children: [
          for (final k in _keys)
            Material(
              color: c.surfaceSunken,
              borderRadius: BorderRadius.circular(Radii.md),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onKey(k),
                onLongPress: k == 'back' ? onClear : null,
                child: Center(
                  child: k == 'back'
                      ? Icon(
                          Symbols.backspace_rounded,
                          color: c.ink,
                          semanticLabel: 'Delete, long press to clear',
                        )
                      : Text(k == '.' ? '.' : k, style: keyStyle),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The note editor. It owns its controller so the controller lives until the
/// dialog's exit animation has finished (disposing it earlier crashes).
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Note'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 60,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'What was it for?'),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
