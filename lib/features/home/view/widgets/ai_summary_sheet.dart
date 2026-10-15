import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/services/gemini_service.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';

class AiSummarySheet extends StatefulWidget {
  final String noteTitle;
  final String noteContent;
  final ValueChanged<String>? onAppendToNote;
  final ValueChanged<String>? onReplaceNote;

  const AiSummarySheet({
    super.key,
    required this.noteTitle,
    required this.noteContent,
    this.onAppendToNote,
    this.onReplaceNote,
  });

  /// Displays the AI summary bottom sheet modally.
  static Future<void> show({
    required BuildContext context,
    required String noteTitle,
    required String noteContent,
    ValueChanged<String>? onAppendToNote,
    ValueChanged<String>? onReplaceNote,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiSummarySheet(
        noteTitle: noteTitle,
        noteContent: noteContent,
        onAppendToNote: onAppendToNote,
        onReplaceNote: onReplaceNote,
      ),
    );
  }

  @override
  State<AiSummarySheet> createState() => _AiSummarySheetState();
}

class _AiSummarySheetState extends State<AiSummarySheet> {
  final GeminiService _geminiService = sl<GeminiService>();

  bool _isLoading = true;
  String? _summary;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateSummary();
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _geminiService.summarizeNote(
        title: widget.noteTitle,
        body: widget.noteContent,
      );

      if (mounted) {
        setState(() {
          _summary = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard() {
    if (_summary == null) return;
    Clipboard.setData(ClipboardData(text: _summary!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate900,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              context.isArabic ? 'تم نسخ الملخص إلى الحافظة' : 'Summary copied to clipboard',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAppend() {
    if (_summary == null) return;
    widget.onAppendToNote?.call(_summary!);
    Navigator.of(context).pop();
  }

  void _handleReplace() {
    if (_summary == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : AppColors.borderSubtle,
          ),
        ),
        title: Text(
          context.isArabic ? 'استبدال محتوى الملاحظة؟' : 'Replace Note Body?',
          style: AppTextStyle.headlineSmall.copyWith(
            color: isDark ? Colors.white : AppColors.slate900,
          ),
        ),
        content: Text(
          context.isArabic
              ? 'سيتم استبدال محتوى ملاحظتك الحالي بملخص الذكاء الاصطناعي.'
              : 'This will replace your current note content with the AI summary.',
          style: AppTextStyle.bodyMedium.copyWith(
            color: isDark ? AppColors.slate300 : AppColors.slate600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate600),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onReplaceNote?.call(_summary!);
              Navigator.of(context).pop();
            },
            child: Text(context.isArabic ? 'استبدال' : 'Replace'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final originalLength = widget.noteContent.trim().length;
    final summaryLength = _summary?.length ?? 0;
    final reduction = originalLength > 0 && summaryLength > 0
        ? (((originalLength - summaryLength) / originalLength) * 100).clamp(0, 99).toInt()
        : 0;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withValues(alpha: 0.94)
                : AppColors.cardWhite.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF334155).withValues(alpha: 0.6)
                    : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.slate700 : AppColors.dragHandle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.skyBlue, Color(0xFF0284C7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.skyBlue.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.isArabic ? 'ملخص الملاحظة بالذكاء الاصطناعي' : 'AI Note Summary',
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.slate900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  context.isArabic
                                      ? 'مدعوم بواسطة Gemini 1.5 Flash'
                                      : 'Powered by Gemini 1.5 Flash',
                                  style: TextStyle(
                                    fontFamily: AppTextStyle.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark ? AppColors.slate400 : AppColors.slate600,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Content Area
                  Flexible(
                    child: _buildBody(reduction, isDark),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Actions
                  if (!_isLoading && _summary != null)
                    Row(
                      children: [
                        // Copy Button
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : AppColors.slate900,
                              side: BorderSide(
                                color: isDark ? const Color(0xFF334155) : AppColors.borderSubtle,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            label: Text(
                              context.isArabic ? 'نسخ' : 'Copy',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Append Button
                        if (widget.onAppendToNote != null)
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _handleAppend,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(
                                context.isArabic ? 'إلحاق' : 'Append',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),

                        // Replace Button
                        if (widget.onReplaceNote != null)
                          IconButton(
                            tooltip: context.isArabic ? 'استبدال محتوى الملاحظة' : 'Replace note body',
                            style: IconButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.slate100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isDark ? const Color(0xFF334155) : Colors.transparent,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.find_replace_rounded,
                              color: isDark ? Colors.white : AppColors.slate900,
                              size: 20,
                            ),
                            onPressed: _handleReplace,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(int reduction, bool isDark) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.darkSkyBlue.withValues(alpha: 0.15)
                    : AppColors.skyBlueBackground,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.isArabic
                  ? 'جارٍ استخلاص أهم النقاط بواسطة Gemini...'
                  : 'Distilling key takeaways with Gemini...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.slate900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.isArabic
                  ? 'استخراج النقاط الرئيسية والمهام والسياق'
                  : 'Finding main points, actions & context',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 13,
                color: isDark ? AppColors.slate400 : AppColors.slate600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF450A0A).withValues(alpha: 0.5) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 14,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.slate900,
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : AppColors.borderSubtle,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _generateSummary,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(context.isArabic ? 'إعادة المحاولة' : 'Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat chip
          if (reduction > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF059669).withValues(alpha: 0.6)
                            : const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_down_rounded,
                          size: 14,
                          color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.isArabic
                              ? 'أكثر إيجازاً بنسبة $reduction%'
                              : '$reduction% more concise',
                          style: TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : AppColors.canvas,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : AppColors.borderSubtle,
              ),
            ),
            child: SelectableText(
              _summary ?? '',
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.slate100 : AppColors.slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
