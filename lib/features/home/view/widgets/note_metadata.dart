import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/model/note_model.dart';

class NoteMetadata extends StatelessWidget {
  final bool isEdit;
  final Note? note;

  const NoteMetadata({super.key, required this.isEdit, required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 13,
            color: AppColors.slate400,
          ),
          const SizedBox(width: 5),
          Text(
            isEdit
                ? context.formatDate(note!.updatedAt)
                : (context.isArabic ? 'اليوم' : 'Today'),
            style: const TextStyle(
              fontFamily: AppTextStyle.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
