// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Quick Notes';

  @override
  String get myNotes => 'My Notes';

  @override
  String activeNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active notes',
      one: '1 active note',
      zero: 'No active notes',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Search notes by title or content...';

  @override
  String get pinnedSection => 'PINNED';

  @override
  String get allNotesSection => 'ALL NOTES';

  @override
  String get newNote => 'New Note';

  @override
  String get favoritesOnly => 'Favorites only';

  @override
  String get showAllNotes => 'Show all notes';

  @override
  String get notesMap => 'Notes Map';

  @override
  String get calendar => 'Calendar';

  @override
  String get productivityInsights => 'Productivity & Insights';

  @override
  String get deleteAllNotes => 'Delete all notes';

  @override
  String get deleteAllNotesTitle => 'Delete All Notes?';

  @override
  String get deleteAllNotesMessage =>
      'This will permanently delete all your notes. This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get undo => 'Undo';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String noteTitleDeleted(String title) {
    return 'Note \"$title\" deleted';
  }

  @override
  String get allNotesDeleted => 'All notes deleted';

  @override
  String get emptyNotesTitle => 'No notes yet';

  @override
  String get emptyNotesSubtitle =>
      'Capture your thoughts, ideas, checklists and voice notes anytime';

  @override
  String get createFirstNote => 'Create First Note';

  @override
  String get noSearchResults => 'No notes found';

  @override
  String noSearchResultsSubtitle(String query) {
    return 'No notes match \"$query\". Try a different keyword.';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String get summarizeWithAi => 'Summarize with AI';

  @override
  String get shareNote => 'Share Note';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get pinNote => 'Pin Note to Top';

  @override
  String get unpinNote => 'Unpin Note';

  @override
  String get cancelReminder => 'Cancel Reminder';

  @override
  String get switchToLightMode => 'Switch to light mode';

  @override
  String get switchToDarkMode => 'Switch to dark mode';

  @override
  String get switchLanguage => 'Switch Language';

  @override
  String get textNote => 'Text Note';

  @override
  String get checklist => 'Tasks Checklist';

  @override
  String get noteTitleHint => 'Title';

  @override
  String get noteBodyHint => 'Write your note...';

  @override
  String get save => 'Save';

  @override
  String get editNote => 'Edit Note';

  @override
  String get addNote => 'New Note';

  @override
  String get lockNote => 'Lock Note';

  @override
  String get unlockNote => 'Unlock Note';

  @override
  String get reminder => 'Reminder';

  @override
  String get location => 'Location';

  @override
  String get tags => 'Tags';

  @override
  String get addTag => 'Add tag';

  @override
  String get subtasks => 'Tasks';

  @override
  String get addSubtask => 'Add task';

  @override
  String get speechToText => 'Voice Notes';

  @override
  String get voiceLanguage => 'Voice Language';

  @override
  String get authRequiredLocked =>
      'Authentication required to view locked note';

  @override
  String get authRequiredDeleteLocked =>
      'Authentication required to delete locked note';

  @override
  String get locked => 'Locked';

  @override
  String get lockedContentPlaceholder =>
      'Locked content • Authenticate to view';

  @override
  String get viewMap => 'View Map';

  @override
  String get tag => 'Tag';

  @override
  String get aiTags => 'AI Tags';

  @override
  String get checklistAndSubtasks => 'Checklist & Sub-tasks';

  @override
  String get addSubtaskHint => 'Add a sub-task...';

  @override
  String get productivitySubtitle => 'Overview of your notes, tasks, and tags';

  @override
  String get tasksCompletion => 'Tasks Completion';

  @override
  String get noChecklistTasksYet => 'No checklist tasks added yet';

  @override
  String get activeNotes => 'Active Notes';

  @override
  String get reminders => 'Reminders';

  @override
  String get favoritesAndPinned => 'Favorites / Pinned';

  @override
  String get inTrash => 'In Trash';

  @override
  String get topTags => 'Top Tags';

  @override
  String get trash => 'Trash';

  @override
  String get emptyTrash => 'Empty Trash';

  @override
  String get trashIsEmpty => 'Trash is Empty';

  @override
  String get trashEmptySubtitle =>
      'Deleted notes will stay here until you restore or permanently delete them.';

  @override
  String get restore => 'Restore';

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String get notesCalendar => 'Notes Calendar';

  @override
  String get today => 'Today';

  @override
  String get remindersOnly => 'Reminders Only';

  @override
  String get all => 'All';

  @override
  String get alarmClock => 'Alarm Clock';

  @override
  String get inProgress => 'In Progress';

  @override
  String get postpone => 'Postpone';

  @override
  String get dismissAlarm => 'Dismiss';

  @override
  String get snooze10Min => 'Snooze 10m';

  @override
  String snoozedSuccessfully(String time) {
    return 'Alarm postponed to $time';
  }
}
