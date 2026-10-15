import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quicknotes/core/database/entities/note_entity.dart';
import 'package:quicknotes/core/services/location_service.dart';
import 'package:quicknotes/features/home/view/notes_map_view.dart';
import 'package:quicknotes/features/home/view/widgets/note_map_preview_card.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

import '../view_model/cubit/notes_cubit_test.dart';

void main() {
  group('NotesMapView Widget Tests', () {
    late FakeNoteDao fakeDao;
    late NotesCubit cubit;

    setUp(() {
      fakeDao = FakeNoteDao();
      cubit = NotesCubit(noteDao: fakeDao);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('displays empty state when no notes have location', (tester) async {
      await cubit.loadNotes();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: const NotesMapView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0 notes on map'), findsOneWidget);
      expect(find.text('No Notes with Location Yet'), findsOneWidget);
      expect(find.text('Create Note'), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('displays notes on map and shows preview card on marker tap', (tester) async {
      final now = DateTime.now();
      await fakeDao.insertNote(
        NoteEntity(
          id: 1,
          title: 'Downtown Coffee',
          body: 'Check out the new cafe near Tahrir',
          latitude: 30.0444,
          longitude: 31.2357,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await fakeDao.insertNote(
        NoteEntity(
          id: 2,
          title: 'Zamalek Art Gallery',
          body: 'Visit the exhibition',
          latitude: 30.0580,
          longitude: 31.2220,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await cubit.loadNotes();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: const NotesMapView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Top bar header count
      expect(find.text('2 notes on map'), findsOneWidget);

      // Verify empty state is NOT shown
      expect(find.text('No Notes with Location Yet'), findsNothing);

      // Markers should be present
      expect(find.byType(MarkerLayer), findsOneWidget);
      expect(find.byIcon(Icons.location_on_rounded), findsNWidgets(2));

      // Preview card is initially closed
      expect(find.byType(NoteMapPreviewCard), findsNothing);

      // Tap on the first marker
      await tester.tap(find.byIcon(Icons.location_on_rounded).first);
      await tester.pumpAndSettle();

      // Preview card should be displayed
      expect(find.byType(NoteMapPreviewCard), findsOneWidget);
      expect(find.text('Zamalek Art Gallery'), findsOneWidget);

      // Close preview card
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(NoteMapPreviewCard), findsNothing);
    });

    testWidgets('opens notes list bottom sheet from top bar', (tester) async {
      final now = DateTime.now();
      await fakeDao.insertNote(
        NoteEntity(
          id: 1,
          title: 'Zamalek Park',
          body: 'Walking in the park',
          latitude: 30.0600,
          longitude: 31.2200,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await cubit.loadNotes();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: const NotesMapView(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap list button in app bar
      final listButton = find.byIcon(Icons.format_list_bulleted_rounded);
      expect(listButton, findsOneWidget);

      await tester.tap(listButton);
      await tester.pumpAndSettle();

      // Bottom sheet should be visible
      expect(find.text('Notes with Location (1)'), findsOneWidget);
      expect(find.text('Zamalek Park'), findsOneWidget);

      // Tap the list tile to select and dismiss sheet
      await tester.tap(find.text('Zamalek Park'));
      await tester.pumpAndSettle();

      // Sheet dismissed and note preview card selected
      expect(find.byType(NoteMapPreviewCard), findsOneWidget);
      expect(find.text('Zamalek Park'), findsOneWidget);
    });

    testWidgets('locating user triggers proximity alert when note is within 500m', (tester) async {
      final now = DateTime.now();
      await fakeDao.insertNote(
        NoteEntity(
          id: 1,
          title: 'Cafe Nearby',
          body: 'Favorite coffee shop',
          latitude: 30.0445,
          longitude: 31.2358,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await cubit.loadNotes();

      final fakeLocationService = FakeLocationService(
        Position(
          latitude: 30.0444,
          longitude: 31.2357,
          timestamp: now,
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotesCubit>.value(
            value: cubit,
            child: NotesMapView(locationService: fakeLocationService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap GPS locate button
      final myLocationButton = find.byTooltip('My current location');
      expect(myLocationButton, findsOneWidget);

      await tester.tap(myLocationButton);
      await tester.pumpAndSettle();

      // Proximity snackbar should be displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Nearby note: "Cafe Nearby"'), findsOneWidget);
    });
  });
}

class FakeLocationService extends LocationService {
  final Position fixedPosition;
  FakeLocationService(this.fixedPosition);

  @override
  Future<Position> getCurrentLocation() async => fixedPosition;
}

