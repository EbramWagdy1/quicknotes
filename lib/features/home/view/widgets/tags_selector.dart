import 'package:flutter/material.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/services/gemini_service.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';

class TagsSelector extends StatefulWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final String? noteTitle;
  final String? noteContent;

  const TagsSelector({
    super.key,
    required this.tags,
    required this.onChanged,
    this.noteTitle,
    this.noteContent,
  });

  static const List<String> defaultSuggestions = [
    'Work',
    'Personal',
    'Ideas',
    'Shopping',
    'Important',
    'Study',
  ];

  @override
  State<TagsSelector> createState() => _TagsSelectorState();
}

class _TagsSelectorState extends State<TagsSelector> {
  bool _isSuggesting = false;

  Future<void> _suggestAiTags() async {
    final title = widget.noteTitle?.trim() ?? '';
    final body = widget.noteContent?.trim() ?? '';

    if (title.isEmpty && body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.slate900,
          content: Text(
            context.isArabic
                ? 'أضف عنواناً أو محتوى أولاً لاقتراح الوسوم'
                : 'Add a title or note content first to suggest AI tags',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSuggesting = true;
    });

    try {
      final gemini = sl<GeminiService>();
      final suggested = await gemini.suggestTags(title: title, body: body);

      if (mounted) {
        if (suggested.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.slate900,
              content: Text(
                context.isArabic
                    ? 'لا توجد وسوم جديدة مقترحة لهذه الملاحظة'
                    : 'No new tags suggested for this note',
              ),
            ),
          );
        } else {
          final updated = List<String>.from(widget.tags);
          int addedCount = 0;
          for (final tag in suggested) {
            if (!updated.contains(tag)) {
              updated.add(tag);
              addedCount++;
            }
          }
          widget.onChanged(updated);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.slate900,
              content: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.skyBlue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    addedCount > 0
                        ? (context.isArabic
                            ? 'تمت إضافة $addedCount وسوم ذكية: ${suggested.join('، ')}'
                            : 'Added $addedCount AI tags: ${suggested.join(', ')}')
                        : (context.isArabic
                            ? 'جميع الوسوم المقترحة مضافة بالفعل'
                            : 'All suggested tags are already added'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.destructive,
            content: Text(
              context.isArabic ? 'فشل اقتراح الوسوم: $e' : 'Failed to generate tags: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSuggesting = false;
        });
      }
    }
  }

  void _showAddTagDialog(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : AppColors.borderSubtle,
                ),
              ),
              title: Text(
                context.isArabic ? 'إضافة وسم' : 'Add Tag',
                style: AppTextStyle.headlineSmall.copyWith(
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                    decoration: InputDecoration(
                      hintText: context.isArabic ? 'أدخل اسم الوسم...' : 'Enter tag name...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.slate500 : AppColors.slate400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : AppColors.borderSubtle,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : AppColors.borderSubtle,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (val) {
                      final text = val.trim();
                      if (text.isNotEmpty && !widget.tags.contains(text)) {
                        widget.onChanged([...widget.tags, text]);
                        Navigator.of(ctx).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.isArabic ? 'اقتراحات:' : 'Suggestions:',
                    style: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (context.isArabic
                            ? const ['عمل', 'شخصي', 'أفكار', 'تسوق', 'مهم', 'دراسة']
                            : TagsSelector.defaultSuggestions)
                        .map((suggestion) {
                      final isSelected = widget.tags.contains(suggestion);
                      return FilterChip(
                        label: Text(
                          suggestion,
                          style: TextStyle(
                            fontFamily: AppTextStyle.fontFamily,
                            fontSize: 12,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.slate300 : AppColors.slate600),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: isDark
                            ? AppColors.primary.withValues(alpha: 0.25)
                            : AppColors.primaryFixed.withValues(alpha: 0.35),
                        backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.surfaceContainerLow,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? const Color(0xFF334155) : AppColors.borderSubtle),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            widget.onChanged([...widget.tags, suggestion]);
                          } else {
                            widget.onChanged(widget.tags.where((t) => t != suggestion).toList());
                          }
                          setState(() {});
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    context.isArabic ? 'إلغاء' : 'Cancel',
                    style: TextStyle(color: isDark ? AppColors.slate400 : AppColors.slate600),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty && !widget.tags.contains(text)) {
                      widget.onChanged([...widget.tags, text]);
                    }
                    Navigator.of(ctx).pop();
                  },
                  child: Text(context.isArabic ? 'إضافة' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeTag(String tag) {
    widget.onChanged(widget.tags.where((t) => t != tag).toList());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...widget.tags.map((tag) {
          return Container(
            padding: const EdgeInsets.fromLTRB(8, 3, 4, 3),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.primaryFixed.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : AppColors.primaryFixedDim.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '#$tag',
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF93C5FD) : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => _removeTag(tag),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: isDark ? const Color(0xFF93C5FD) : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Add Tag manual chip
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _showAddTagDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? context.glassSurface : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? context.glassBorder : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: isDark ? context.textSecondary : AppColors.slate600,
                ),
                const SizedBox(width: 4),
                Text(
                  context.isArabic ? 'وسم +' : 'Tag +',
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? context.textSecondary : AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // AI Suggest Tags Chip
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: _isSuggesting ? null : _suggestAiTags,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkSkyBlue.withValues(alpha: 0.16)
                  : AppColors.skyBlueBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark
                    ? AppTheme.darkSkyBlue.withValues(alpha: 0.4)
                    : AppColors.skyBlue.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSuggesting)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                    ),
                  )
                else
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                  ),
                const SizedBox(width: 4),
                Text(
                  context.isArabic ? 'وسوم ذكية ✨' : 'AI Tags ✨',
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
