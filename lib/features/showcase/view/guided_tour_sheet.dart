import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';
import 'package:quicknotes/features/stats/view/productivity_stats_sheet.dart';

class _TourStep {
  final IconData icon;
  final Color color;
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;
  final String actionLabelEn;
  final String actionLabelAr;
  final void Function(BuildContext context) onAction;

  const _TourStep({
    required this.icon,
    required this.color,
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    required this.actionLabelEn,
    required this.actionLabelAr,
    required this.onAction,
  });
}

class GuidedTourSheet extends StatefulWidget {
  const GuidedTourSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const GuidedTourSheet(),
    );
  }

  @override
  State<GuidedTourSheet> createState() => _GuidedTourSheetState();
}

class _GuidedTourSheetState extends State<GuidedTourSheet> {
  int _currentStep = 0;

  late final List<_TourStep> _steps = [
    _TourStep(
      icon: Icons.search_rounded,
      color: const Color(0xFF0EA5E9),
      titleEn: 'Search & AI Semantic Matching',
      titleAr: 'البحث والبحث الدلالي بالذكاء الاصطناعي',
      descEn:
          'Search notes by title, body, tags, or checklist subtasks. Tap the AI sparkle button to let Gemini AI find notes by meaning even if keywords don\'t match.',
      descAr:
          'ابحث في العناوين والمحتوى والوسوم وقوائم المهام. اضغط زر الشرارة لتفعيل البحث الدلالي بالذكاء الاصطناعي للعثور على الملاحظات حسب المعنى.',
      actionLabelEn: 'Explore Full Showcase',
      actionLabelAr: 'استعراض كل المزايا',
      onAction: (ctx) {
        Navigator.of(ctx).pop();
        ctx.push(AppRoutes.showcase);
      },
    ),
    _TourStep(
      icon: Icons.edit_note_rounded,
      color: const Color(0xFF6366F1),
      titleEn: 'Note Editor: Voice, OCR & Checklists',
      titleAr: 'محرر الملاحظات: إملاء صوتي، OCR، وقوائم مهام',
      descEn:
          'Tap the floating (+) button anytime to create text notes or checklist tasks. Use Voice Dictation (AR/EN), extract text from camera (OCR), and summarize with Gemini AI.',
      descAr:
          'اضغط على زر (+) في أي وقت لكتابة ملاحظة أو قائمة مهام. استخدم الإملاء الصوتي، استخرج النص من الصور بالكاميرا، ولخّص بالذكاء الاصطناعي.',
      actionLabelEn: 'Open Note Editor Now',
      actionLabelAr: 'افتح محرر الملاحظات الآن',
      onAction: (ctx) {
        Navigator.of(ctx).pop();
        ctx.push(AppRoutes.addNote);
      },
    ),
    _TourStep(
      icon: Icons.map_rounded,
      color: const Color(0xFF10B981),
      titleEn: 'Notes Map & Geotagging',
      titleAr: 'خريطة الملاحظات والتنبيهات الجغرافية',
      descEn:
          'Attach coordinates to your notes. Open the Map to see all your geotagged notes on OpenStreetMap. You get an automatic alert when you\'re within 500m of a saved note.',
      descAr:
          'أرفق موقعك بملاحظاتك. استعرضها جميعاً على خريطة حية، واحصل على تنبيه تلقائي بمجرد الاقتراب 500م من أي ملاحظة محفوظة.',
      actionLabelEn: 'Open Notes Map',
      actionLabelAr: 'افتح خريطة الملاحظات',
      onAction: (ctx) {
        Navigator.of(ctx).pop();
        ctx.push(AppRoutes.notesMap);
      },
    ),
    _TourStep(
      icon: Icons.calendar_month_rounded,
      color: const Color(0xFFF59E0B),
      titleEn: 'Calendar & Schedule View',
      titleAr: 'التقويم وجدولة الملاحظات',
      descEn:
          'Organize your notes on a calendar timeline. View notes and upcoming reminders day by day with immediate filtering.',
      descAr:
          'نظّم ملاحظاتك على تقويم زمني تفاعلي. تابع الملاحظات والتذكيرات القادمة يوماً بيوم مع تصفية فورية.',
      actionLabelEn: 'Open Calendar View',
      actionLabelAr: 'افتح شاشة التقويم',
      onAction: (ctx) {
        Navigator.of(ctx).pop();
        ctx.push(AppRoutes.calendar);
      },
    ),
    _TourStep(
      icon: Icons.insights_rounded,
      color: const Color(0xFF8B5CF6),
      titleEn: 'Productivity Insights',
      titleAr: 'إحصائيات ومؤشرات الإنتاجية',
      descEn:
          'Track your note-taking metrics: total notes, completed subtask ratio, reminders scheduled, and overall productivity score.',
      descAr:
          'تابع مؤشرات إنتاجيتك: إجمالي الملاحظات، نسبة إنجاز المهام الفرعية، التذكيرات المجدولة، ونقاط الإنتاجية.',
      actionLabelEn: 'View Insights Sheet',
      actionLabelAr: 'عرض شاشة الإحصائيات',
      onAction: (ctx) {
        Navigator.of(ctx).pop();
        final cubit = ctx.read<NotesCubit>();
        final state = cubit.state;
        final activeNotes = state is NotesLoaded ? state.notes : <Note>[];
        final trashNotes = state is NotesLoaded ? state.trashNotes : <Note>[];
        ProductivityStatsSheet.show(
          ctx,
          activeNotes: List.from(activeNotes),
          trashNotes: List.from(trashNotes),
        );
      },
    ),
    _TourStep(
      icon: Icons.lock_rounded,
      color: const Color(0xFFEF4444),
      titleEn: 'Biometric Lock & Security',
      titleAr: 'القفل بالبصمة والأمان',
      descEn:
          'Lock sensitive notes with your fingerprint or device credentials. Shake your phone to quickly delete notes with safe confirmation.',
      descAr:
          'اقفل الملاحظات المهمة ببصمة الإصبع أو رمز الجهاز. هز الهاتف لمسح الملاحظات بسرعة مع تأكيد وحماية بيومترية.',
      actionLabelEn: 'Create Locked Note',
      actionLabelAr: 'إنشاء ملاحظة محمية',
      onAction: (ctx) {
        Navigator.of(ctx).pop();
        ctx.push(AppRoutes.addNote);
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;
    final isDark = context.isDarkMode;
    final step = _steps[_currentStep];

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppColors.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : AppColors.slate300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header: Step counter + close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: step.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isAr
                        ? 'خطوة ${_currentStep + 1} من ${_steps.length}'
                        : 'Step ${_currentStep + 1} of ${_steps.length}',
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: step.color,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: context.textSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Step Icon + Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: step.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(step.icon, size: 28, color: step.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    isAr ? step.titleAr : step.titleEn,
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Step Description
            Text(
              isAr ? step.descAr : step.descEn,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 14,
                height: 1.55,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 18),

            // Action Button: Direct navigation to the feature
            ElevatedButton.icon(
              onPressed: () => step.onAction(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: step.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                isAr ? step.actionLabelAr : step.actionLabelEn,
                style: const TextStyle(
                  fontFamily: AppTextStyle.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Navigation bar: Prev, Dots, Next
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () => setState(() => _currentStep--),
                    child: Text(
                      isAr ? 'السابق' : 'Previous',
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 70),

                // Dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_steps.length, (i) {
                    final isActive = i == _currentStep;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? step.color
                            : (isDark ? Colors.white24 : AppColors.slate300),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    );
                  }),
                ),

                // Next or Finish button
                if (_currentStep < _steps.length - 1)
                  TextButton(
                    onPressed: () => setState(() => _currentStep++),
                    child: Text(
                      isAr ? 'التالي' : 'Next',
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        color: step.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      isAr ? 'تم' : 'Done',
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        color: step.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
