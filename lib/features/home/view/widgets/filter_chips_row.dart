import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class FilterChipsRow extends StatelessWidget {
  final NoteFilter currentFilter;
  final NoteSortOrder currentSort;
  final int totalCount;
  final int locationCount;
  final int lockedCount;

  const FilterChipsRow({
    super.key,
    required this.currentFilter,
    required this.currentSort,
    required this.totalCount,
    required this.locationCount,
    required this.lockedCount,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotesCubit>();
    final isAr = context.isArabic;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // All Notes Chip
          _FilterChipItem(
            label: isAr ? 'الكل ($totalCount)' : 'All ($totalCount)',
            isSelected: currentFilter == NoteFilter.all,
            onTap: () => cubit.setFilter(NoteFilter.all),
          ),
          const SizedBox(width: 8),

          // With Location Chip
          _FilterChipItem(
            label: isAr ? 'بموقع ($locationCount)' : 'With Location ($locationCount)',
            icon: Icons.location_on_rounded,
            iconColor: currentFilter == NoteFilter.withLocation
                ? Colors.white
                : AppColors.tertiary,
            isSelected: currentFilter == NoteFilter.withLocation,
            onTap: () => cubit.setFilter(NoteFilter.withLocation),
          ),
          const SizedBox(width: 8),

          // Without Location Chip
          _FilterChipItem(
            label: isAr ? 'بدون موقع' : 'No Location',
            isSelected: currentFilter == NoteFilter.withoutLocation,
            onTap: () => cubit.setFilter(NoteFilter.withoutLocation),
          ),
          const SizedBox(width: 8),

          // Locked Notes Chip
          _FilterChipItem(
            label: isAr ? 'مقفل ($lockedCount)' : 'Locked ($lockedCount)',
            icon: Icons.lock_outline_rounded,
            isSelected: currentFilter == NoteFilter.locked,
            onTap: () => cubit.setFilter(NoteFilter.locked),
          ),
          const SizedBox(width: 8),

          // Sort Menu Button
          PopupMenuButton<NoteSortOrder>(
            initialValue: currentSort,
            tooltip: isAr ? 'ترتيب الملاحظات' : 'Sort notes',
            onSelected: (sortOrder) => cubit.setSortOrder(sortOrder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.borderSubtle, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: AppColors.slate600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortLabel(currentSort, isArabic: isAr),
                    style: const TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: NoteSortOrder.newest,
                child: Text(isAr ? 'الأحدث أولاً' : 'Newest first'),
              ),
              PopupMenuItem(
                value: NoteSortOrder.oldest,
                child: Text(isAr ? 'الأقدم أولاً' : 'Oldest first'),
              ),
              PopupMenuItem(
                value: NoteSortOrder.titleAz,
                child: Text(isAr ? 'العنوان (أ-ي)' : 'Title (A-Z)'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _sortLabel(NoteSortOrder sortOrder, {required bool isArabic}) {
    switch (sortOrder) {
      case NoteSortOrder.newest:
        return isArabic ? 'الأحدث' : 'Newest';
      case NoteSortOrder.oldest:
        return isArabic ? 'الأقدم' : 'Oldest';
      case NoteSortOrder.titleAz:
        return isArabic ? 'أ-ي' : 'A-Z';
    }
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? Colors.white
                    : (iconColor ?? AppColors.slate600),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.slate600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
