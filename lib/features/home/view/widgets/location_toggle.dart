import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';

class LocationToggle extends StatelessWidget {
  final bool attached;
  final ValueChanged<bool>? onChanged;

  const LocationToggle({
    super.key,
    required this.attached,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = context.isArabic;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged?.call(!attached),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: attached ? AppColors.skyBlueBackground : AppColors.slate100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: attached
                  ? AppColors.skyBlue.withValues(alpha: 0.35)
                  : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: attached
                      ? AppColors.skyBlue.withValues(alpha: 0.15)
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    attached
                        ? Icons.location_on_rounded
                        : Icons.location_off_outlined,
                    size: 20,
                    color: attached ? AppColors.skyBlue : AppColors.slate600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isAr ? 'إرفاق الموقع' : 'Attach Location',
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: attached
                            ? AppColors.skyBlue
                            : AppColors.slate900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      attached
                          ? (isAr
                              ? 'سيتم إرفاق الموقع بالملاحظة'
                              : 'Location will be attached to note')
                          : (isAr ? 'لم يتم إرفاق موقع' : 'No location attached'),
                      style: const TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        fontSize: 12,
                        color: AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: attached,
                activeThumbColor: AppColors.skyBlue,
                activeTrackColor: AppColors.skyBlue.withValues(alpha: 0.35),
                inactiveThumbColor: AppColors.slate400,
                inactiveTrackColor: AppColors.borderSubtle,
                onChanged: (val) {
                  onChanged?.call(val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
