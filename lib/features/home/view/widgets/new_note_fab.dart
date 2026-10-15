import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class NewNoteFab extends StatelessWidget {
  const NewNoteFab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        if (state is! NotesLoaded || state.notes.isEmpty) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final fabBg = isDark ? const Color(0xFF38BDF8) : AppColors.primary;
        final fabFg = isDark ? const Color(0xFF0F172A) : Colors.white;

        return FloatingActionButton.extended(
          elevation: 4,
          highlightElevation: 6,
          backgroundColor: fabBg,
          foregroundColor: fabFg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () {
            context.push(AppRoutes.addNote);
          },
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text(
            context.l10n.newNote,
            style: const TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        );
      },
    );
  }
}
