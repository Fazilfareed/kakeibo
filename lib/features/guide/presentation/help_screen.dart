import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../app/theme/kakeibo_colors.dart';
import '../../../app/theme/kakeibo_text.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/widgets/empty_state.dart';

/// One bundled help article (FR-104, FR-105): `assets/help/*.md`.
class HelpArticle {
  const HelpArticle({required this.id, required this.title, required this.body});

  final String id;
  final String title;
  final String body;

  /// The first line after the title, for the list.
  String get summary {
    for (final line in body.split('\n').skip(1)) {
      final t = line.trim();
      if (t.isNotEmpty && !t.startsWith('#')) return t.replaceAll('**', '').replaceAll('*', '');
    }
    return '';
  }

  /// FR-105: a plain-text search across titles and bodies. Returns a short
  /// snippet around the first match, or null.
  String? match(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return summary;
    final plain = body.replaceAll(RegExp(r'[#*]'), '');
    final i = plain.toLowerCase().indexOf(q);
    if (i < 0) return null;
    final start = (i - 40).clamp(0, plain.length);
    final end = (i + q.length + 80).clamp(0, plain.length);
    return '${start > 0 ? '…' : ''}${plain.substring(start, end).replaceAll('\n', ' ').trim()}…';
  }
}

const _files = ['01-basics', '02-using-the-app', '03-faq', '04-backup', '05-privacy'];

final helpArticlesProvider = FutureProvider<List<HelpArticle>>((ref) async {
  return [
    for (final id in _files)
      await rootBundle.loadString('assets/help/$id.md').then((body) {
        final title = body.split('\n').first.replaceFirst(RegExp(r'^#\s*'), '').trim();
        return HelpArticle(id: id, title: title, body: body);
      }),
  ];
});

/// Settings → Help Center: offline, searchable articles.
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final articles = ref.watch(helpArticlesProvider).value ?? const <HelpArticle>[];
    final hits = [
      for (final a in articles)
        if (a.match(_query) case final snippet?) (a, snippet),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s3, Space.gutter, Space.s7),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Symbols.search_rounded),
              hintText: 'Search help, e.g. refund or PIN',
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: Space.s4),
          if (articles.isNotEmpty && hits.isEmpty)
            const EmptyState(
              icon: Symbols.search_off_rounded,
              title: 'Nothing found',
              message: 'Try another word, like "backup" or "pillar".',
            ),
          for (final (a, snippet) in hits) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Space.s4,
                  vertical: Space.s1,
                ),
                title: Text(a.title, style: context.text.titleMedium),
                subtitle: Text(snippet, maxLines: 3, overflow: TextOverflow.ellipsis),
                trailing: Icon(Symbols.chevron_right_rounded, color: c.ink3),
                onTap: () => context.push('/help/${a.id}', extra: _query),
              ),
            ),
            const SizedBox(height: Space.s2),
          ],
        ],
      ),
    );
  }
}

class HelpArticleScreen extends ConsumerWidget {
  const HelpArticleScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(helpArticlesProvider).value?.where((a) => a.id == id).firstOrNull;
    final t = context.text;
    return Scaffold(
      appBar: AppBar(title: Text(article?.title ?? '')),
      body: article == null
          ? const SizedBox.shrink()
          : Markdown(
              data: article.body.split('\n').skip(1).join('\n'),
              padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s2, Space.gutter, Space.s7),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: t.bodyLarge,
                listBullet: t.bodyLarge,
                h2: t.titleLarge,
                h2Padding: const EdgeInsets.only(top: Space.s5),
                h3: t.titleMedium,
                h3Padding: const EdgeInsets.only(top: Space.s3),
                blockSpacing: Space.s3,
              ),
            ),
    );
  }
}
