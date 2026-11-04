import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../data/stats_providers.dart';
import '../domain/my_stats.dart';

/// My stats (FR-36): how the habit is going, from this phone's data only.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(myStatsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My stats')),
      body: stats == null ? const SizedBox.shrink() : _Body(s: stats),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.s});

  final MyStats s;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    String plural(int n, String one, [String? many]) => '$n ${n == 1 ? one : many ?? '${one}s'}';
    final pct = (s.loggedShare * 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s4, Space.gutter, Space.s7),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.s5),
            child: Semantics(
              label:
                  'Logging streak, ${plural(s.streak, 'day')}. Best ${plural(s.bestStreak, 'day')}.',
              excludeSemantics: true,
              child: Row(
                children: [
                  Icon(Symbols.local_fire_department_rounded, size: 40, color: c.seal, fill: 1),
                  const SizedBox(width: Space.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Logging streak', style: context.text.bodySmall),
                        Text(
                          plural(s.streak, 'day'),
                          style: context.moneyText.displayMoney.copyWith(fontSize: 34),
                        ),
                        Text('Best: ${plural(s.bestStreak, 'day')}', style: context.text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.s3),
        _Grid(
          tiles: [
            _Tile(
              label: 'Days logged',
              value: '$pct%',
              detail: s.daysSinceStart == 0
                  ? 'Nothing logged yet'
                  : '${s.daysLogged} of ${s.daysSinceStart} days',
            ),
            _Tile(
              label: 'Entries a day',
              value: s.entriesPerLoggedDay.toStringAsFixed(1),
              detail: 'on days you logged',
            ),
            _Tile(
              label: 'Goals met',
              value: '${s.goalsMet} of ${s.closedMonths}',
              detail: plural(s.closedMonths, 'finished month'),
            ),
            _Tile(
              label: 'Reflections',
              value: '${s.reflectionsDone} of ${s.closedMonths}',
              detail: 'months reflected on',
            ),
          ],
        ),
        const SizedBox(height: Space.s3),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Savings rate', style: context.text.titleMedium),
                Text('Share of income you kept each month.', style: context.text.bodySmall),
                const SizedBox(height: Space.s3),
                if (s.savingsRates.isEmpty)
                  Text(
                    'Appears after your first finished month.',
                    style: context.text.bodyMedium?.copyWith(color: c.ink3),
                  )
                else
                  for (final r in s.savingsRates) _RateRow(month: r.month, rate: r.rate),
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.s4),
        Row(
          children: [
            Icon(Symbols.lock_rounded, size: IconSizes.sm, color: c.ink3),
            const SizedBox(width: Space.s2),
            Expanded(
              child: Text(
                'Worked out on this phone. Nothing is sent anywhere.',
                style: context.text.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: Space.s3),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tiles[i]),
                const SizedBox(width: Space.s3),
                Expanded(child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value, required this.detail});

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Space.s4),
        child: Semantics(
          label: '$label: $value, $detail',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.text.bodySmall),
              const SizedBox(height: Space.s1),
              Text(value, style: context.moneyText.moneyM),
              const SizedBox(height: Space.s1),
              Text(detail, style: context.text.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// One month's savings rate as a bar from zero; negative months (spent more
/// than earned) show an empty bar and a minus value, never a red alarm.
class _RateRow extends StatelessWidget {
  const _RateRow({required this.month, required this.rate});

  final String month;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pct = (rate * 100).round();
    return Semantics(
      label: '$month: $pct percent',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.s1),
        child: Row(
          children: [
            SizedBox(width: 48, child: Text(month, style: context.text.bodyMedium)),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Radii.full),
                child: LinearProgressIndicator(
                  value: rate.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: c.surfaceSunken,
                  color: c.success,
                ),
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                pct < 0 ? '−${pct.abs()}%' : '$pct%',
                textAlign: TextAlign.end,
                style: context.text.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
