import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/localization/locale_cubit.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/theme/theme_cubit.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/view/widgets/alarm_permissions_sheet.dart';
import 'package:quicknotes/features/home/view/widgets/delete_all_dialog.dart';
import 'package:quicknotes/features/home/view/widgets/privacy_policy_sheet.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';
import 'package:quicknotes/features/showcase/view/guided_tour_sheet.dart';
import 'package:quicknotes/features/stats/view/productivity_stats_sheet.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  Widget _buildLanguageToggleButton(BuildContext context) {
    LocaleCubit? cubit;
    try {
      cubit = context.read<LocaleCubit>();
    } catch (_) {
      if (sl.isRegistered<LocaleCubit>()) {
        cubit = sl<LocaleCubit>();
      }
    }

    final isAr = context.isArabic;
    return IconButton(
      tooltip: isAr ? 'Switch to English' : 'التبديل إلى العربية',
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: context.accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.accentColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Text(
          isAr ? 'EN' : 'عربي',
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.accentColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
      onPressed: () => cubit?.toggleLocale(),
    );
  }

  Widget _buildThemeToggleButton(BuildContext context, Color iconColor) {
    ThemeCubit? cubit;
    try {
      cubit = context.read<ThemeCubit>();
    } catch (_) {
      if (sl.isRegistered<ThemeCubit>()) {
        cubit = sl<ThemeCubit>();
      }
    }

    if (cubit == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return IconButton(
        tooltip: isDark ? context.l10n.switchToLightMode : context.l10n.switchToDarkMode,
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
          color: isDark ? const Color(0xFFFBBF24) : iconColor,
          size: 21,
        ),
        onPressed: () {},
      );
    }

    return BlocBuilder<ThemeCubit, ThemeMode>(
      bloc: cubit,
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? context.l10n.switchToLightMode : context.l10n.switchToDarkMode,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                RotationTransition(turns: anim, child: FadeTransition(opacity: anim, child: child)),
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
              key: ValueKey(isDark),
              color: isDark ? const Color(0xFFFBBF24) : iconColor,
              size: 21,
            ),
          ),
          onPressed: () => cubit?.toggleTheme(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = context.iconColor;
    final isDark = context.isDarkMode;

    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          final count = state is NotesLoaded ? state.notes.length : 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.myNotes,
                style: TextStyle(
                  fontFamily: AppTextStyle.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: count > 0 ? AppColors.skyBlue : context.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    context.l10n.activeNotesCount(count),
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            final isLoaded = state is NotesLoaded;
            final isFavoriteFilter =
                isLoaded && state.filter == NoteFilter.favorites;
            final hasActiveNotes = isLoaded && state.notes.isNotEmpty;
            final activeNotes = isLoaded ? state.notes : const [];
            final trashNotes = isLoaded ? state.trashNotes : const [];

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language Switcher Toggle
                  _buildLanguageToggleButton(context),

                  // Theme Mode Toggle
                  _buildThemeToggleButton(context, iconColor),

                  // Options menu consolidating secondary actions
                  PopupMenuButton<String>(
                    tooltip: context.isArabic ? 'خيارات إضافية' : 'More options',
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: iconColor,
                      size: 21,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: context.borderColor,
                        width: 1,
                      ),
                    ),
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.95),
                    elevation: 6,
                    onSelected: (value) async {
                      final cubit = context.read<NotesCubit>();
                      if (value == 'favorites') {
                        if (isFavoriteFilter) {
                          cubit.setFilter(NoteFilter.all);
                        } else {
                          cubit.setFilter(NoteFilter.favorites);
                        }
                      } else if (value == 'map') {
                        context.push(AppRoutes.notesMap);
                      } else if (value == 'calendar') {
                        context.push(AppRoutes.calendar);
                      } else if (value == 'showcase') {
                        GuidedTourSheet.show(context);
                      } else if (value == 'stats') {
                        ProductivityStatsSheet.show(
                          context,
                          activeNotes: List.from(activeNotes),
                          trashNotes: List.from(trashNotes),
                        );
                      } else if (value == 'alarm_permissions') {
                        AlarmPermissionsSheet.show(context);
                      } else if (value == 'privacy_policy') {
                        PrivacyPolicySheet.show(context);
                      } else if (value == 'delete_all') {
                        final confirmed = await showDeleteAllDialog(context);
                        if (confirmed == true && context.mounted) {
                          cubit.deleteAllNotes();
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      // Filter Favorites
                      PopupMenuItem(
                        value: 'favorites',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isFavoriteFilter
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 16,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isFavoriteFilter
                                  ? context.l10n.showAllNotes
                                  : context.l10n.favoritesOnly,
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                color: context.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notes Map
                      PopupMenuItem(
                        value: 'map',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.skyBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.map_outlined,
                                size: 16,
                                color: AppColors.skyBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.l10n.notesMap,
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                color: context.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notes Calendar
                      PopupMenuItem(
                        value: 'calendar',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_month_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.l10n.calendar,
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                color: context.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      const PopupMenuDivider(),

                      // Tour the App
                      PopupMenuItem(
                        value: 'showcase',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16,
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.isArabic ? 'جولة في التطبيق' : 'Tour the App',
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                color: context.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      const PopupMenuDivider(),

                      // Productivity Insights
                      PopupMenuItem(
                        value: 'stats',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.skyBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.insights_rounded,
                                size: 16,
                                color: AppColors.skyBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.l10n.productivityInsights,
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                color: context.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Alarm Permissions Guide
                      PopupMenuItem(
                        value: 'alarm_permissions',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.alarm_on_rounded,
                                size: 16,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.isArabic ? 'إعدادات رنين المنبه' : 'Alarm Ring Settings',
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                color: context.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Privacy Policy
                      PopupMenuItem(
                        value: 'privacy_policy',
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.privacy_tip_outlined,
                                size: 16,
                                color: Color(0xFF0EA5E9),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
                              style: TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                color: context.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete all notes
                      if (hasActiveNotes)
                        PopupMenuItem(
                          value: 'delete_all',
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.destructive.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete_sweep_outlined,
                                  size: 16,
                                  color: AppColors.destructive,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                context.l10n.deleteAllNotes,
                                style: const TextStyle(
                                  fontFamily: AppTextStyle.fontFamily,
                                  color: AppColors.destructive,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
