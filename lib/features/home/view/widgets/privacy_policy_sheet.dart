import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';

class PrivacyPolicySheet extends StatelessWidget {
  const PrivacyPolicySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PrivacyPolicySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.privacy_tip_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'سياسة الخصوصية وأمان البيانات' : 'Privacy & Data Safety',
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        isAr ? 'بياناتك ملك لك ومحفوظة على جهازك' : 'Your data stays on your device',
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: context.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _buildSection(
                  context,
                  icon: Icons.storage_rounded,
                  color: AppColors.primary,
                  title: isAr ? '1. تخزين محلي بالكامل (Local-First)' : '1. Local-First Storage',
                  description: isAr
                      ? 'جميع ملاحظاتك، مهامك، تسجيلاتك الصوتية وقوائمك تُحفظ محليًا داخل قاعدة بيانات SQLite على جهازك فقط. لا نقوم بتشغيل خوادم سحابية لجمع أو نسخ بياناتك الشخصية.'
                      : 'All your notes, tasks, checklists, and voice memos are stored locally in an SQLite database on your device. We do not run proprietary cloud servers to harvest or store your personal notes.',
                ),
                _buildSection(
                  context,
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: isAr ? '2. إذن الكاميرا (مسح المستندات OCR)' : '2. Camera Permission (OCR Scan)',
                  description: isAr
                      ? 'يُستخدم فقط عند فتح ماسح المستندات لقراءة وتفريغ النصوص المطبوعة أو المكتوبة بخط اليد. لا تُستخدم الكاميرا في الخلفية مطلقًا.'
                      : 'Used strictly when you launch the document scanner to extract text from physical notes or receipts. The camera is never accessed in the background.',
                ),
                _buildSection(
                  context,
                  icon: Icons.mic_rounded,
                  color: const Color(0xFFEC4899),
                  title: isAr ? '3. الميكروفون (الملاحظات الصوتية)' : '3. Microphone (Voice Notes)',
                  description: isAr
                      ? 'يُستخدم لتسجيل المذكرات الصوتية أو تحويل صوتك إلى نص عبر محرك أندرويد المدمج. يتم التسجيل فقط أثناء ضغطك على زر التسجيل.'
                      : 'Used to record voice memos and dictate speech-to-text notes via on-device Android recognition. Audio records only while actively recording.',
                ),
                _buildSection(
                  context,
                  icon: Icons.location_on_rounded,
                  color: const Color(0xFF10B981),
                  title: isAr ? '4. إذن الموقع الجغرافي (اختياري)' : '4. Location Permission (Optional)',
                  description: isAr
                      ? 'يُطلب فقط إذا رغبت في وسم ملاحظتك بموقعها وعرضها على الخريطة التفاعلية. لا يتم تتبع موقعك إطلاقًا في الخلفية.'
                      : 'Requested solely if you choose to attach a geotag to a note to view it on the interactive map. Location is never tracked in the background.',
                ),
                _buildSection(
                  context,
                  icon: Icons.alarm_rounded,
                  color: const Color(0xFFF59E0B),
                  title: isAr ? '5. المنبهات ورنين شاشة القفل' : '5. Exact Alarms & Full-Screen',
                  description: isAr
                      ? 'تُستخدم صلاحيات المنبه الدقيق لإيقاظ المنبه في الدقيقة المحددة، وعرض شاشة الرنين فوق شاشة القفل عند انطلاق التنبيه الحرج.'
                      : 'Exact alarm and full-screen intent permissions ensure time-critical alarms ring at the exact minute and wake the screen when locked.',
                ),
                _buildSection(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFF3B82F6),
                  title: isAr ? '6. ميزات الذكاء الاصطناعي (Google Gemini)' : '6. AI Processing (Google Gemini)',
                  description: isAr
                      ? 'ميزات الـ AI (التلخيص، اقتراح الوسوم، والمسح الذكي) اختيارية. عند استخدامها فقط، يُرسل نص الملاحظة مشفرًا عبر HTTPS إلى خوادم Google Gemini للمعالجة دون بيع أو استغلال للبيانات.'
                      : 'AI features (Summary, Tag suggestions, smart scan) are optional. Only when triggered, note content is sent via encrypted HTTPS to Google Gemini API. Data is never sold or used for advertising.',
                ),
                _buildSection(
                  context,
                  icon: Icons.delete_sweep_rounded,
                  color: AppColors.destructive,
                  title: isAr ? '7. التحكم وحذف البيانات' : '7. Data Deletion & Control',
                  description: isAr
                      ? 'يمكنك حذف أي ملاحظة أو استخدام ميزة "حذف جميع الملاحظات" لمسح كافة بياناتك محليًا في أي وقت. إلغاء تثبيت التطبيق يحذف كامل البيانات فورًا وبشكل نهائي.'
                      : 'You can delete individual notes or use "Delete All Notes" to wipe all data instantly. Uninstalling QuickNotes completely and permanently removes all stored data.',
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'QuickNotes v1.0.0 • Developed by Ebram Wagdy',
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 11,
                      color: context.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 12,
                    height: 1.45,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
