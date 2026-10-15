import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/localization/generated/app_localizations.dart';
import 'package:quicknotes/core/localization/locale_cubit.dart';
import 'package:quicknotes/core/routing/app_router.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/theme/theme_cubit.dart';
import 'package:quicknotes/core/utils/app_strings.dart';
import 'package:quicknotes/core/utils/snackbar_helper.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class QuickNoteApp extends StatelessWidget {
  const QuickNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotesCubit>(
          create: (_) => sl<NotesCubit>()..loadNotes(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => sl.isRegistered<ThemeCubit>()
              ? sl<ThemeCubit>()
              : ThemeCubit(),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => sl.isRegistered<LocaleCubit>()
              ? sl<LocaleCubit>()
              : LocaleCubit(),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, currentLocale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                title: AppStrings.appName,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: currentLocale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: appRouter,
              );
            },
          );
        },
      ),
    );
  }
}

