import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/core/utils/calendar_helper.dart';
import 'package:quicknotes/features/calendar/view/widgets/calendar_day_notes.dart';
import 'package:quicknotes/features/calendar/view/widgets/calendar_grid.dart';
import 'package:quicknotes/features/calendar/view/widgets/calendar_header.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _currentMonth;
  late DateTime _selectedDay;
  bool _remindersOnly = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _onPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _selectedDay = _currentMonth;
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _selectedDay = _currentMonth;
    });
  }

  void _onToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month, 1);
      _selectedDay = DateTime(now.year, now.month, now.day);
    });
  }

  void _onSelectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
      if (day.month != _currentMonth.month) {
        _currentMonth = DateTime(day.year, day.month, 1);
      }
    });
  }

  void _toggleRemindersOnly(bool value) {
    setState(() {
      _remindersOnly = value;
    });
  }

  void _addNewNote() {
    context.push(AppRoutes.addNote);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: context.canvasColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.textPrimary,
          ),
          tooltip: context.isArabic ? 'رجوع للملاحظات' : 'Back to notes',
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.notesCalendar,
          style: TextStyle(
            fontFamily: AppTextStyle.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: context.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: isDark ? AppTheme.darkSkyBlue : AppColors.primary,
              size: 24,
            ),
            tooltip: context.isArabic ? 'إضافة ملاحظة' : 'Add note',
            onPressed: _addNewNote,
          ),
        ],
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          final List<Note> notes =
              state is NotesLoaded ? state.notes : <Note>[];

          final dayNotes = CalendarHelper.getNotesForDay(
            notes,
            _selectedDay,
            remindersOnly: _remindersOnly,
          );

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarHeader(
                  currentMonth: _currentMonth,
                  onPreviousMonth: _onPreviousMonth,
                  onNextMonth: _onNextMonth,
                  onToday: _onToday,
                  remindersOnly: _remindersOnly,
                  onToggleRemindersOnly: _toggleRemindersOnly,
                ),
                const SizedBox(height: 8),
                CalendarGrid(
                  currentMonth: _currentMonth,
                  selectedDay: _selectedDay,
                  notes: notes,
                  onSelectDay: _onSelectDay,
                ),
                const SizedBox(height: 20),
                CalendarDayNotes(
                  selectedDay: _selectedDay,
                  notes: dayNotes,
                  remindersOnly: _remindersOnly,
                  onAddNote: _addNewNote,
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewNote,
        backgroundColor: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
        foregroundColor: isDark ? AppTheme.darkCanvas : Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tooltip: context.isArabic ? 'إنشاء ملاحظة' : 'Create note',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
