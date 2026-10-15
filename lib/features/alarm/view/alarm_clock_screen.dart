import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/services/alarm_permission_service.dart';
import 'package:quicknotes/core/services/notification_service.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class AlarmClockScreen extends StatefulWidget {
  final int? noteId;
  final Note? note;

  const AlarmClockScreen({
    super.key,
    this.noteId,
    this.note,
  });

  @override
  State<AlarmClockScreen> createState() => _AlarmClockScreenState();
}

class _AlarmClockScreenState extends State<AlarmClockScreen>
    with SingleTickerProviderStateMixin {
  static const Color _amberColor = Color(0xFFF59E0B);
  static const Color _roseColor = Color(0xFFF43F5E);
  static const Color _emeraldColor = Color(0xFF10B981);

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  Note? _loadedNote;
  bool _isLoading = true;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _startAlarmSound();

    // Auto-dismiss floating heads-up notification so it doesn't obstruct the alarm screen
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _cancelActiveNotification();
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    _loadNoteData();
  }

  Future<void> _startAlarmSound() async {
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer?.play(AssetSource('audio/alarm.wav'));
    } catch (_) {}
  }

  void _stopAlarmSound() {
    try {
      _audioPlayer?.stop();
      _audioPlayer?.dispose();
      _audioPlayer = null;
    } catch (_) {}
  }

  Future<void> _loadNoteData() async {
    if (widget.note != null) {
      setState(() {
        _loadedNote = widget.note;
        _isLoading = false;
      });
      _cancelActiveNotification();
      return;
    }

    if (widget.noteId != null) {
      final cubit = context.read<NotesCubit>();
      final note = await cubit.getNoteById(widget.noteId!);
      if (mounted) {
        setState(() {
          _loadedNote = note;
          _isLoading = false;
        });
        _cancelActiveNotification();
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stopAlarmSound();
    _pulseController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _cancelActiveNotification() {
    final id = _loadedNote?.id ?? widget.noteId;
    if (id != null && sl.isRegistered<NotificationService>()) {
      sl<NotificationService>().cancelReminder(id);
    }
  }

  Future<void> _exitAlarmAndReturn() async {
    _stopAlarmSound();
    _cancelActiveNotification();

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }

    if (sl.isRegistered<AlarmPermissionService>()) {
      await sl<AlarmPermissionService>().closeAlarm();
    } else {
      await AlarmPermissionService().closeAlarm();
    }
  }

  void _onInProgress() {
    _stopAlarmSound();
    _cancelActiveNotification();
    if (_loadedNote != null) {
      context.pushReplacement(AppRoutes.editNote, extra: _loadedNote);
    } else {
      _exitAlarmAndReturn();
    }
  }

  Future<void> _onSnooze({int minutes = 10}) async {
    _stopAlarmSound();
    _cancelActiveNotification();
    final note = _loadedNote;
    if (note != null && note.id != null) {
      final cubit = context.read<NotesCubit>();
      final snoozeDuration = Duration(minutes: minutes);
      await cubit.snoozeNoteById(note.id!, duration: snoozeDuration);
    }
    if (mounted) {
      await _exitAlarmAndReturn();
    }
  }

  void _showSnoozeOptions() {
    final isArabic = context.isArabic;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  context.l10n.postpone,
                  style: AppTextStyle.headlineMedium.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _snoozeOptionTile(
                  title: isArabic ? '5 دقائق' : '5 Minutes',
                  minutes: 5,
                  bottomSheetContext: bottomSheetContext,
                ),
                _snoozeOptionTile(
                  title: isArabic ? '10 دقائق (الموصى به)' : '10 Minutes (Recommended)',
                  minutes: 10,
                  isRecommended: true,
                  bottomSheetContext: bottomSheetContext,
                ),
                _snoozeOptionTile(
                  title: isArabic ? '15 دقيقة' : '15 Minutes',
                  minutes: 15,
                  bottomSheetContext: bottomSheetContext,
                ),
                _snoozeOptionTile(
                  title: isArabic ? '30 دقيقة' : '30 Minutes',
                  minutes: 30,
                  bottomSheetContext: bottomSheetContext,
                ),
                _snoozeOptionTile(
                  title: isArabic ? 'ساعة واحدة' : '1 Hour',
                  minutes: 60,
                  bottomSheetContext: bottomSheetContext,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

  Widget _snoozeOptionTile({
    required String title,
    required int minutes,
    bool isRecommended = false,
    required BuildContext bottomSheetContext,
  }) {
    return ListTile(
      leading: Icon(
        Icons.snooze_rounded,
        color: isRecommended ? _amberColor : context.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyle.bodyLarge.copyWith(
          color: context.textPrimary,
          fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isRecommended
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _amberColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.isArabic ? 'تلقائي' : 'Default',
                style: const TextStyle(
                  color: _amberColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.of(bottomSheetContext).pop();
        _onSnooze(minutes: minutes);
      },
    );
  }

  Future<void> _onDismiss() async {
    _stopAlarmSound();
    _cancelActiveNotification();
    final note = _loadedNote;
    if (note != null && note.id != null) {
      final cubit = context.read<NotesCubit>();
      await cubit.dismissReminderById(note.id!);
    }
    if (mounted) {
      await _exitAlarmAndReturn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final timeFormat = DateFormat('hh:mm').format(_currentTime);
    final periodFormat = DateFormat('a').format(_currentTime);
    final dateFormat = DateFormat('EEEE, d MMMM').format(_currentTime);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _exitAlarmAndReturn();
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // Top Bar with Alarm Indicator & Quick Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _roseColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _roseColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.alarm_rounded,
                                  color: _roseColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.l10n.alarmClock,
                                  style: AppTextStyle.bodySmall.copyWith(
                                    color: _roseColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: context.textSecondary),
                            onPressed: _exitAlarmAndReturn,
                            tooltip: context.isArabic ? 'إغلاق' : 'Close',
                          ),
                        ],
                      ),

                    const Spacer(flex: 1),

                    // Animated Glowing Alarm Bell
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _roseColor.withValues(alpha: 0.12),
                          boxShadow: [
                            BoxShadow(
                              color: _roseColor.withValues(alpha: 0.25),
                              blurRadius: 36,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.alarm_on_rounded,
                          color: _roseColor,
                          size: 54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Big Digital Clock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          timeFormat,
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            fontFamily: AppTextStyle.fontFamily,
                            color: context.textPrimary,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          periodFormat,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppTextStyle.fontFamily,
                            color: _roseColor,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      dateFormat,
                      style: AppTextStyle.bodyLarge.copyWith(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Note Details Card
                    if (_loadedNote != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: context.borderColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _loadedNote!.title.isNotEmpty
                                        ? _loadedNote!.title
                                        : (context.isArabic
                                            ? 'تذكير بملاحظة'
                                            : 'Note Reminder'),
                                    style: AppTextStyle.headlineSmall.copyWith(
                                      color: context.textPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_loadedNote!.isPinned)
                                  const Icon(
                                    Icons.push_pin_rounded,
                                    color: _amberColor,
                                    size: 18,
                                  ),
                              ],
                            ),
                            if (_loadedNote!.body.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                _loadedNote!.body,
                                style: AppTextStyle.bodyMedium.copyWith(
                                  color: context.textSecondary,
                                  height: 1.4,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (_loadedNote!.subtasks.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.checklist_rounded,
                                    size: 16,
                                    color: _emeraldColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_loadedNote!.subtasks.where((s) => !s.isCompleted).length} ${context.isArabic ? "مهام متبقية" : "tasks pending"}',
                                    style: AppTextStyle.bodySmall.copyWith(
                                      color: _emeraldColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                    const Spacer(flex: 2),

                    // Action Buttons Column
                    // 1. "جاري العمل" (In Progress / Open Note) Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _onInProgress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _emeraldColor,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: _emeraldColor.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 22),
                        label: Text(
                          context.l10n.inProgress,
                          style: AppTextStyle.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 2. Row: "أجّل" (Postpone / Snooze) & "إيقاف" (Dismiss)
                    Row(
                      children: [
                        // Postpone (Snooze)
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _showSnoozeOptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _amberColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.snooze_rounded, size: 20),
                              label: Text(
                                context.l10n.postpone,
                                style: AppTextStyle.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Dismiss
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _onDismiss,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.textPrimary,
                                side: BorderSide(
                                  color: context.borderColor,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.close_rounded, size: 20),
                              label: Text(
                                context.l10n.dismissAlarm,
                                style: AppTextStyle.bodyLarge.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
