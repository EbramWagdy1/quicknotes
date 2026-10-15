# QuickNotes — Master Feature Roadmap & Competitive Strategy

---

## 1. Status Audit (ما تم تنفيذه بالفعل vs ما هو مطلوب)

| الفئة (Category) | الميزة (Feature) | الحالة الحالية | التفاصيل المعمارية في الكود |
| :--- | :--- | :---: | :--- |
| **Core** | 📝 Create Note | ✅ **تم إنجازه** | [NoteFormScreen](file:///d:/quicknotes/lib/features/home/view/note_form_screen.dart) يدعم Text Note و Checklist بشكل تبادلي بتصميم عصري |
| | ✏️ Edit Note | ✅ **تم إنجازه** | تعديل متكامل مع حفظ لحظي وتحديث تلقائي |
| | 🗑️ Delete Note | ✅ **تم إنجازه** | مع تأكيد وحماية بالمصادقة للنوتات المقفولة وسلة مهملات Soft Delete ومهلة تراجع 10 ثوانٍ |
| | 📋 View All Notes | ✅ **تم إنجازه** | [HomeView](file:///d:/quicknotes/lib/features/home/view/home_view.dart) بتصميم Paper Slate هادئ وخالٍ من التشتيت |
| | 🔍 Search Notes | ✅ **تم إنجازه** | بحث فوري عبر العنوان، المحتوى، والتاسكات الفرعية، مع دعم البحث الدلالي |
| | 📌 Pin Notes | ✅ **تم إنجازه** | عمود `is_pinned` في DB (Floor v3)، فصل بصري "PINNED" ومؤشرات أنيقة |
| | 🏷️ Tags & Categories | ✅ **تم إنجازه** | `tags_json` في DB، محدد التاجات [tags_selector.dart](file:///d:/quicknotes/lib/features/home/view/widgets/tags_selector.dart)، وفلترة سريعة بالتاجات |
| | ⭐ Favorite Notes | ✅ **تم إنجازه** | عمود `is_favorite` في DB، بادج النجمة، وفلتر سريع بالمفضلة في [home_app_bar.dart](file:///d:/quicknotes/lib/features/home/view/widgets/home_app_bar.dart) |
| **Smart Features** | 🧠 AI Note Summarization | ✅ **تم إنجازه** | تكامل فوري مع Google Gemini 2.5 Flash عبر [gemini_service.dart](file:///d:/quicknotes/lib/core/services/gemini_service.dart) وويدجت [ai_summary_sheet.dart](file:///d:/quicknotes/lib/features/home/view/widgets/ai_summary_sheet.dart) مع دعم النسخ، الإلحاق، والاستبدال |
| | 🤖 Auto Categorization | ✅ **تم إنجازه** | تصنيف تلقائي ذكي وتوليد التاجات والتصنيفات بدقة عبر [gemini_service.dart](file:///d:/quicknotes/lib/core/services/gemini_service.dart) |
| | ✨ Smart Tag Suggestions | ✅ **تم إنجازه** | زر تفاعلي وقائمة ذكية تقترح تاجات مخصصة فورية حسب محتوى النوتة والعنوان |
| | ✅ Convert Note → Task | ✅ **تم إنجازه** | تحويل فوري للنوتة واستخراج المهام التنفيذية إلى قائمة تشيك ليست تفاعلية |
| | 🎯 Detect Tasks & Deadlines | ✅ **تم إنجازه** | استخراج ذكي للمواعيد والتواريخ المحددة (مثل "بكرة الساعة 5") وتضمينها في عناوين المهام |
| | 🔎 Natural Language Search | ✅ **تم إنجازه** | زر تبديل `AI` في شريط البحث [search_header.dart](file:///d:/quicknotes/lib/features/home/view/widgets/search_header.dart) للبحث الدلالي (Semantic Search) بالمعنى والسياق |
| | 📸 OCR (Image → Note) | ✅ **تم إنجازه** | دعم ثنائي متقدم للغتين **العربية والإنجليزية** مع الحفاظ على النص الأصلي دون ترجمة قسرية، استخراج نصوص وقوائم مهام فورية عبر الكاميرا والمعرض |
| | 🎙️ Voice → Note | ✅ **تم إنجازه** | إملاء صوتي دقيق مع محدد تبديل اللغات السريع (**عربي / EN**) في شريط الأدوات، معالجة أذونات الميكروفون بمرونة وشريط نبضي حي |
| **Design & UX** | 🎨 Sky Blue Modern Theme | ✅ **تم إنجازه** | استبدال درجات الموف بألوان **Sky Blue** الحيوية (`#0284C7`)، كروت أنيقة بدون ازدحام، وشريط أدوات ذكي موحد |
| | 🌙 Dark / Light Mode | ✅ **تم إنجازه** | نظام متكامل للثيمين الداكن والفاتح مع التوافق التلقائي مع النظام أو التبديل اليدوي السريع عبر [ThemeCubit](file:///d:/quicknotes/lib/core/theme/theme_cubit.dart) و [AppTheme](file:///d:/quicknotes/lib/core/theme/app_theme.dart) معايير WCAG AA |
| | 🎬 Animated Splash Screen | ✅ **تم إنجازه** | شاشة بداية تفاعلية سلسة بحركات ارتدادية للوجو (`Scale` + `Fade`) وانزلاق العنوان (`Slide` + `Fade`) مع ثبات تام للألوان الأصلية |
| **Context-Aware** | 📍 Location-based Notes | ✅ **تم إنجازه** | `Geolocator` يحفظ الإحداثيات مع النوتة بالخلفية بشكل متفائل مع شارة موقع بالمحرر |
| | 🗺️ Show Notes on Map | ✅ **تم إنجازه** | شاشة خريطة تفاعلية [notes_map_view.dart](file:///d:/quicknotes/lib/features/home/view/notes_map_view.dart) مدعومة بـ `flutter_map` و `latlong2` مع دبابيس وكروت معاينة |
| | ⏰ Time-based Reminders | ✅ **تم إنجازه** | منبهات وتذكيرات زمنية للنوتات والمواعيد عبر Floor v4، `NotificationService` و `flutter_local_notifications` مع منتقي تاريخ ووقت وبادج تفاعلي |
| | 📅 Calendar Integration | ✅ **تم إنجازه** | تقويم تفاعلي شهري [calendar_view.dart](file:///d:/quicknotes/lib/features/calendar/view/calendar_view.dart) يعرض دلالات النوتات والتذكيرات وفلترة التذكيرات واستعراض وإضافة نوتات لليوم المحدد |
| | 📍 Location Proximity Alerts | ✅ **تم إنجازه** | حساب المسافة الجيوديسية وفلترة النوتات القريبة عبر [LocationService](file:///d:/quicknotes/lib/core/services/location_service.dart) وتنبيه لحظي عند الاقتراب ضمن نطاق 500 متر |
| | 📅 Date & Time Context | ✅ **تم إنجازه** | توثيق زمني دقيق `createdAt` و `updatedAt` بصيغة مقروءة وواضحة |
| **Productivity** | ✅ Task Status: Todo/Done | ✅ **تم إنجازه** | إنجاز فوري للتاسك مباشرة من كارت النوتة في [note_card.dart](file:///d:/quicknotes/lib/features/home/view/widgets/note_card.dart) بنقرة واحدة |
| | ⏱️ Extended Undo Window | ✅ **تم إنجازه** | شريط تراجع (Undo SnackBar) لمدة 10 ثوانٍ كاملة عند نقل أي ملاحظة لسلة المهملات |
| | 📊 Productivity Statistics | ✅ **تم إنجازه** | لوحة إحصائيات بصرية [ProductivityStatsSheet](file:///d:/quicknotes/lib/features/stats/view/productivity_stats_sheet.dart) توضح نسبة إنجاز المهام، وكروت المؤشرات وتوزيع التاجات |
| | 📤 Export to Markdown & Text | ✅ **تم إنجازه** | تصدير النوتات بتنسيق Markdown أنيق أو نص خام عبر [NoteExportHelper](file:///d:/quicknotes/lib/core/utils/note_export_helper.dart) |
| | 🔗 Share Notes | ✅ **تم إنجازه** | مشاركة فورية للملاحظات والتاسكات عبر `share_plus` من كارت النوتة أو شاشة المحرر |
| | 🔄 Recurring Reminders | ⏳ **مطلوب** | تكرار التنبيهات يومياً/أسبوعياً عبر جدولة محلية |
| | 🕐 Note Versioning | ⏳ **مطلوب** | جدول `note_history` لتتبع سجل التعديلات السابقة |
| **Advanced** | 🔐 Biometrics / App Lock | ✅ **تم إنجازه** | حماية بالبصمة والـ PIN لكل نوتة مقفولة عبر [biometric_service.dart](file:///d:/quicknotes/lib/core/services/biometric_service.dart) |
| | 🗑️ Trash & Restore (Soft Delete) | ✅ **تم إنجازه** | سلة المهملات [trash_view.dart](file:///d:/quicknotes/lib/features/trash/view/trash_view.dart) مع Undo SnackBar واسترجاع وحذف نهائي |
| | 📱 Offline-first | ✅ **تم إنجازه** | Floor SQLite يعمل بنسبة 100% محلياً مع ترحيل آمن (Floor v4) |
| | 🌍 Arabic / English | ⏳ **مطلوب** | تعريب شامل للواجهة ودعم اتجاه RTL عبر `flutter_localizations` |
| | ☁️ Cloud Backup & Sync | ⏳ **مطلوب** | مزامنة سحابية اختيارية عبر Supabase أو Firebase |
| **Unique Ideas** | 🔥 Shake to Clean | ✅ **تم إنجازه** | هز الهاتف لحذف النوتات مع حماية النوتات المقفولة |
| | 🎯 Note → Action | ✅ **تم إنجازه** | تحويل الملاحظة لقائمة إجراءات تنفيذية فورية بضغطة زر عبر الذكاء الاصطناعي |
| | ⚡ Quick Capture Mode | ⏳ **مطلوب** | نافذة عائمة أو اختصار سريع للتدوين الفوري |
| | 💡 Idea Mode | ⏳ **مطلوب** | وضع التدوين الحر بدون أي مشتتات بصرية |

---

## 2. تفاصيل التحديثات الأخيرة (Recent Architecture & Design Upgrades)

### أ. نظام التصميم الذكي والثيم المزدوج (UI/UX Pro Max Dark / Light Mode):
- **بنية التنسيق المركزية ([AppTheme](file:///d:/quicknotes/lib/core/theme/app_theme.dart))**:
  - لوحة ألوان Dark Mode مهندسة بعناية فائقة مع نسبة تباين تتجاوز معايير WCAG AA (Slate 900 `#0F172A` للخلفية، Slate 800 `#1E293B` للأسطح، و Slate 50 `#F8FAFC` للنصوص الأساسية).
  - لوحة ألوان Light Mode بألوان Sky Blue الاحترافية (`#0284C7`) مع خلفيات بيضاء ثلجية مريحة للعين.
  - إضافة `ThemeContextExtension` على `BuildContext` لتوفير رموز التصميم الموحدة (`context.surfaceColor`, `context.textPrimary`, `context.borderColor`, `context.chipBackground`) بشكل مباشر وفعال عبر كل الشاشات.
- **إدارة الحالة والتخزين الدائم ([ThemeCubit](file:///d:/quicknotes/lib/core/theme/theme_cubit.dart))**:
  - حفظ خيار الثيم في `SharedPreferences` مع دعم 3 أوضاع: `system`, `light`, `dark`.
  - زر تبديل سريع في [HomeAppBar](file:///d:/quicknotes/lib/features/home/view/widgets/home_app_bar.dart) مع اختبارات تفاعلية مؤكدة.

### ب. لوحة إحصائيات الإنتاجية المتقدمة ([ProductivityStatsSheet](file:///d:/quicknotes/lib/features/stats/view/productivity_stats_sheet.dart)):
- **محرك الحسابات الإحصائية ([NoteStatsHelper](file:///d:/quicknotes/lib/core/utils/note_stats_helper.dart))**:
  - حساب نسبة إنجاز المهام الكلية (`taskCompletionPercentage`).
  - رصد دقيق لعدد الملاحظات النشطة، التذكيرات المجدولة، الملاحظات المثبتة، المفضلة، وسلة المهملات.
  - فرز وتجميع أكثر التاجات استخداماً (Top Tags Distribution).
- **واجهة بصرية تفاعلية**:
  - شيت سفلي حديث يعرض شريط تقدم خطي بلون Sky Blue لإنجاز المهام.
  - شبكة 2x2 لكروت المؤشرات مع أيقونات ملونة وتصميم متجاوب للثيمين الفاتح والداكن.

### ج. محرك التصدير والمشاركة الذكية ([NoteExportHelper](file:///d:/quicknotes/lib/core/utils/note_export_helper.dart)):
- تحويل الملاحظة لصيغة Markdown منسقة مع التشيك ليست وروابط الموقع والتاريخ.
- تحويل الملاحظة لنص خام مهندم للعرض المباشر.
- تكامل مباشر مع `SharePlus.instance.share(ShareParams(...))` للمشاركة عبر كل تطبيقات المراسلة والنظام.
- أزرار مشاركة سريعة في كارت الملاحظة ومحرر الملاحظات.

### د. التنبيهات الجغرافية والاقتراب المكاني (Proximity Alerts & Geofencing):
- **بنية الحساب المكاني ([LocationService](file:///d:/quicknotes/lib/core/services/location_service.dart))**:
  - دالة `calculateDistance` لحساب المسافة الجيوديسية بين إحداثيات المستخدم والنوتة.
  - دالة `getNearbyNotes` لفلترة النوتات الواقعة ضمن نطاق جغرافي محدد (افتراضياً 500 متر) وترتيبها من الأقرب للأبعد.
- **تكامل الواجهة والتنبيهات**:
  - تنبيه فوري استباقي في [NotesMapView](file:///d:/quicknotes/lib/features/home/view/notes_map_view.dart) بشريط SnackBar يعرض اسم النوتة القريبة وبعدها بالأمتار أو الكيلومترات مع زر "View" للانتقال السريع لها.
  - دالة `showProximityNotification` في [NotificationService](file:///d:/quicknotes/lib/core/services/notification_service.dart) لإطلاق إشعار للنوتات القريبة.

---

## 3. خطة التنفيذ المحدثة عبر المراحل (Execution Roadmap)

### ✅ المرحلة الأولى: التنظيم ودورة حياة الملاحظة (Organization & Lifecycle) — **100% مكتمل**
- [x] **📌 Pin Notes**: تثبيت النوتات بالأعلى مع فرز تلقائي في SQL وقسم خاص "PINNED".
- [x] **⭐ Favorite Notes**: تمييز النوتات المفضلة وفلتر سريع بالمفضلة في شريط التطبيق.
- [x] **🏷️ Tags & Categories**: محدد التاجات (`TagsSelector`) مع تاجات مقترحة وتخصيص كامل وفلترة سريعة.
- [x] **🗑️ Soft Delete & Trash**: سلة مهملات متكاملة (`TrashView`)، استرجاع فوري، مهلة تراجع Undo ممتدة (10s)، وحذف نهائي.
- [x] **🛡️ Safe Database Migration**: ترحيل آمن للـ SQLite من Floor v2 إلى v3 مدعوم باختبارات مؤكدة.

---

### ✅ المرحلة الثانية: المحرك التفاعلي والمكاني (Context-Aware Engine) — **100% مكتمل**
- [x] **🗺️ Show Notes on Map**: شاشة خريطة تفاعلية متكاملة باستخدام `flutter_map` و `latlong2` تعرض دبابيس النوتات جغرافياً وكروت المعاينة.
- [x] **⏰ Time-based Reminders**: منبهات وتذكيرات زمنية للملاحظات والمهام (Floor v4 Migration، `NotificationService` وجدولة محلية دقيقة، محدد التاريخ والوقت في المحرر، كروت الملاحظات والخريطة).
- [x] **📅 Calendar View**: تقويم تفاعلي شهري للملاحظات والمهام (`CalendarView` مع التنقل بين الأشهر، شارة اليوم، فلترة التذكيرات، عرض كروت الملاحظات وإضافتها).
- [x] **📍 Location-based Reminders & Proximity**: تنبيهات جغرافية واكتشاف النوتات القريبة ضمن 500 متر مع إشعارات وبانر تفاعلي.

---

### ✅ المرحلة الثالثة: الذكاء الاصطناعي والإدخال متعدد الوسائط (Smart AI & Multimodal Input) — **100% مكتمل**
- [x] **🧠 AI Note Summarization**: تلخيص فوري للملاحظات الطويلة بضغطة زر مدعوماً بـ Gemini 2.5 Flash مع خيارات النسخ والإلحاق والاستبدال.
- [x] **🤖 Auto Categorization & Smart Tags**: تصنيف تلقائي للمحتوى واقتراح تاجات مخصصة للعنوان والنص.
- [x] **🎯 Convert Note → Tasks & Deadlines**: استخراج المهام التنفيذية والمواعيد المجدولة وتحويلها لقائمة Checklist تفاعلية.
- [x] **🔎 Semantic Natural Language Search**: بحث ذكي بالمعنى والسياق الدلالي وليس بالكلمات المجردة فقط.
- [x] **📸 Multimodal OCR (Image/Camera → Note)**: استخراج النصوص والمهام بالعربية والإنجليزية بدقة عبر الذكاء الاصطناعي.
- [x] **🎙️ Voice Dictation (Speech → Text)**: إملاء صوتي فوري مباشر مع دعم التبديل بين اللغتين (عربي / EN).
- [x] **🎬 Animated Splash**: شاشة بداية متحركة بدقة وبدون تغيير ألوان.

---

### 🚀 المرحلة الرابعة: الإنتاجية والمزامنة السحابية (Productivity, Export & Cloud Sync)
- [x] **🌙 Dark / Light Mode**: دعم كامل للثيم الداكن والفاتح ومطابقة إعدادات النظام مع الحفاظ على جمالية Sky Blue ومعايير WCAG AA.
- [x] **📤 Export & Share**: تصدير النوتات كملفات Markdown أنيقة ومشاركتها عبر التطبيقات (`share_plus`).
- [x] **📊 Productivity Statistics**: لوحة إحصائيات بصرية توضح معدل إنجاز المهام وتوزيع التاجات ومؤشرات النوتات.
- [ ] **🌍 Arabic / English Localization**: تعريب شامل للواجهة مع دعم اتجاه RTL عبر `flutter_localizations`.
- [ ] **☁️ Cloud Backup & Sync**: مزامنة اختيارية مشفرة عبر Supabase أو Firebase.
