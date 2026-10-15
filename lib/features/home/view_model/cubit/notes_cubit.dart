import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quicknotes/core/database/daos/note_dao.dart';
import 'package:quicknotes/core/database/entities/note_entity.dart'
    show NoteEntity;
import 'package:quicknotes/core/di/injection.dart';
import 'package:quicknotes/core/services/gemini_service.dart';
import 'package:quicknotes/core/services/location_service.dart';
import 'package:quicknotes/core/services/notification_service.dart';
import 'package:quicknotes/core/utils/validators.dart';
import 'package:quicknotes/features/home/model/note_model.dart';
import 'package:quicknotes/features/home/model/subtask_model.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  final NoteDao noteDao;
  final LocationService locationService;
  final GeminiService? geminiService;
  final NotificationService? notificationService;
  final bool _enableForegroundMonitoring;
  Timer? _reminderTimer;
  final Set<int> _triggeredReminderIds = {};

  NotesCubit({
    required this.noteDao,
    LocationService? locationService,
    this.geminiService,
    NotificationService? notificationService,
    this._enableForegroundMonitoring = true,
  })  : locationService = locationService ?? LocationService(),
        notificationService = notificationService ??
            (sl.isRegistered<NotificationService>()
                ? sl<NotificationService>()
                : null),
        super(const NotesInitial());

  void _syncForegroundReminderMonitor() {
    if (!_enableForegroundMonitoring) return;
    if (state is! NotesLoaded) {
      _reminderTimer?.cancel();
      _reminderTimer = null;
      return;
    }
    final hasPendingReminders = (state as NotesLoaded).notes.any(
          (n) => n.reminderAt != null && !_triggeredReminderIds.contains(n.id),
        );

    if (hasPendingReminders) {
      if (_reminderTimer == null || !_reminderTimer!.isActive) {
        _startForegroundReminderMonitor();
      }
    } else {
      _reminderTimer?.cancel();
      _reminderTimer = null;
    }
  }

  void _startForegroundReminderMonitor() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkDueReminders();
    });
  }

  void _checkDueReminders() {
    if (state is! NotesLoaded) return;
    final notes = (state as NotesLoaded).notes;
    final now = DateTime.now();

    for (final note in notes) {
      if (note.id != null &&
          note.reminderAt != null &&
          !_triggeredReminderIds.contains(note.id)) {
        final diff = note.reminderAt!.difference(now);
        // If due now or within the last 90 seconds
        if (diff.inSeconds <= 0 && diff.inSeconds.abs() <= 90) {
          _triggeredReminderIds.add(note.id!);
          notificationService?.triggerImmediateAlarm(
            id: note.id!,
            title: note.title.trim(),
            body: _resolveReminderBody(
              body: note.body,
              subtasks: note.subtasks,
            ),
          );
          _syncForegroundReminderMonitor();
        }
      }
    }
  }

  // Load notes (separates active notes and trash notes)
  Future<void> loadNotes() async {
    final currentQuery = state is NotesLoaded
        ? (state as NotesLoaded).searchQuery
        : '';
    final currentFilter = state is NotesLoaded
        ? (state as NotesLoaded).filter
        : NoteFilter.all;
    final currentSort = state is NotesLoaded
        ? (state as NotesLoaded).sortOrder
        : NoteSortOrder.newest;
    final currentSelectedTag = state is NotesLoaded
        ? (state as NotesLoaded).selectedTag
        : null;

    emit(const NotesLoading());

    try {
      final entities = await noteDao.getAllNotes();
      final allNotes = entities.map(_toModel).toList();

      final activeNotes = allNotes.where((n) => !n.isDeleted).toList();
      final trashNotes = allNotes.where((n) => n.isDeleted).toList();

      emit(
        NotesLoaded(
          notes: activeNotes,
          trashNotes: trashNotes,
          searchQuery: currentQuery,
          filter: currentFilter,
          sortOrder: currentSort,
          selectedTag: currentSelectedTag,
        ),
      );
    } catch (e) {
      emit(NotesError(message: e.toString()));
    }
  }

  // Add note with tags, pin, favorite, subtasks, lock state, reminder, optimistic UI & background location
  Future<bool> addNote({
    required String title,
    required String body,
    double? latitude,
    double? longitude,
    bool isLocked = false,
    bool isPinned = false,
    bool isFavorite = false,
    List<String> tags = const [],
    List<Subtask> subtasks = const [],
    DateTime? reminderAt,
    String? audioPath,
    bool fetchLocationInBackground = false,
  }) async {
    final titleError = Validators.validateTitle(title);
    if (titleError != null) {
      emit(NotesError(message: titleError));
      return false;
    }

    final bodyError = Validators.validateBody(
      body,
      isChecklist: subtasks.isNotEmpty,
      hasAudio: audioPath != null && audioPath.isNotEmpty,
    );
    if (bodyError != null) {
      emit(NotesError(message: bodyError));
      return false;
    }

    try {
      if ((latitude == null) != (longitude == null)) {
        emit(const NotesError(message: 'Invalid location data.'));
        return false;
      }

      final now = DateTime.now();
      final entity = NoteEntity(
        title: title.trim(),
        body: body.trim(),
        latitude: latitude,
        longitude: longitude,
        createdAt: now,
        updatedAt: now,
        isLocked: isLocked,
        isPinned: isPinned,
        isFavorite: isFavorite,
        isDeleted: false,
        tagsJson: _tagsToJson(tags),
        checklistJson: _subtasksToJson(subtasks),
        reminderAt: reminderAt,
        audioPath: audioPath,
      );

      final id = await noteDao.insertNote(entity);

      final newNote = Note(
        id: id,
        title: title.trim(),
        body: body.trim(),
        latitude: latitude,
        longitude: longitude,
        createdAt: now,
        updatedAt: now,
        isLocked: isLocked,
        isPinned: isPinned,
        isFavorite: isFavorite,
        isDeleted: false,
        tags: tags,
        subtasks: subtasks,
        reminderAt: reminderAt,
        audioPath: audioPath,
      );

      if (state is NotesLoaded) {
        final current = state as NotesLoaded;
        emit(current.copyWith(notes: [newNote, ...current.notes]));
      } else {
        emit(NotesLoaded(notes: [newNote]));
      }

      if (reminderAt != null) {
        final diff = reminderAt.difference(now);
        if (diff.inSeconds <= 5 && diff.inSeconds >= -90) {
          _triggeredReminderIds.add(id);
          await notificationService?.triggerImmediateAlarm(
            id: id,
            title: title.trim(),
            body: _resolveReminderBody(body: body, subtasks: subtasks),
          );
        } else if (reminderAt.isAfter(now)) {
          _triggeredReminderIds.remove(id);
          await notificationService?.scheduleNoteReminder(
            id: id,
            title: title.trim(),
            body: _resolveReminderBody(body: body, subtasks: subtasks),
            reminderTime: reminderAt,
          );
        }
      }

      if (fetchLocationInBackground) {
        _resolveLocationForNote(id);
      }

      return true;
    } catch (e) {
      emit(NotesError(message: e.toString()));
      return false;
    }
  }

  // Update note
  Future<bool> updateNote(
    Note note, {
    bool fetchLocationInBackground = false,
  }) async {
    if (note.id == null) return false;

    final titleError = Validators.validateTitle(note.title);
    if (titleError != null) {
      emit(NotesError(message: titleError));
      return false;
    }

    final bodyError = Validators.validateBody(
      note.body,
      isChecklist: note.subtasks.isNotEmpty,
      hasAudio: note.hasAudio,
    );
    if (bodyError != null) {
      emit(NotesError(message: bodyError));
      return false;
    }

    try {
      final updatedNote = note.copyWith(updatedAt: DateTime.now());
      final entity = _toEntity(updatedNote);

      await noteDao.updateNote(entity);

      if (state is NotesLoaded) {
        final current = state as NotesLoaded;
        final updatedNotes = current.notes.map((item) {
          return item.id == updatedNote.id ? updatedNote : item;
        }).toList();

        emit(current.copyWith(notes: updatedNotes));
      }

      if (updatedNote.reminderAt != null) {
        final now = DateTime.now();
        final diff = updatedNote.reminderAt!.difference(now);
        if (diff.inSeconds <= 5 && diff.inSeconds >= -90) {
          _triggeredReminderIds.add(updatedNote.id!);
          await notificationService?.triggerImmediateAlarm(
            id: updatedNote.id!,
            title: updatedNote.title.trim(),
            body: _resolveReminderBody(
              body: updatedNote.body,
              subtasks: updatedNote.subtasks,
            ),
          );
        } else if (updatedNote.reminderAt!.isAfter(now)) {
          _triggeredReminderIds.remove(updatedNote.id!);
          await notificationService?.scheduleNoteReminder(
            id: updatedNote.id!,
            title: updatedNote.title.trim(),
            body: _resolveReminderBody(
              body: updatedNote.body,
              subtasks: updatedNote.subtasks,
            ),
            reminderTime: updatedNote.reminderAt!,
          );
        } else {
          await notificationService?.cancelReminder(updatedNote.id!);
        }
      } else {
        await notificationService?.cancelReminder(updatedNote.id!);
      }

      if (fetchLocationInBackground) {
        _resolveLocationForNote(note.id!);
      }

      return true;
    } catch (e) {
      emit(NotesError(message: e.toString()));
      return false;
    }
  }

  // Get note by id from state or database
  Future<Note?> getNoteById(int id) async {
    if (state is NotesLoaded) {
      final current = state as NotesLoaded;
      final found = current.notes.where((n) => n.id == id).firstOrNull;
      if (found != null) return found;
      final foundInTrash =
          current.trashNotes.where((n) => n.id == id).firstOrNull;
      if (foundInTrash != null) return foundInTrash;
    }

    try {
      final entity = await noteDao.getNoteById(id);
      if (entity != null) {
        return _toModel(entity);
      }
    } catch (_) {}
    return null;
  }

  // Snooze note reminder
  Future<bool> snoozeNoteById(
    int id, {
    Duration duration = const Duration(minutes: 10),
  }) async {
    final note = await getNoteById(id);
    if (note == null) return false;
    _triggeredReminderIds.remove(id);
    final newReminder = DateTime.now().add(duration);
    final updated = note.copyWith(reminderAt: newReminder);
    return updateNote(updated);
  }

  // Dismiss note reminder
  Future<bool> dismissReminderById(int id) async {
    final note = await getNoteById(id);
    if (note == null) return false;
    _triggeredReminderIds.add(id);
    await notificationService?.cancelReminder(id);
    final updated = note.copyWith(clearReminder: true);
    return updateNote(updated);
  }

  // Toggle subtask directly from home note card or editor
  Future<void> toggleSubtask({
    required Note note,
    required String subtaskId,
    bool? isCompleted,
  }) async {
    if (note.id == null) return;

    final updatedSubtasks = note.subtasks.map((s) {
      if (s.id == subtaskId) {
        return s.copyWith(isCompleted: isCompleted ?? !s.isCompleted);
      }
      return s;
    }).toList();

    final updatedNote = note.copyWith(
      subtasks: updatedSubtasks,
      updatedAt: DateTime.now(),
    );

    if (state is NotesLoaded) {
      final current = state as NotesLoaded;
      final updatedNotes = current.notes.map((item) {
        return item.id == note.id ? updatedNote : item;
      }).toList();
      emit(current.copyWith(notes: updatedNotes));
    }

    try {
      await noteDao.updateNote(_toEntity(updatedNote));
    } catch (e) {
      await loadNotes();
    }
  }

  // Toggle Pin Status
  Future<void> togglePin(Note note) async {
    if (note.id == null) return;
    final updated = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updated);
  }

  // Toggle Favorite Status
  Future<void> toggleFavorite(Note note) async {
    if (note.id == null) return;
    final updated = note.copyWith(isFavorite: !note.isFavorite);
    await updateNote(updated);
  }

  // Soft Delete: Move note to Trash
  Future<void> moveToTrash(Note note) async {
    if (note.id == null) return;

    notificationService?.cancelReminder(note.id!);

    final trashedNote = note.copyWith(
      isDeleted: true,
      updatedAt: DateTime.now(),
    );

    if (state is NotesLoaded) {
      final current = state as NotesLoaded;
      final updatedActive = current.notes.where((n) => n.id != note.id).toList();
      final updatedTrash = [trashedNote, ...current.trashNotes];
      emit(current.copyWith(notes: updatedActive, trashNotes: updatedTrash));
    }

    try {
      await noteDao.updateNote(_toEntity(trashedNote));
    } catch (e) {
      await loadNotes();
    }
  }

  /// Alias for backward compatibility - moves note to trash
  Future<void> deleteNote(Note note) => moveToTrash(note);

  // Restore note from Trash back to active notes
  Future<void> restoreNote(Note note) async {
    if (note.id == null) return;

    final restoredNote = note.copyWith(
      isDeleted: false,
      updatedAt: DateTime.now(),
    );

    if (state is NotesLoaded) {
      final current = state as NotesLoaded;
      final updatedTrash = current.trashNotes.where((n) => n.id != note.id).toList();
      final updatedActive = [restoredNote, ...current.notes];
      emit(current.copyWith(notes: updatedActive, trashNotes: updatedTrash));
    }

    if (restoredNote.reminderAt != null &&
        restoredNote.reminderAt!.isAfter(DateTime.now())) {
      notificationService?.scheduleNoteReminder(
        id: restoredNote.id!,
        title: restoredNote.title.trim(),
        body: _resolveReminderBody(
          body: restoredNote.body,
          subtasks: restoredNote.subtasks,
        ),
        reminderTime: restoredNote.reminderAt!,
      );
    }

    try {
      await noteDao.updateNote(_toEntity(restoredNote));
    } catch (e) {
      await loadNotes();
    }
  }

  // Permanently delete a single note
  Future<void> permanentlyDeleteNote(Note note) async {
    if (note.id == null) return;

    notificationService?.cancelReminder(note.id!);

    if (state is NotesLoaded) {
      final current = state as NotesLoaded;
      final updatedTrash = current.trashNotes.where((n) => n.id != note.id).toList();
      final updatedActive = current.notes.where((n) => n.id != note.id).toList();
      emit(current.copyWith(notes: updatedActive, trashNotes: updatedTrash));
    }

    try {
      final entity = await noteDao.getNoteById(note.id!);
      if (entity != null) {
        await noteDao.deleteNote(entity);
      }
    } catch (e) {
      await loadNotes();
    }
  }

  // Empty Trash (permanently deletes all items in trash)
  Future<void> emptyTrash() async {
    if (state is NotesLoaded) {
      final current = state as NotesLoaded;
      emit(current.copyWith(trashNotes: []));
    }

    try {
      await noteDao.emptyTrash();
    } catch (e) {
      await loadNotes();
    }
  }

  // Delete all notes (Shake to clean - moves all active notes to Trash)
  Future<bool> deleteAllNotes() async {
    final currentNotes = state is NotesLoaded
        ? (state as NotesLoaded).notes
        : <Note>[];

    if (currentNotes.isEmpty) return false;

    try {
      for (final note in currentNotes) {
        final trashed = note.copyWith(isDeleted: true, updatedAt: DateTime.now());
        await noteDao.updateNote(_toEntity(trashed));
      }

      if (state is NotesLoaded) {
        final current = state as NotesLoaded;
        final newTrash = [...currentNotes.map((n) => n.copyWith(isDeleted: true)), ...current.trashNotes];
        emit(current.copyWith(notes: [], trashNotes: newTrash));
      } else {
        emit(const NotesLoaded(notes: []));
      }

      return true;
    } catch (e) {
      emit(NotesError(message: e.toString()));
      return false;
    }
  }

  // Tag filter selection
  void setSelectedTag(String? tag) {
    if (state is NotesLoaded) {
      final current = state as NotesLoaded;
      if (tag == null) {
        emit(current.copyWith(clearSelectedTag: true));
      } else {
        emit(current.copyWith(selectedTag: tag));
      }
    }
  }

  // Search and Sort
  void setSearchQuery(String query) {
    if (state is NotesLoaded) {
      emit((state as NotesLoaded).copyWith(
        searchQuery: query,
        clearSemanticSearch: query.isEmpty,
      ));
    }
  }

  // Natural Language / Semantic Search with Gemini AI
  Future<void> performSemanticSearch(String query) async {
    final cleanQuery = query.trim();
    if (state is! NotesLoaded) return;
    final current = state as NotesLoaded;

    if (cleanQuery.isEmpty) {
      emit(current.copyWith(
        searchQuery: '',
        clearSemanticSearch: true,
        isSemanticSearching: false,
      ));
      return;
    }

    emit(current.copyWith(
      searchQuery: cleanQuery,
      isSemanticSearching: true,
    ));

    try {
      final gemini = geminiService ??
          (sl.isRegistered<GeminiService>()
              ? sl<GeminiService>()
              : GeminiService());
      final summaries = current.notes.map((n) {
        final tasks = n.subtasks.map((s) => s.title).join(', ');
        return {
          'id': n.id,
          'title': n.title,
          'body': n.body,
          'tasks': tasks,
        };
      }).toList();

      final matchedIds = await gemini.semanticSearch(
        query: cleanQuery,
        notesSummary: summaries,
      );

      if (state is NotesLoaded) {
        emit((state as NotesLoaded).copyWith(
          semanticMatchedIds: matchedIds,
          isSemanticSearching: false,
        ));
      }
    } catch (_) {
      if (state is NotesLoaded) {
        emit((state as NotesLoaded).copyWith(
          isSemanticSearching: false,
        ));
      }
    }
  }

  void clearSemanticSearch() {
    if (state is NotesLoaded) {
      emit((state as NotesLoaded).copyWith(
        clearSemanticSearch: true,
        isSemanticSearching: false,
      ));
    }
  }

  void setFilter(NoteFilter filter) {
    if (state is NotesLoaded) {
      emit((state as NotesLoaded).copyWith(filter: filter));
    }
  }

  void setSortOrder(NoteSortOrder sortOrder) {
    if (state is NotesLoaded) {
      emit((state as NotesLoaded).copyWith(sortOrder: sortOrder));
    }
  }

  void clearSearchAndFilters() {
    if (state is NotesLoaded) {
      emit(
        (state as NotesLoaded).copyWith(
          searchQuery: '',
          filter: NoteFilter.all,
          sortOrder: NoteSortOrder.newest,
          clearSelectedTag: true,
        ),
      );
    }
  }

  Future<void> _resolveLocationForNote(int noteId) async {
    try {
      final position = await locationService.getCurrentLocation();
      final existing = await noteDao.getNoteById(noteId);
      if (existing == null) return;

      final updatedEntity = NoteEntity(
        id: existing.id,
        title: existing.title,
        body: existing.body,
        latitude: position.latitude,
        longitude: position.longitude,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        isLocked: existing.isLocked,
        isPinned: existing.isPinned,
        isFavorite: existing.isFavorite,
        isDeleted: existing.isDeleted,
        tagsJson: existing.tagsJson,
        checklistJson: existing.checklistJson,
      );

      await noteDao.updateNote(updatedEntity);

      if (state is NotesLoaded) {
        final current = state as NotesLoaded;
        final updatedNotes = current.notes.map((item) {
          if (item.id == noteId) {
            return item.copyWith(
              latitude: position.latitude,
              longitude: position.longitude,
              updatedAt: DateTime.now(),
            );
          }
          return item;
        }).toList();

        emit(current.copyWith(notes: updatedNotes));
      }
    } catch (_) {
      // Silently ignore if background location fails
    }
  }

  String? _subtasksToJson(List<Subtask> subtasks) {
    if (subtasks.isEmpty) return null;
    return jsonEncode(subtasks.map((s) => s.toJson()).toList());
  }

  String? _tagsToJson(List<String> tags) {
    if (tags.isEmpty) return null;
    return jsonEncode(tags);
  }

  List<String> _tagsFromJson(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  NoteEntity _toEntity(Note note) {
    return NoteEntity(
      id: note.id,
      title: note.title.trim(),
      body: note.body.trim(),
      latitude: note.latitude,
      longitude: note.longitude,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      isLocked: note.isLocked,
      isPinned: note.isPinned,
      isFavorite: note.isFavorite,
      isDeleted: note.isDeleted,
      tagsJson: _tagsToJson(note.tags),
      checklistJson: _subtasksToJson(note.subtasks),
      reminderAt: note.reminderAt,
      audioPath: note.audioPath,
    );
  }

  Note _toModel(NoteEntity entity) {
    List<Subtask> subtasks = const [];
    if (entity.checklistJson != null && entity.checklistJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(entity.checklistJson!) as List<dynamic>;
        subtasks = decoded
            .map((item) => Subtask.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        subtasks = const [];
      }
    }

    return Note(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isLocked: entity.isLocked,
      isPinned: entity.isPinned,
      isFavorite: entity.isFavorite,
      isDeleted: entity.isDeleted,
      tags: _tagsFromJson(entity.tagsJson),
      subtasks: subtasks,
      reminderAt: entity.reminderAt,
      audioPath: entity.audioPath,
    );
  }

  String _resolveReminderBody({
    required String body,
    required List<Subtask> subtasks,
  }) {
    final trimmed = body.trim();
    if (trimmed.isNotEmpty) return trimmed;
    if (subtasks.isNotEmpty) {
      final pendingCount = subtasks.where((s) => !s.isCompleted).length;
      return pendingCount > 0
          ? '$pendingCount pending task(s)'
          : '${subtasks.length} task(s)';
    }
    return '';
  }

  @override
  Future<void> close() {
    _reminderTimer?.cancel();
    return super.close();
  }
}
