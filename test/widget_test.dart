import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/app/quick_note.dart';
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/services/biometric_service.dart';
import 'package:quicknotes/core/services/shake_service.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

import 'features/home/view_model/cubit/notes_cubit_test.dart';

void main() {
  setUp(() async {
    await sl.reset();
    final fakeDao = FakeNoteDao();
    sl.registerLazySingleton<ShakeService>(() => ShakeService());
    sl.registerLazySingleton<BiometricService>(() => BiometricService());
    sl.registerFactory<NotesCubit>(() => NotesCubit(noteDao: fakeDao));
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('QuickNoteApp launches and navigates to Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const QuickNoteApp());
    await tester.pump();

    expect(find.byType(QuickNoteApp), findsOneWidget);

    // Fast-forward past splash timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
