import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_colors.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class SearchHeader extends StatefulWidget {
  final String initialQuery;

  const SearchHeader({super.key, this.initialQuery = ''});

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isAiSearch = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SearchHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery &&
        widget.initialQuery != _controller.text) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (!_isAiSearch) {
      context.read<NotesCubit>().setSearchQuery(value);
    }
    setState(() {});
  }

  void _onSubmitted(String value) {
    if (_isAiSearch) {
      context.read<NotesCubit>().performSemanticSearch(value);
    } else {
      context.read<NotesCubit>().setSearchQuery(value);
    }
  }

  void _clearSearch() {
    _controller.clear();
    final cubit = context.read<NotesCubit>();
    cubit.setSearchQuery('');
    cubit.clearSemanticSearch();
    setState(() {});
  }

  void _toggleAiSearch() {
    setState(() {
      _isAiSearch = !_isAiSearch;
    });

    final cubit = context.read<NotesCubit>();
    if (_isAiSearch && _controller.text.trim().isNotEmpty) {
      cubit.performSemanticSearch(_controller.text);
    } else if (!_isAiSearch) {
      cubit.clearSemanticSearch();
      cubit.setSearchQuery(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocBuilder<NotesCubit, NotesState>(
      buildWhen: (prev, curr) {
        if (prev is NotesLoaded && curr is NotesLoaded) {
          return prev.isSemanticSearching != curr.isSemanticSearching ||
              prev.semanticMatchedIds != curr.semanticMatchedIds;
        }
        return false;
      },
      builder: (context, state) {
        final isSearchingAi = state is NotesLoaded && state.isSemanticSearching;

        final effectiveGlassColor = _isAiSearch
            ? (isDark
                ? const Color(0xFF0C4A6E).withValues(alpha: 0.75)
                : const Color(0xFFE0F2FE).withValues(alpha: 0.85))
            : (isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.72)
                : Colors.white.withValues(alpha: 0.82));

        final effectiveBorderColor = _isAiSearch
            ? (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue)
            : (_isFocused
                ? (isDark ? AppTheme.darkSkyBlue : AppColors.primary)
                : (isDark
                    ? const Color(0xFF334155).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.85)));

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9999),
            boxShadow: _isFocused || _isAiSearch
                ? [
                    BoxShadow(
                      color: (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue)
                          .withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                decoration: BoxDecoration(
                  color: effectiveGlassColor,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: (_isFocused || _isAiSearch) ? 1.5 : 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(
                      _isAiSearch ? Icons.auto_awesome_rounded : Icons.search_rounded,
                      color: _isAiSearch
                          ? (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue)
                          : (_isFocused
                              ? (isDark ? AppTheme.darkSkyBlue : AppColors.primary)
                              : context.textMuted),
                      size: 20,
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onChanged,
                  onSubmitted: _onSubmitted,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: _isAiSearch
                        ? (context.isArabic
                            ? 'ابحث بالمعنى: مثلاً "مشتريات الأسبوع الماضي"...'
                            : 'Search by meaning: e.g. "shopping last week"...')
                        : context.l10n.searchPlaceholder,
                    hintStyle: TextStyle(
                      fontFamily: AppTextStyle.fontFamily,
                      color: _isAiSearch
                          ? (isDark
                              ? AppTheme.darkSkyBlue.withValues(alpha: 0.8)
                              : AppColors.skyBlue.withValues(alpha: 0.7))
                          : context.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontFamily: AppTextStyle.fontFamily,
                    color: context.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              if (isSearchingAi)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.skyBlue,
                    ),
                  ),
                ),

              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: context.chipBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: context.textSecondary,
                    ),
                  ),
                ),

              // AI Search Toggle Chip
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _toggleAiSearch,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isAiSearch
                        ? (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue)
                        : context.chipBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: _isAiSearch
                            ? (isDark ? AppTheme.darkCanvas : Colors.white)
                            : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI',
                        style: TextStyle(
                          fontFamily: AppTextStyle.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _isAiSearch
                              ? (isDark ? AppTheme.darkCanvas : Colors.white)
                              : (isDark ? AppTheme.darkSkyBlue : AppColors.skyBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
},
    );
  }
}
