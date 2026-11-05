/// Per-guide flags in the settings table (PRD §6.10 technical notes).
abstract final class GuideKeys {
  static const tourDone = 'guide_tour_done';
  static const tipsEnabled = 'tips_enabled';
  static const checklistDismissed = 'checklist_dismissed';

  /// Coach marks shown once per screen (FR-99).
  static String coachSeen(CoachScreen s) => 'coach_${s.name}_seen';
}

/// Screens with first-visit coach marks.
enum CoachScreen { dashboard, quickAdd, transactions, plan, history }

/// The "Getting started" checklist (FR-97).
class Checklist {
  const Checklist({
    required this.planned,
    required this.logged,
    required this.reminders,
    required this.checkedIn,
    required this.backedUp,
  });

  final bool planned;
  final bool logged;
  final bool reminders;
  final bool checkedIn;
  final bool backedUp;

  List<bool> get items => [planned, logged, reminders, checkedIn, backedUp];
  int get done => items.where((x) => x).length;
  bool get complete => done == items.length;
}

extension GuideSettings on Map<String, String> {
  bool get tourDone => this[GuideKeys.tourDone] == 'true';
  bool get tipsOn => this[GuideKeys.tipsEnabled] != 'false';
  bool get checklistDismissed => this[GuideKeys.checklistDismissed] == 'true';
  bool coachSeen(CoachScreen s) => this[GuideKeys.coachSeen(s)] == 'true';

  /// Replay guide (FR-93): coach marks show again; the tour itself is
  /// replayed straight away. Never touches user data.
  Map<String, String> get guideReset => {
    for (final s in CoachScreen.values) GuideKeys.coachSeen(s): 'false',
  };
}
