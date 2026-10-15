import 'package:flutter/material.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';

class SubtasksEditor extends StatefulWidget {
  final List<Subtask> subtasks;
  final ValueChanged<List<Subtask>> onChanged;

  const SubtasksEditor({
    super.key,
    required this.subtasks,
    required this.onChanged,
  });

  @override
  State<SubtasksEditor> createState() => _SubtasksEditorState();
}

class _SubtasksEditorState extends State<SubtasksEditor> {
  final TextEditingController _newSubtaskController = TextEditingController();
  final FocusNode _newSubtaskFocus = FocusNode();

  @override
  void dispose() {
    _newSubtaskController.dispose();
    _newSubtaskFocus.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _newSubtaskController.text.trim();
    if (text.isEmpty) return;

    final newSubtask = Subtask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: text,
      isCompleted: false,
    );

    widget.onChanged([...widget.subtasks, newSubtask]);
    _newSubtaskController.clear();
  }

  void _toggleSubtask(int index, bool? value) {
    final updated = List<Subtask>.from(widget.subtasks);
    final current = updated[index];
    updated[index] = current.copyWith(
      isCompleted: value ?? !current.isCompleted,
    );
    widget.onChanged(updated);
  }

  void _removeSubtask(int index) {
    final updated = List<Subtask>.from(widget.subtasks)..removeAt(index);
    widget.onChanged(updated);
  }

  void _updateSubtaskTitle(int index, String newTitle) {
    final updated = List<Subtask>.from(widget.subtasks);
    updated[index] = updated[index].copyWith(title: newTitle.trim());
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.subtasks.where((s) => s.isCompleted).length;
    final totalCount = widget.subtasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header & Progress Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.checklist_rounded,
                  size: 18,
                  color: AppColors.skyBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.checklistAndSubtasks,
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
            if (totalCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: completedCount == totalCount
                      ? AppColors.tertiaryContainer.withValues(alpha: 0.15)
                      : context.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.isArabic
                      ? '$completedCount من $totalCount مكتملة'
                      : '$completedCount of $totalCount done',
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: completedCount == totalCount
                        ? AppColors.tertiaryContainer
                        : context.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Subtasks List
        if (widget.subtasks.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.subtasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final subtask = widget.subtasks[index];
              return _SubtaskItemTile(
                key: ValueKey(subtask.id),
                subtask: subtask,
                onToggle: (val) => _toggleSubtask(index, val),
                onDelete: () => _removeSubtask(index),
                onTitleChanged: (val) => _updateSubtaskTitle(index, val),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // Input Field to add new subtask
        Container(
          decoration: BoxDecoration(
            color: context.containerFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              // Visual unchecked placeholder icon
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.borderColor, width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _newSubtaskController,
                  focusNode: _newSubtaskFocus,
                  decoration: InputDecoration(
                    hintText: context.l10n.addSubtaskHint,
                    hintStyle: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      color: context.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 14,
                    color: context.textPrimary,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addSubtask(),
                ),
              ),
              IconButton(
                tooltip: context.isArabic ? 'إضافة مهمة فرعية' : 'Add sub-task',
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                onPressed: _addSubtask,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubtaskItemTile extends StatelessWidget {
  final Subtask subtask;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;
  final ValueChanged<String> onTitleChanged;

  const _SubtaskItemTile({
    super.key,
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
    required this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: subtask.isCompleted
              ? context.borderColor.withValues(alpha: 0.5)
              : context.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onToggle(!subtask.isCompleted),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: subtask.isCompleted
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: subtask.isCompleted
                      ? AppColors.primary
                      : context.borderColor,
                  width: 1.5,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: AppTextStyle.fontFamily,
                fontSize: 14,
                color: subtask.isCompleted
                    ? context.textMuted
                    : context.textPrimary,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: context.textMuted,
                fontWeight: FontWeight.w400,
              ),
              child: Text(subtask.title),
            ),
          ),

          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: context.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
