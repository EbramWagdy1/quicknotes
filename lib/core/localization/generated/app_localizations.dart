import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Quick Notes'**
  String get appName;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get myNotes;

  /// Number of active notes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active notes} =1{1 active note} other{{count} active notes}}'**
  String activeNotesCount(int count);

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search notes by title or content...'**
  String get searchPlaceholder;

  /// No description provided for @pinnedSection.
  ///
  /// In en, this message translates to:
  /// **'PINNED'**
  String get pinnedSection;

  /// No description provided for @allNotesSection.
  ///
  /// In en, this message translates to:
  /// **'ALL NOTES'**
  String get allNotesSection;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @favoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorites only'**
  String get favoritesOnly;

  /// No description provided for @showAllNotes.
  ///
  /// In en, this message translates to:
  /// **'Show all notes'**
  String get showAllNotes;

  /// No description provided for @notesMap.
  ///
  /// In en, this message translates to:
  /// **'Notes Map'**
  String get notesMap;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @productivityInsights.
  ///
  /// In en, this message translates to:
  /// **'Productivity & Insights'**
  String get productivityInsights;

  /// No description provided for @deleteAllNotes.
  ///
  /// In en, this message translates to:
  /// **'Delete all notes'**
  String get deleteAllNotes;

  /// No description provided for @deleteAllNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Notes?'**
  String get deleteAllNotesTitle;

  /// No description provided for @deleteAllNotesMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your notes. This action cannot be undone.'**
  String get deleteAllNotesMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// Message when a titled note is deleted
  ///
  /// In en, this message translates to:
  /// **'Note \"{title}\" deleted'**
  String noteTitleDeleted(String title);

  /// No description provided for @allNotesDeleted.
  ///
  /// In en, this message translates to:
  /// **'All notes deleted'**
  String get allNotesDeleted;

  /// No description provided for @emptyNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get emptyNotesTitle;

  /// No description provided for @emptyNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture your thoughts, ideas, checklists and voice notes anytime'**
  String get emptyNotesSubtitle;

  /// No description provided for @createFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Create First Note'**
  String get createFirstNote;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No notes found'**
  String get noSearchResults;

  /// Message when search finds no matches
  ///
  /// In en, this message translates to:
  /// **'No notes match \"{query}\". Try a different keyword.'**
  String noSearchResultsSubtitle(String query);

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @summarizeWithAi.
  ///
  /// In en, this message translates to:
  /// **'Summarize with AI'**
  String get summarizeWithAi;

  /// No description provided for @shareNote.
  ///
  /// In en, this message translates to:
  /// **'Share Note'**
  String get shareNote;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @pinNote.
  ///
  /// In en, this message translates to:
  /// **'Pin Note to Top'**
  String get pinNote;

  /// No description provided for @unpinNote.
  ///
  /// In en, this message translates to:
  /// **'Unpin Note'**
  String get unpinNote;

  /// No description provided for @cancelReminder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Reminder'**
  String get cancelReminder;

  /// No description provided for @switchToLightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get switchToLightMode;

  /// No description provided for @switchToDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get switchToDarkMode;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  /// No description provided for @textNote.
  ///
  /// In en, this message translates to:
  /// **'Text Note'**
  String get textNote;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Tasks Checklist'**
  String get checklist;

  /// No description provided for @noteTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitleHint;

  /// No description provided for @noteBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your note...'**
  String get noteBodyHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get addNote;

  /// No description provided for @lockNote.
  ///
  /// In en, this message translates to:
  /// **'Lock Note'**
  String get lockNote;

  /// No description provided for @unlockNote.
  ///
  /// In en, this message translates to:
  /// **'Unlock Note'**
  String get unlockNote;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @subtasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get subtasks;

  /// No description provided for @addSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addSubtask;

  /// No description provided for @speechToText.
  ///
  /// In en, this message translates to:
  /// **'Voice Notes'**
  String get speechToText;

  /// No description provided for @voiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Voice Language'**
  String get voiceLanguage;

  /// No description provided for @authRequiredLocked.
  ///
  /// In en, this message translates to:
  /// **'Authentication required to view locked note'**
  String get authRequiredLocked;

  /// No description provided for @authRequiredDeleteLocked.
  ///
  /// In en, this message translates to:
  /// **'Authentication required to delete locked note'**
  String get authRequiredDeleteLocked;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @lockedContentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Locked content • Authenticate to view'**
  String get lockedContentPlaceholder;

  /// No description provided for @viewMap.
  ///
  /// In en, this message translates to:
  /// **'View Map'**
  String get viewMap;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @aiTags.
  ///
  /// In en, this message translates to:
  /// **'AI Tags'**
  String get aiTags;

  /// No description provided for @checklistAndSubtasks.
  ///
  /// In en, this message translates to:
  /// **'Checklist & Sub-tasks'**
  String get checklistAndSubtasks;

  /// No description provided for @addSubtaskHint.
  ///
  /// In en, this message translates to:
  /// **'Add a sub-task...'**
  String get addSubtaskHint;

  /// No description provided for @productivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview of your notes, tasks, and tags'**
  String get productivitySubtitle;

  /// No description provided for @tasksCompletion.
  ///
  /// In en, this message translates to:
  /// **'Tasks Completion'**
  String get tasksCompletion;

  /// No description provided for @noChecklistTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No checklist tasks added yet'**
  String get noChecklistTasksYet;

  /// No description provided for @activeNotes.
  ///
  /// In en, this message translates to:
  /// **'Active Notes'**
  String get activeNotes;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @favoritesAndPinned.
  ///
  /// In en, this message translates to:
  /// **'Favorites / Pinned'**
  String get favoritesAndPinned;

  /// No description provided for @inTrash.
  ///
  /// In en, this message translates to:
  /// **'In Trash'**
  String get inTrash;

  /// No description provided for @topTags.
  ///
  /// In en, this message translates to:
  /// **'Top Tags'**
  String get topTags;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get emptyTrash;

  /// No description provided for @trashIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is Empty'**
  String get trashIsEmpty;

  /// No description provided for @trashEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted notes will stay here until you restore or permanently delete them.'**
  String get trashEmptySubtitle;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForever;

  /// No description provided for @notesCalendar.
  ///
  /// In en, this message translates to:
  /// **'Notes Calendar'**
  String get notesCalendar;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @remindersOnly.
  ///
  /// In en, this message translates to:
  /// **'Reminders Only'**
  String get remindersOnly;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @alarmClock.
  ///
  /// In en, this message translates to:
  /// **'Alarm Clock'**
  String get alarmClock;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @postpone.
  ///
  /// In en, this message translates to:
  /// **'Postpone'**
  String get postpone;

  /// No description provided for @dismissAlarm.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissAlarm;

  /// No description provided for @snooze10Min.
  ///
  /// In en, this message translates to:
  /// **'Snooze 10m'**
  String get snooze10Min;

  /// Feedback message when alarm is snoozed
  ///
  /// In en, this message translates to:
  /// **'Alarm postponed to {time}'**
  String snoozedSuccessfully(String time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
