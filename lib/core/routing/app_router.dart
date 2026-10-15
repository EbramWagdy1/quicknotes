import 'package:go_router/go_router.dart';
import 'package:quicknotes/core/routing/app_routes.dart';
import 'package:quicknotes/features/alarm/view/alarm_clock_screen.dart';
import 'package:quicknotes/features/calendar/view/calendar_view.dart';
import 'package:quicknotes/features/showcase/view/showcase_screen.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/view/home_view.dart';
import 'package:quicknotes/features/home/view/note_form_screen.dart';
import 'package:quicknotes/features/home/view/notes_map_view.dart';
import 'package:quicknotes/features/splash/view/splash_view.dart';
import 'package:quicknotes/features/trash/view/trash_view.dart';

abstract final class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppRoutes.addNote,
        name: 'addNote',
        builder: (context, state) => const NoteFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.editNote,
        name: 'editNote',
        builder: (context, state) {
          final note = state.extra as Note?;
          return NoteFormScreen(note: note);
        },
      ),
      GoRoute(
        path: AppRoutes.trash,
        name: 'trash',
        builder: (context, state) => const TrashView(),
      ),
      GoRoute(
        path: AppRoutes.notesMap,
        name: 'notesMap',
        builder: (context, state) => const NotesMapView(),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        builder: (context, state) => const CalendarView(),
      ),
      GoRoute(
        path: AppRoutes.showcase,
        name: 'showcase',
        builder: (context, state) => const ShowcaseScreen(),
      ),
      GoRoute(
        path: AppRoutes.alarm,
        name: 'alarm',
        builder: (context, state) {
          if (state.extra is Note) {
            return AlarmClockScreen(note: state.extra as Note);
          } else if (state.extra is int) {
            return AlarmClockScreen(noteId: state.extra as int);
          }
          return const AlarmClockScreen();
        },
      ),
    ],
  );
}

final GoRouter appRouter = AppRouter.router;
