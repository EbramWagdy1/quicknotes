import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/showcase/view/guided_tour_sheet.dart';

class _SlideData {
  final IconData icon;
  final List<Color> gradient;
  final String titleEn;
  final String titleAr;
  final String descEn;
  final String descAr;
  final String? actionLabelEn;
  final String? actionLabelAr;
  final void Function(BuildContext context)? onAction;

  const _SlideData({
    required this.icon,
    required this.gradient,
    required this.titleEn,
    required this.titleAr,
    required this.descEn,
    required this.descAr,
    this.actionLabelEn,
    this.actionLabelAr,
    this.onAction,
  });
}

final List<_SlideData> _slides = [
  _SlideData(
    icon: Icons.auto_awesome_rounded,
    gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    titleEn: 'Welcome to QuickNotes',
    titleAr: 'مرحباً في QuickNotes',
    descEn:
        'A premium AI-powered notes app. Capture ideas, tasks, and memories — beautifully and effortlessly.',
    descAr:
        'تطبيق ملاحظات ذكي ومميز. سجّل أفكارك ومهامك وذكرياتك بأناقة وسهولة.',
    actionLabelEn: 'Start Guided Walkthrough',
    actionLabelAr: 'بدء الجولة التفاعلية',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      GuidedTourSheet.show(ctx);
    },
  ),
  _SlideData(
    icon: Icons.note_alt_rounded,
    gradient: const [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    titleEn: 'Smart Note Editor',
    titleAr: 'محرر ملاحظات ذكي',
    descEn:
        'Write text notes or switch to Checklist mode. Add tags, pin, favourite, attach location, set reminders, and lock with biometrics — all from one screen.',
    descAr:
        'اكتب ملاحظات نصية أو حوّلها لقائمة مهام. أضف وسوماً، ثبّت، فضّل، أرفق موقعاً، اضبط تذكيراً، وأقفل ببصمتك — كل ذلك من شاشة واحدة.',
    actionLabelEn: 'Try Note Editor Now',
    actionLabelAr: 'افتح محرر الملاحظات الآن',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.addNote);
    },
  ),
  _SlideData(
    icon: Icons.auto_awesome_mosaic_rounded,
    gradient: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    titleEn: 'AI Summarization',
    titleAr: 'تلخيص بالذكاء الاصطناعي',
    descEn:
        'Powered by Google Gemini. Tap the AI button on any note to get an instant smart summary. Append it, replace the note body, or copy it.',
    descAr:
        'مدعوم بـ Google Gemini. اضغط زر الذكاء الاصطناعي على أي ملاحظة لملخص فوري. أضفه، استبدل المحتوى، أو انسخه.',
    actionLabelEn: 'Try AI in Note Editor',
    actionLabelAr: 'جرّب الذكاء الاصطناعي بالمحرر',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.addNote);
    },
  ),
  _SlideData(
    icon: Icons.mic_rounded,
    gradient: const [Color(0xFF10B981), Color(0xFF0EA5E9)],
    titleEn: 'Voice Notes',
    titleAr: 'الملاحظات الصوتية',
    descEn:
        'Record voice notes directly with high audio quality. Listen to your recordings anytime with an integrated audio player right inside your notes.',
    descAr:
        'سجّل ملاحظاتك الصوتية مباشرة بجودة عالية مع مشغل صوت مدمج للاستماع للتسجيل في أي وقت داخل ملاحظاتك.',
    actionLabelEn: 'Record a Voice Note',
    actionLabelAr: 'جرّب تسجيل صوت',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.addNote);
    },
  ),
  _SlideData(
    icon: Icons.document_scanner_rounded,
    gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
    titleEn: 'OCR — Image to Text',
    titleAr: 'تحويل الصور إلى نص',
    descEn:
        'Photograph any text — handwritten notes, receipts, whiteboards — and Gemini AI extracts it instantly into your note.',
    descAr:
        'صوّر أي نص — كتابة يدوية، إيصالات، سبورات — ويستخرجه Gemini فوراً إلى ملاحظتك.',
    actionLabelEn: 'Extract Text from Image',
    actionLabelAr: 'استخرج نصاً من صورة',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.addNote);
    },
  ),
  _SlideData(
    icon: Icons.checklist_rounded,
    gradient: const [Color(0xFF6366F1), Color(0xFF10B981)],
    titleEn: 'Checklists and Subtasks',
    titleAr: 'قوائم المهام الفرعية',
    descEn:
        'Convert any note into a checklist with unlimited subtasks. A live progress bar tracks your completion ratio.',
    descAr:
        'حوّل أي ملاحظة لقائمة مهام غير محدودة. شريط تقدم حي يتابع نسبة إنجازك.',
    actionLabelEn: 'Create a Checklist',
    actionLabelAr: 'إنشاء قائمة مهام جديدة',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.addNote);
    },
  ),
  _SlideData(
    icon: Icons.map_rounded,
    gradient: const [Color(0xFF0EA5E9), Color(0xFF10B981)],
    titleEn: 'Map View',
    titleAr: 'عرض الخريطة',
    descEn:
        'See all geotagged notes as markers on a live OpenStreetMap. Tap a marker for a preview. Get alerted when within 500 m of a saved note.',
    descAr:
        'شاهد ملاحظاتك المرفقة بموقع على خريطة OpenStreetMap. اضغط علامة للمعاينة. تنبيه عند الاقتراب 500م من ملاحظة.',
    actionLabelEn: 'Open Notes Map',
    actionLabelAr: 'افتح خريطة الملاحظات',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.notesMap);
    },
  ),
  _SlideData(
    icon: Icons.lock_rounded,
    gradient: const [Color(0xFFEF4444), Color(0xFF8B5CF6)],
    titleEn: 'Biometric Lock',
    titleAr: 'القفل البيومتري',
    descEn:
        'Protect sensitive notes with fingerprint or passcode. Locked notes show a lock badge and require re-authentication to open.',
    descAr:
        'احمِ ملاحظاتك الحساسة ببصمة الإصبع أو رمز الجهاز. الملاحظات المقفولة تحتاج مصادقة لفتحها.',
    actionLabelEn: 'Create Locked Note',
    actionLabelAr: 'إنشاء ملاحظة محمية',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.addNote);
    },
  ),
  _SlideData(
    icon: Icons.notifications_active_rounded,
    gradient: const [Color(0xFFF59E0B), Color(0xFF6366F1)],
    titleEn: 'Reminders',
    titleAr: 'التذكيرات والإشعارات',
    descEn:
        'Set an exact date and time reminder on any note. A local notification fires at the right moment and takes you straight to your note.',
    descAr:
        'اضبط تذكيراً بتاريخ ووقت دقيق. إشعار محلي يظهر في الوقت المناسب ويأخذك مباشرةً لملاحظتك.',
    actionLabelEn: 'Schedule a Reminder',
    actionLabelAr: 'ضبط تذكير بملاحظة',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.addNote);
    },
  ),
  _SlideData(
    icon: Icons.calendar_month_rounded,
    gradient: const [Color(0xFF6366F1), Color(0xFF0EA5E9)],
    titleEn: 'Calendar & Productivity',
    titleAr: 'التقويم وإحصائيات الإنتاجية',
    descEn:
        'Track daily progress on the calendar and view completion stats, total notes, and productivity ratings in one place.',
    descAr:
        'تابع إنجازك اليومي على شاشة التقويم واستعرض مؤشرات الإنتاجية الشاملة في مكان واحد.',
    actionLabelEn: 'Open Calendar View',
    actionLabelAr: 'افتح شاشة التقويم',
    onAction: (ctx) {
      Navigator.of(ctx).pop();
      ctx.push(AppRoutes.calendar);
    },
  ),
];

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});
  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animController
      ..reset()
      ..forward();
  }

  bool get _isArabic => context.isArabic;
  bool get _isLast => _currentPage == _slides.length - 1;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkCanvas : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: -100,
            left: _currentPage.isEven ? -80 : null,
            right: _currentPage.isEven ? null : -80,
            child: _GradientBlob(colors: slide.gradient),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            bottom: -60,
            left: _currentPage.isEven ? null : -40,
            right: _currentPage.isEven ? -40 : null,
            child: _GradientBlob(
              colors: [slide.gradient.last, slide.gradient.first],
              size: 200,
              opacity: 0.14,
            ),
          ),
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _slides.length,
            itemBuilder: (_, index) => _SlidePage(
              slide: _slides[index],
              isArabic: _isArabic,
              fadeAnim: _fadeAnim,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppColors.slate600,
                    ),
                  ),
                  if (!_isLast)
                    _GlassButton(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        _isArabic ? 'تخطى' : 'Skip',
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppColors.slate600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PageDots(
                      count: _slides.length,
                      current: _currentPage,
                      activeColor: slide.gradient.first,
                    ),
                    GestureDetector(
                      onTap: _nextPage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: slide.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: slide.gradient.first.withValues(
                                alpha: 0.38,
                              ),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isLast
                                  ? (_isArabic ? 'ابدأ الآن' : "Let's go!")
                                  : (_isArabic ? 'التالي' : 'Next'),
                              style: const TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              _isLast
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final _SlideData slide;
  final bool isArabic;
  final Animation<double> fadeAnim;
  const _SlidePage({
    required this.slide,
    required this.isArabic,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 100),
            FadeTransition(
              opacity: fadeAnim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                  CurvedAnimation(parent: fadeAnim, curve: Curves.elasticOut),
                ),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: slide.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: slide.gradient.first.withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(slide.icon, size: 46, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: fadeAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: fadeAnim, curve: Curves.easeOut),
                ),
                child: Text(
                  isArabic ? slide.titleAr : slide.titleEn,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.25,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppColors.slate900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: fadeAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: fadeAnim, curve: Curves.easeOut),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.09)
                              : slide.gradient.first.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isArabic ? slide.descAr : slide.descEn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.65,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppColors.slate600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Direct Interactive Action Button: Navigates straight to the feature!
            if (slide.actionLabelEn != null) ...[
              const SizedBox(height: 20),
              FadeTransition(
                opacity: fadeAnim,
                child: GestureDetector(
                  onTap: () => slide.onAction?.call(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: slide.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: slide.gradient.first.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isArabic
                              ? (slide.actionLabelAr ?? '')
                              : (slide.actionLabelEn ?? ''),
                          style: const TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;
  const _PageDots({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 5),
          width: isActive ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : (isDark
                    ? Colors.white.withValues(alpha: 0.18)
                    : AppColors.slate300),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _GlassButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final List<Color> colors;
  final double size;
  final double opacity;
  const _GradientBlob({
    required this.colors,
    this.size = 340,
    this.opacity = 0.22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors.first.withValues(alpha: opacity),
            colors.last.withValues(alpha: opacity * 0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
