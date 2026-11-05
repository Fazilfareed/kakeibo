import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

/// All guide text in one place, ready to move into localisation files
/// (FR-92). Nothing here is fetched from the network.
abstract final class GuideContent {
  static const tour = <TourCard>[
    TourCard(
      icon: Symbols.menu_book_rounded,
      title: 'What is Kakeibo?',
      body:
          'Kakeibo (kah-keh-boh) is a Japanese household account book from 1904. You write '
          'down what you spend, by hand, and stop to think about it. That small pause is what '
          'helps you save.',
    ),
    TourCard(
      icon: Symbols.help_rounded,
      title: 'Four questions',
      body:
          'How much money do I have? How much do I want to save? How much am I spending? '
          'How can I do better? The app asks them at the right moments: when you plan, log '
          'and reflect.',
    ),
    TourCard(
      icon: Symbols.grid_view_rounded,
      title: 'Four pillars',
      body:
          'Every spend goes in one pillar. Needs: food, bus, bills. Wants: eating out, '
          'shopping. Culture: books, a concert, a course. Unexpected: a repair, a doctor’s '
          'visit. Ask: do I need it, or do I want it?',
      pillars: true,
    ),
    TourCard(
      icon: Symbols.autorenew_rounded,
      title: 'Plan, log, reflect',
      body:
          'At the start of each month, plan your income, fixed costs and what you’ll save '
          'first. Log each spend in a few taps. At the end of the month, reflect and choose one '
          'thing to do better.',
    ),
    TourCard(
      icon: Symbols.lock_rounded,
      title: 'Your data stays here',
      body:
          'No account, no internet, no ads. Everything is on this phone, so make backups: the '
          'app can save one to a folder every week, and you can protect it with a PIN.',
    ),
  ];

  /// FR-100: "(?)" explanations, the formula in plain words.
  static const spendable = InfoText(
    title: 'Spendable',
    body:
        'Spendable is what you can spend this month after the things that come first.\n\n'
        'Spendable = income − fixed costs − savings goal\n\n'
        'For example: a salary of 150,000, rent of 40,000 and a goal of 20,000 leave 90,000 '
        'spendable.',
  );
  static const dailyAllowance = InfoText(
    title: 'A day keeps you on track',
    body:
        'What’s left to spend, shared out over the days left in the month, today '
        'included.\n\n'
        'Daily allowance = left to spend ÷ days left\n\n'
        'For example: 60,000 left with 20 days to go is 3,000 a day. Spend less today and '
        'tomorrow’s amount goes up.',
  );
  static const projection = InfoText(
    title: 'At this pace',
    body:
        'From day 4, the ring shows what you would save if you kept spending at the same '
        'pace until the month ends.\n\n'
        'Projected savings = income − fixed costs − (spent so far ÷ days so far '
        '× days in the month)\n\n'
        'One big spend early in the month can make it look worse than it is. If you go over '
        'budget, the ring shows how much of your goal is still safe instead.',
  );

  /// FR-101: tip of the day, rotating by date.
  static const tips = <String>[
    'Log a spend as soon as you make it. Waiting until evening is how cash spends get lost.',
    'Before you buy, ask: do I need it, or do I want it? The pillar is the answer.',
    'Save first. Move your savings goal out of your account at the start of the month.',
    'Tag a spend as Regret when it doesn’t feel worth it. Your reflection will show them all.',
    'Fixed costs are bills that don’t change. Logging them as spends would count them twice.',
    'A refund is logged against the pillar of the original spend, so it lowers that total.',
    'The daily allowance goes up on days you spend less. Small days add up.',
    'A Culture spend that made you happy is money well used. Keep a little room for it.',
    'Unexpected costs always come. A small Unexpected budget keeps them from wrecking the month.',
    'If you overspend, that’s okay. The app shows what it costs your savings, not a scolding.',
    'Your weekly check-in takes a minute. One thing to watch next week is enough.',
    'Pick one improvement each month, not five. One you keep beats five you forget.',
    'Use the note field for things you buy often. It suggests them next time.',
    'Paid in cash? Choose Cash as the payment method to see how much cash you really use.',
    'Swipe a spend left to delete it. There’s always an Undo.',
    'Tap a pillar bar on Home to see every spend in that pillar.',
    'Saving 10% of your income is a good start. Raise it once a month feels easy.',
    'A month you miss your goal still teaches you something. The reflection shows what.',
    'Turn on the weekly backup. If your phone is lost, a backup file is the only copy.',
    'If your salary comes on the 25th, start your Kakeibo month on the 25th in Settings.',
    'Shopping when tired or bored? Tag it, and see in your reflection how often it happens.',
    'Before a big Want, wait a day. If you still want it tomorrow, plan it in.',
    'Ask your family to tell you about shared spends, so the month is complete.',
    'Look at History every few months: the savings line shows how far you’ve come.',
    'Write in the reflection as if no one will read it. No one will: it stays on your phone.',
    'Many small Wants can cost more than one big Need. Your pillar bars make it visible.',
    'Subscriptions are fixed costs. Review them in your plan each month.',
    'A Kakeibo month is calm, not perfect. Logging most spends is already a win.',
    'Gifts for others usually belong in Culture or Wants. Pick one and stay consistent.',
    'My stats (in History) shows your logging streak. Try to keep it going.',
  ];

  static String tipFor(DateTime day) {
    final n = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ 86400000;
    return tips[n % tips.length];
  }
}

class TourCard {
  const TourCard({
    required this.icon,
    required this.title,
    required this.body,
    this.pillars = false,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Show the four pillar icons in the illustration.
  final bool pillars;
}

class InfoText {
  const InfoText({required this.title, required this.body});
  final String title;
  final String body;
}
