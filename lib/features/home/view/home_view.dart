import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/services/alarm_permission_service.dart';
import 'package:quicknotes/core/services/biometric_service.dart';
import 'package:quicknotes/core/services/shake_service.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/view/widgets/alarm_permissions_sheet.dart';
import 'package:quicknotes/features/home/view/widgets/delete_all_dialog.dart';
import 'package:quicknotes/features/home/view/widgets/empty_note_view.dart';
import 'package:quicknotes/features/home/view/widgets/error_view.dart';
import 'package:quicknotes/features/home/view/widgets/home_app_bar.dart';
import 'package:quicknotes/features/home/view/widgets/new_note_fab.dart';
import 'package:quicknotes/features/home/view/widgets/no_search_results_view.dart';
import 'package:quicknotes/features/home/view/widgets/note_list.dart';
import 'package:quicknotes/features/home/view/widgets/search_header.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class HomeView extends StatefulWidget {
  final ShakeService? shakeService;

  const HomeView({super.key, this.shakeService});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  late final ShakeService shakeService;
  bool isProcessingShake = false;

  @override
  void initState() {
    super.initState();
    shakeService =
        widget.shakeService ??
        (sl.isRegistered<ShakeService>() ? sl<ShakeService>() : ShakeService());
    WidgetsBinding.instance.addObserver(this);
    startShakeListening();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAlarmPermissionsGuide();
    });
  }

  Future<void> _checkAlarmPermissionsGuide() async {
    if (!mounted) return;
    if (sl.isRegistered<AlarmPermissionService>()) {
      final alarmService = sl<AlarmPermissionService>();
      final shouldShow = await alarmService.shouldShowPrompt();
      if (shouldShow && mounted) {
        AlarmPermissionsSheet.show(context);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      startShakeListening();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      shakeService.stopListening();
    }
  }

  void startShakeListening() {
    shakeService.startListening(
      onShake: () {
        handleShake();
      },
    );
  }

  Future<void> handleShake() async {
    if (!mounted || isProcessingShake) return;

    final cubit = context.read<NotesCubit>();
    final state = cubit.state;

    if (state is! NotesLoaded || state.notes.isEmpty) {
      return;
    }

    isProcessingShake = true;

    try {
      final confirmed = await showDeleteAllDialog(context);

      if (confirmed == true && mounted) {
        final hasLockedNotes = state.notes.any((n) => n.isLocked);
        if (hasLockedNotes) {
          final biometricService = sl.isRegistered<BiometricService>()
              ? sl<BiometricService>()
              : BiometricService();
          final authenticated = await biometricService.authenticate(
            localizedReason: context.isArabic
                ? 'يلزم التحقق لحذف جميع الملاحظات بما فيها المقفلة'
                : 'Authenticate to delete all notes including locked notes',
          );
          if (!authenticated) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.slate900,
                  content: Text(
                    context.isArabic
                        ? 'يلزم التحقق لحذف الملاحظات المقفلة.'
                        : 'Authentication required to delete locked notes.',
                  ),
                ),
              );
            }
            return;
          }
        }

        final success = await cubit.deleteAllNotes();

        if (success && mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.slate900,
                content: const Row(
                  children: [
                    Icon(
                      Icons.delete_sweep_rounded,
                      color: AppColors.cardWhite,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'All notes deleted',
                      style: TextStyle(
                        fontFamily: AppTextStyle.fontFamily,
                        color: AppColors.cardWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 3),
              ),
            );
        }
      }
    } finally {
      if (mounted) {
        isProcessingShake = false;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    shakeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: const HomeAppBar(),
      body: BlocConsumer<NotesCubit, NotesState>(
        listener: (context, state) {
          if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.error,
                content: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.skyBlue),
            );
          }

          if (state is NotesError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<NotesCubit>().loadNotes();
              },
            );
          }

          if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const EmptyNotesView();
            }

            final filteredNotes = state.filteredNotes;

            return Column(
              children: [
                // Search Header section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: SearchHeader(initialQuery: state.searchQuery),
                ),

                // Tags Filter Bar (only visible when user has added tags)
                if (state.allTags.isNotEmpty) ...[
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildTagChip(
                          label: context.l10n.all,
                          isSelected: state.selectedTag == null,
                          onTap: () =>
                              context.read<NotesCubit>().setSelectedTag(null),
                        ),
                        ...state.allTags.map((tag) {
                          final isSelected = state.selectedTag == tag;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _buildTagChip(
                              label: '#$tag',
                              isSelected: isSelected,
                              onTap: () {
                                final cubit = context.read<NotesCubit>();
                                cubit.setSelectedTag(isSelected ? null : tag);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],

                // Note list or empty search result view
                Expanded(
                  child: filteredNotes.isEmpty
                      ? NoSearchResultsView(query: state.searchQuery)
                      : NoteList(notes: filteredNotes),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: const NewNoteFab(),
    );
  }

  Widget _buildTagChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;
    return InkWell(
      borderRadius: BorderRadius.circular(9999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.accentColor
              : (isDark
                  ? const Color(0xFF1E293B).withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.85)),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? context.accentColor
                : (isDark
                    ? const Color(0xFF334155).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.9)),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.accentColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppTheme.darkCanvas : AppColors.onPrimary)
                  : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
