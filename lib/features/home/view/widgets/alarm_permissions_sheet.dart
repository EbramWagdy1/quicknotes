import 'package:flutter/material.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/services/alarm_permission_service.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';

class AlarmPermissionsSheet extends StatefulWidget {
  final AlarmPermissionService? service;

  const AlarmPermissionsSheet({super.key, this.service});

  static Future<void> show(BuildContext context) async {
    final service = sl.isRegistered<AlarmPermissionService>()
        ? sl<AlarmPermissionService>()
        : AlarmPermissionService();
    await service.markPromptSeen();

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AlarmPermissionsSheet(),
    );
  }

  @override
  State<AlarmPermissionsSheet> createState() => _AlarmPermissionsSheetState();
}

class _AlarmPermissionsSheetState extends State<AlarmPermissionsSheet> {
  late final AlarmPermissionService _service;
  bool _isIgnoringBattery = false;
  bool _isLoading = true;
  String _manufacturer = '';

  @override
  void initState() {
    super.initState();
    _service = widget.service ??
        (sl.isRegistered<AlarmPermissionService>()
            ? sl<AlarmPermissionService>()
            : AlarmPermissionService());
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final ignoring = await _service.isIgnoringBatteryOptimizations();
    final manufacturer = await _service.getDeviceManufacturer();
    if (mounted) {
      setState(() {
        _isIgnoringBattery = ignoring;
        _manufacturer = manufacturer;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBatteryOptimization() async {
    await _service.requestIgnoreBatteryOptimizations();
    // Allow brief time for user interaction
    await Future.delayed(const Duration(milliseconds: 600));
    final ignoring = await _service.isIgnoringBatteryOptimizations();
    if (mounted) {
      setState(() {
        _isIgnoringBattery = ignoring;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final oemBrand = _manufacturer.isNotEmpty ? _manufacturer.toUpperCase() : 'Android';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Icon & Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.alarm_on_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic
                            ? 'ضمان رنين المنبه في موعده'
                            : 'Ensure On-Time Alarms',
                        style: AppTextStyle.headlineSmall.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isArabic
                            ? 'إعدادات مطلوبة لهواتف $oemBrand'
                            : 'Required settings for $oemBrand',
                        style: AppTextStyle.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Description
            Text(
              isArabic
                ? 'لكي يعمل المنبه ويوقظ الشاشة عندما يكون الهاتف مقفولاً أو التطبيق مغلقاً تماماً، يُرجى تفعيل الآتي:'
                : 'To wake up your screen and ring alarms when locked or closed, please allow the following:',
              style: AppTextStyle.bodyMedium.copyWith(
                color: context.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ))
            else ...[
              // Step 1: Battery Optimization
              _buildStepCard(
                context: context,
                stepNumber: '1',
                title: isArabic
                    ? 'إلغاء قيود البطارية (بدون قيود)'
                    : 'Disable Battery Optimization',
                description: isArabic
                    ? 'يمنع نظام توفير الطاقة من إيقاف المنبه عند غلق التطبيق.'
                    : 'Prevents battery saver from killing alarms when app is closed.',
                icon: Icons.battery_charging_full_rounded,
                isCompleted: _isIgnoringBattery,
                actionLabel: isArabic ? 'تعطيل القيود الآن' : 'Allow Unrestricted',
                onAction: _handleBatteryOptimization,
              ),
              const SizedBox(height: 12),

              // Step 2: Lock screen and Pop-up windows
              _buildStepCard(
                context: context,
                stepNumber: '2',
                title: isArabic
                    ? 'أذونات شاشة القفل والنوافذ المنبثقة'
                    : 'Lock Screen & Pop-up Permissions',
                description: isArabic
                    ? 'تفعيل: (العرض على شاشة القفل) و (عرض النوافذ المنبثقة في الخلفية).'
                    : 'Enable: (Show on Lock screen) & (Display pop-up windows).',
                icon: Icons.lock_clock_rounded,
                isCompleted: false,
                actionLabel: isArabic ? 'فتح صفحة الأذونات ⚙️' : 'Open Permissions ⚙️',
                onAction: () => _service.openOemPermissions(),
              ),
            ],
            const SizedBox(height: 20),

            // Dismiss Button
            FilledButton(
              onPressed: () async {
                await _service.markPromptSeen();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isArabic ? 'حسناً، فهمت' : 'Got It',
                style: AppTextStyle.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required bool isCompleted,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981)
              : context.borderColor,
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.isArabic ? 'مُفعّل' : 'Active',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyle.bodySmall.copyWith(
              color: context.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          if (!isCompleted)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
