import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/database/daos/note_dao.dart';
import 'package:quicknotes/core/database/entities/note_entity.dart';
import 'package:quicknotes/core/services/gemini_service.dart';
import 'package:quicknotes/core/services/notification_service.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';
import 'package:quicknotes/features/home/view_model/cubit/notes_cubit.dart';

class FakeNoteDao implements NoteDao {
  final List<NoteEntity> _entities = [];

  @override
  Future<List<NoteEntity>> getAllNotes() async => List.unmodifiable(_entities);

  @override
  Future<List<NoteEntity>> getAllActiveNotes() async =>
      _entities.where((e) => !e.isDeleted).toList();

  @override
  Future<List<NoteEntity>> getTrashNotes() async =>
      _entities.where((e) => e.isDeleted).toList();

  @override
  Future<NoteEntity?> getNoteById(int id) async {
    return _entities.cast<NoteEntity?>().firstWhere(
      (e) => e?.id == id,
      orElse: () => null,
    );
  }

  @override
  Future<int> insertNote(NoteEntity note) async {
    final id = note.id ?? (_entities.length + 1);
    final entity = NoteEntity(
      id: id,
      title: note.title,
      body: note.body,
      latitude: note.latitude,
      longitude: note.longitude,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isLocked: note.isLocked,
      checklistJson: note.checklistJson,
      isPinned: note.isPinned,
      isFavorite: note.isFavorite,
      isDeleted: note.isDeleted,
      tagsJson: note.tagsJson,
      reminderAt: note.reminderAt,
      audioPath: note.audioPath,
    );
    _entities.removeWhere((e) => e.id == id);
    _entities.insert(0, entity);
    return id;
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    final index = _entities.indexWhere((e) => e.id == note.id);
    if (index != -1) {
      _entities[index] = note;
    }
  }

  @override
  Future<void> deleteNote(NoteEntity note) async {
    _entities.removeWhere((e) => e.id == note.id);
  }

  @override
  Future<void> emptyTrash() async {
    _entities.removeWhere((e) => e.isDeleted);
  }

  @override
  Future<void> deleteAllNotes() async {
    _entities.clear();
  }
}

void main() {
  group('NotesCubit Comprehensive Feature Tests', () {
    late FakeNoteDao fakeDao;
    late NotesCubit cubit;

    setUp(() {
      fakeDao = FakeNoteDao();
      cubit = NotesCubit(noteDao: fakeDao);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is NotesInitial', () {
      expect(cubit.state, const NotesInitial());
    });

    test('addNote creates note with subtasks and locked status', () async {
      final success = await cubit.addNote(
        title: 'Meeting Notes',
        body: 'Discuss roadmap',
        isLocked: true,
        subtasks: [
          const Subtask(id: '1', title: 'Prepare slides', isCompleted: false),
          const Subtask(id: '2', title: 'Send invite', isCompleted: true),
        ],
      );

      expect(success, true);
      expect(cubit.state, isA<NotesLoaded>());
      final loaded = cubit.state as NotesLoaded;
      expect(loaded.notes.length, 1);

      final note = loaded.notes.first;
      expect(note.title, 'Meeting Notes');
      expect(note.isLocked, true);
      expect(note.subtasks.length, 2);
      expect(note.hasSubtasks, true);
      expect(note.completedSubtasksCount, 1);
      expect(note.subtasksProgress, 0.5);
    });

    test('toggleSubtask updates subtask completion in-place', () async {
      await cubit.addNote(
        title: 'Groceries',
        body: 'Weekly shopping',
        subtasks: [
          const Subtask(id: 's1', title: 'Apples', isCompleted: false),
        ],
      );

      final loaded = cubit.state as NotesLoaded;
      final note = loaded.notes.first;

      await cubit.toggleSubtask(note: note, subtaskId: 's1', isCompleted: true);

      final updatedLoaded = cubit.state as NotesLoaded;
      final updatedNote = updatedLoaded.notes.first;
      expect(updatedNote.subtasks.first.isCompleted, true);
      expect(updatedNote.completedSubtasksCount, 1);
    });

    test(
      'setSearchQuery filters notes by title, body, and subtask title',
      () async {
        await cubit.addNote(
          title: 'Flutter Architecture',
          body: 'Clean architecture and bloc pattern',
        );
        await cubit.addNote(
          title: 'Grocery List',
          body: 'Supermarket items',
          subtasks: [
            const Subtask(id: '1', title: 'Buy Oat Milk', isCompleted: false),
          ],
        );

        final loaded = cubit.state as NotesLoaded;
        expect(loaded.notes.length, 2);

        // Search by title
        cubit.setSearchQuery('architecture');
        expect((cubit.state as NotesLoaded).filteredNotes.length, 1);
        expect(
          (cubit.state as NotesLoaded).filteredNotes.first.title,
          'Flutter Architecture',
        );

        // Search by body
        cubit.setSearchQuery('supermarket');
        expect((cubit.state as NotesLoaded).filteredNotes.length, 1);
        expect(
          (cubit.state as NotesLoaded).filteredNotes.first.title,
          'Grocery List',
        );

        // Search by subtask item
        cubit.setSearchQuery('oat milk');
        expect((cubit.state as NotesLoaded).filteredNotes.length, 1);
        expect(
          (cubit.state as NotesLoaded).filteredNotes.first.title,
          'Grocery List',
        );

        // Query with zero matches
        cubit.setSearchQuery('nonexistent');
        expect((cubit.state as NotesLoaded).filteredNotes.isEmpty, true);

        // Reset
        cubit.clearSearchAndFilters();
        expect((cubit.state as NotesLoaded).filteredNotes.length, 2);
      },
    );

    test('setFilter filters by location and locked state', () async {
      await cubit.addNote(title: 'Plain Note', body: 'No extras');
      await cubit.addNote(
        title: 'Location Note',
        body: 'With coordinates',
        latitude: 40.7128,
        longitude: -74.0060,
      );
      await cubit.addNote(
        title: 'Secret Note',
        body: 'Confidential',
        isLocked: true,
      );

      final loaded = cubit.state as NotesLoaded;
      expect(loaded.notes.length, 3);

      // Filter with location
      cubit.setFilter(NoteFilter.withLocation);
      var filtered = (cubit.state as NotesLoaded).filteredNotes;
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Location Note');

      // Filter without location
      cubit.setFilter(NoteFilter.withoutLocation);
      filtered = (cubit.state as NotesLoaded).filteredNotes;
      expect(filtered.length, 2);

      // Filter locked
      cubit.setFilter(NoteFilter.locked);
      filtered = (cubit.state as NotesLoaded).filteredNotes;
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Secret Note');
    });

    test('setSortOrder sorts notes correctly', () async {
      await cubit.addNote(title: 'Banana', body: 'First');
      await Future.delayed(const Duration(milliseconds: 10));
      await cubit.addNote(title: 'Apple', body: 'Second');
      await Future.delayed(const Duration(milliseconds: 10));
      await cubit.addNote(title: 'Cherry', body: 'Third');

      // Default: Newest first
      var filtered = (cubit.state as NotesLoaded).filteredNotes;
      expect(filtered.first.title, 'Cherry');
      expect(filtered.last.title, 'Banana');

      // Oldest first
      cubit.setSortOrder(NoteSortOrder.oldest);
      filtered = (cubit.state as NotesLoaded).filteredNotes;
      expect(filtered.first.title, 'Banana');
      expect(filtered.last.title, 'Cherry');

      // Title A-Z
      cubit.setSortOrder(NoteSortOrder.titleAz);
      filtered = (cubit.state as NotesLoaded).filteredNotes;
      expect(filtered.first.title, 'Apple');
      expect(filtered[1].title, 'Banana');
      expect(filtered.last.title, 'Cherry');
    });

    test('deleteNote and restoreNote work with new fields', () async {
      await cubit.addNote(
        title: 'Task Note',
        body: 'To be deleted',
        isLocked: true,
        subtasks: [
          const Subtask(id: '1', title: 'Subtask 1', isCompleted: true),
        ],
      );

      final note = (cubit.state as NotesLoaded).notes.first;

      await cubit.deleteNote(note);
      expect((cubit.state as NotesLoaded).notes.isEmpty, true);

      await cubit.restoreNote(note);
      expect((cubit.state as NotesLoaded).notes.length, 1);
      final restored = (cubit.state as NotesLoaded).notes.first;
      expect(restored.title, 'Task Note');
      expect(restored.isLocked, true);
      expect(restored.subtasks.first.isCompleted, true);
    });

    test('deleteAllNotes empties list', () async {
      await cubit.addNote(title: 'Note 1', body: 'Body 1');
      await cubit.addNote(title: 'Note 2', body: 'Body 2');

      final success = await cubit.deleteAllNotes();
      expect(success, true);
      expect((cubit.state as NotesLoaded).notes.isEmpty, true);
    });

    test('togglePin updates pinned status and state separation', () async {
      await cubit.addNote(title: 'Regular Note', body: 'Normal');
      await cubit.addNote(title: 'Pinned Note', body: 'Important', isPinned: true);

      final state = cubit.state as NotesLoaded;
      expect(state.pinnedNotes.length, 1);
      expect(state.unpinnedNotes.length, 1);
      expect(state.pinnedNotes.first.title, 'Pinned Note');

      // Unpin it
      await cubit.togglePin(state.pinnedNotes.first);
      final updatedState = cubit.state as NotesLoaded;
      expect(updatedState.pinnedNotes.length, 0);
      expect(updatedState.unpinnedNotes.length, 2);
    });

    test('toggleFavorite updates favorite status and filtering', () async {
      await cubit.addNote(title: 'Note 1', body: 'Body 1', isFavorite: false);
      final note = (cubit.state as NotesLoaded).notes.first;

      await cubit.toggleFavorite(note);
      expect((cubit.state as NotesLoaded).notes.first.isFavorite, true);

      // Test favorite filter
      cubit.setFilter(NoteFilter.favorites);
      expect((cubit.state as NotesLoaded).filteredNotes.length, 1);

      cubit.setFilter(NoteFilter.all);
      expect((cubit.state as NotesLoaded).filter, NoteFilter.all);
    });

    test('tags management and filtering work correctly', () async {
      await cubit.addNote(
        title: 'Work Note',
        body: 'Work tasks',
        tags: ['Work', 'Important'],
      );
      await cubit.addNote(
        title: 'Personal Note',
        body: 'Groceries',
        tags: ['Personal'],
      );

      final state = cubit.state as NotesLoaded;
      expect(state.allTags.contains('Work'), true);
      expect(state.allTags.contains('Important'), true);
      expect(state.allTags.contains('Personal'), true);

      // Filter by tag
      cubit.setSelectedTag('Work');
      final filteredState = cubit.state as NotesLoaded;
      expect(filteredState.selectedTag, 'Work');
      expect(filteredState.filteredNotes.length, 1);
      expect(filteredState.filteredNotes.first.title, 'Work Note');

      // Clear tag filter
      cubit.setSelectedTag(null);
      expect((cubit.state as NotesLoaded).filteredNotes.length, 2);
    });

    test('trash operations: moveToTrash, restoreNote, emptyTrash', () async {
      await cubit.addNote(title: 'Note to trash', body: 'Bye');
      final note = (cubit.state as NotesLoaded).notes.first;

      await cubit.moveToTrash(note);
      final trashedState = cubit.state as NotesLoaded;
      expect(trashedState.notes.isEmpty, true);
      expect(trashedState.trashNotes.length, 1);
      expect(trashedState.trashNotes.first.title, 'Note to trash');

      // Restore it
      await cubit.restoreNote(trashedState.trashNotes.first);
      final restoredState = cubit.state as NotesLoaded;
      expect(restoredState.notes.length, 1);
      expect(restoredState.trashNotes.isEmpty, true);

      // Move to trash again and empty trash
      await cubit.moveToTrash(restoredState.notes.first);
      await cubit.emptyTrash();
      final emptiedState = cubit.state as NotesLoaded;
      expect(emptiedState.notes.isEmpty, true);
      expect(emptiedState.trashNotes.isEmpty, true);
    });

    test('semantic search ranks notes by Gemini match IDs and clears correctly', () async {
      await cubit.addNote(title: 'Groceries List', body: 'Milk, cheese, eggs');
      await cubit.addNote(title: 'Work Project', body: 'Flutter clean architecture');

      final loaded = cubit.state as NotesLoaded;
      final groceryId = loaded.notes.firstWhere((n) => n.title == 'Groceries List').id!;

      final fakeGemini = FakeGeminiService(
        semanticSearchResponse: [groceryId],
      );

      final semanticCubit = NotesCubit(
        noteDao: fakeDao,
        geminiService: fakeGemini,
      );

      await semanticCubit.loadNotes();
      await semanticCubit.performSemanticSearch('What food to buy?');

      final searchState = semanticCubit.state as NotesLoaded;
      expect(searchState.semanticMatchedIds, [groceryId]);
      expect(searchState.isSemanticSearching, false);
      expect(searchState.filteredNotes.first.id, groceryId);

      semanticCubit.clearSemanticSearch();
      final clearedState = semanticCubit.state as NotesLoaded;
      expect(clearedState.semanticMatchedIds, null);

      await semanticCubit.close();
    });

    test('addNote with future reminder schedules notification', () async {
      final fakeNotifications = FakeNotificationService();
      final reminderCubit = NotesCubit(
        noteDao: fakeDao,
        notificationService: fakeNotifications,
      );

      final futureTime = DateTime.now().add(const Duration(hours: 2));
      final success = await reminderCubit.addNote(
        title: 'Doctor Appointment',
        body: 'Dentist at 3 PM',
        reminderAt: futureTime,
      );

      expect(success, true);
      expect(fakeNotifications.scheduledReminderIds, isNotEmpty);

      final state = reminderCubit.state as NotesLoaded;
      expect(state.notes.first.hasReminder, true);
      expect(state.notes.first.reminderAt, futureTime);

      await reminderCubit.close();
    });

    test('updateNote cancels reminder when cleared', () async {
      final fakeNotifications = FakeNotificationService();
      final reminderCubit = NotesCubit(
        noteDao: fakeDao,
        notificationService: fakeNotifications,
      );

      final futureTime = DateTime.now().add(const Duration(hours: 2));
      await reminderCubit.addNote(
        title: 'Doctor Appointment',
        body: 'Dentist at 3 PM',
        reminderAt: futureTime,
      );

      final state = reminderCubit.state as NotesLoaded;
      final addedNote = state.notes.first;

      await reminderCubit.updateNote(addedNote.copyWith(clearReminder: true));
      expect(fakeNotifications.cancelledReminderIds, contains(addedNote.id));

      await reminderCubit.close();
    });

    test('moveToTrash cancels scheduled reminder', () async {
      final fakeNotifications = FakeNotificationService();
      final reminderCubit = NotesCubit(
        noteDao: fakeDao,
        notificationService: fakeNotifications,
      );

      final futureTime = DateTime.now().add(const Duration(hours: 2));
      await reminderCubit.addNote(
        title: 'Task to Trash',
        body: 'Content',
        reminderAt: futureTime,
      );

      final state = reminderCubit.state as NotesLoaded;
      final addedNote = state.notes.first;

      await reminderCubit.moveToTrash(addedNote);
      expect(fakeNotifications.cancelledReminderIds, contains(addedNote.id));

      await reminderCubit.close();
    });

    test('addNote and updateNote support voice recordings with empty body', () async {
      // Adding note with audioPath and empty body should succeed
      final added = await cubit.addNote(
        title: 'Voice Recording Note',
        body: '',
        audioPath: '/path/to/voice_note_123.m4a',
      );
      expect(added, true);

      final state = cubit.state as NotesLoaded;
      expect(state.notes.length, 1);
      final note = state.notes.first;
      expect(note.title, 'Voice Recording Note');
      expect(note.audioPath, '/path/to/voice_note_123.m4a');
      expect(note.hasAudio, true);

      // Updating note audioPath
      final updated = await cubit.updateNote(
        note.copyWith(audioPath: '/path/to/voice_note_updated.m4a'),
      );
      expect(updated, true);

      final updatedState = cubit.state as NotesLoaded;
      expect(
        updatedState.notes.first.audioPath,
        '/path/to/voice_note_updated.m4a',
      );
    });
  });
}

class FakeNotificationService extends Fake implements NotificationService {
  final List<int> scheduledReminderIds = [];
  final List<int> cancelledReminderIds = [];

  @override
  Future<bool> scheduleNoteReminder({
    required int id,
    required String title,
    required String body,
    required DateTime reminderTime,
  }) async {
    scheduledReminderIds.add(id);
    return true;
  }

  @override
  Future<void> cancelReminder(int id) async {
    cancelledReminderIds.add(id);
  }
}

class FakeGeminiService extends Fake implements GeminiService {
  final List<int> semanticSearchResponse;

  FakeGeminiService({this.semanticSearchResponse = const []});

  @override
  Future<List<int>> semanticSearch({
    required String query,
    required List<Map<String, dynamic>> notesSummary,
  }) async {
    return semanticSearchResponse;
  }
}
