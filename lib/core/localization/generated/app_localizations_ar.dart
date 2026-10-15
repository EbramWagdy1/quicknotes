// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'الملاحظات السريعة';

  @override
  String get myNotes => 'ملاحظاتي';

  @override
  String activeNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاحظة نشطة',
      many: '$count ملاحظة نشطة',
      few: '$count ملاحظات نشطة',
      two: 'ملاحظتان نشطتان',
      one: 'ملاحظة واحدة نشطة',
      zero: 'لا توجد ملاحظات نشطة',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'ابحث في الملاحظات بالعنوان أو المحتوى...';

  @override
  String get pinnedSection => 'المثبتة';

  @override
  String get allNotesSection => 'كل الملاحظات';

  @override
  String get newNote => 'ملاحظة جديدة';

  @override
  String get favoritesOnly => 'المفضلة فقط';

  @override
  String get showAllNotes => 'عرض كل الملاحظات';

  @override
  String get notesMap => 'خريطة الملاحظات';

  @override
  String get calendar => 'التقويم';

  @override
  String get productivityInsights => 'إحصائيات الإنتاجية';

  @override
  String get deleteAllNotes => 'حذف جميع الملاحظات';

  @override
  String get deleteAllNotesTitle => 'حذف جميع الملاحظات؟';

  @override
  String get deleteAllNotesMessage =>
      'سيؤدي هذا إلى حذف جميع ملاحظاتك نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get deleteNote => 'حذف الملاحظة';

  @override
  String get undo => 'تراجع';

  @override
  String get noteDeleted => 'تم حذف الملاحظة';

  @override
  String noteTitleDeleted(String title) {
    return 'تم حذف ملاحظة \"$title\"';
  }

  @override
  String get allNotesDeleted => 'تم حذف جميع الملاحظات';

  @override
  String get emptyNotesTitle => 'لا توجد ملاحظات بعد';

  @override
  String get emptyNotesSubtitle =>
      'سجّل أفكارك، ومهامك اليومية، والملاحظات الصوتية في أي وقت';

  @override
  String get createFirstNote => 'إنشاء أول ملاحظة';

  @override
  String get noSearchResults => 'لم يتم العثور على ملاحظات';

  @override
  String noSearchResultsSubtitle(String query) {
    return 'لا توجد ملاحظات تطابق \"$query\". جرب كلمة مفتاحية أخرى.';
  }

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get summarizeWithAi => 'تلخيص بالذكاء الاصطناعي';

  @override
  String get shareNote => 'مشاركة الملاحظة';

  @override
  String get addToFavorites => 'إضافة إلى المفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get pinNote => 'تثبيت في الأعلى';

  @override
  String get unpinNote => 'إلغاء التثبيت';

  @override
  String get cancelReminder => 'إلغاء التذكير';

  @override
  String get switchToLightMode => 'التبديل إلى الوضع النهاري';

  @override
  String get switchToDarkMode => 'التبديل إلى الوضع الليلي';

  @override
  String get switchLanguage => 'تغيير اللغة';

  @override
  String get textNote => 'ملاحظة نصية';

  @override
  String get checklist => 'قائمة مهام';

  @override
  String get noteTitleHint => 'عنوان الملاحظة';

  @override
  String get noteBodyHint => 'ابدأ بكتابة ملاحظتك هنا...';

  @override
  String get save => 'حفظ';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get addNote => 'ملاحظة جديدة';

  @override
  String get lockNote => 'قفل الملاحظة';

  @override
  String get unlockNote => 'إلغاء قفل الملاحظة';

  @override
  String get reminder => 'تذكير';

  @override
  String get location => 'الموقع';

  @override
  String get tags => 'الوسوم';

  @override
  String get addTag => 'إضافة وسم';

  @override
  String get subtasks => 'المهام';

  @override
  String get addSubtask => 'إضافة مهمة';

  @override
  String get speechToText => 'الملاحظات الصوتية';

  @override
  String get voiceLanguage => 'لغة الصوت';

  @override
  String get authRequiredLocked => 'يلزم التحقق لفتح الملاحظة المقفلة';

  @override
  String get authRequiredDeleteLocked => 'يلزم التحقق لحذف الملاحظة المقفلة';

  @override
  String get locked => 'مقفل';

  @override
  String get lockedContentPlaceholder => 'محتوى مقفل • يلزم التحقق للعرض';

  @override
  String get viewMap => 'عرض الخريطة';

  @override
  String get tag => 'وسم';

  @override
  String get aiTags => 'وسوم ذكية';

  @override
  String get checklistAndSubtasks => 'قائمة المهام والمهام الفرعية';

  @override
  String get addSubtaskHint => 'إضافة مهمة فرعية...';

  @override
  String get productivitySubtitle => 'نظرة عامة على ملاحظاتك، مهامك، والوسوم';

  @override
  String get tasksCompletion => 'إنجاز المهام';

  @override
  String get noChecklistTasksYet => 'لم تتم إضافة مهام فرعية بعد';

  @override
  String get activeNotes => 'ملاحظات نشطة';

  @override
  String get reminders => 'التذكيرات';

  @override
  String get favoritesAndPinned => 'المفضلة / المثبتة';

  @override
  String get inTrash => 'في المهملات';

  @override
  String get topTags => 'أبرز الوسوم';

  @override
  String get trash => 'سلة المهملات';

  @override
  String get emptyTrash => 'إفراغ المهملات';

  @override
  String get trashIsEmpty => 'سلة المهملات فارغة';

  @override
  String get trashEmptySubtitle =>
      'الملاحظات المحذوفة ستظل هنا حتى تقوم باستعادتها أو حذفها نهائياً.';

  @override
  String get restore => 'استعادة';

  @override
  String get deleteForever => 'حذف نهائي';

  @override
  String get notesCalendar => 'تقويم الملاحظات';

  @override
  String get today => 'اليوم';

  @override
  String get remindersOnly => 'التذكيرات فقط';

  @override
  String get all => 'الكل';

  @override
  String get alarmClock => 'المنبه';

  @override
  String get inProgress => 'جاري العمل';

  @override
  String get postpone => 'أجّل';

  @override
  String get dismissAlarm => 'إيقاف';

  @override
  String get snooze10Min => 'تأجيل 10 دقائق';

  @override
  String snoozedSuccessfully(String time) {
    return 'تم تأجيل المنبه إلى $time';
  }
}
