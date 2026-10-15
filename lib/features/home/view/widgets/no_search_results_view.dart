import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknotes/core/localization/l10n_extension.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class NoSearchResultsView extends StatelessWidget {
  final String query;

  const NoSearchResultsView({super.key, this.query = ''});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.containerFill,
                shape: BoxShape.circle,
                border: Border.all(color: context.borderColor, width: 1.5),
              ),
              child: Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: context.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.noSearchResults,
              style: AppTextStyle.headlineMedium.copyWith(
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? context.l10n.noSearchResultsSubtitle(query)
                  : context.l10n.noSearchResults,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySmall.copyWith(
                color: context.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.read<NotesCubit>().clearSearchAndFilters();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                context.l10n.clearSearch,
                style: AppTextStyle.labelLarge,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.borderColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
