part of 'notes_cubit.dart';

enum NoteFilter { all, withLocation, withoutLocation, locked, favorites }

enum NoteSortOrder { newest, oldest, titleAz }

abstract class NotesState {
  const NotesState();
}

final class NotesInitial extends NotesState {
  const NotesInitial();
}

final class NotesLoading extends NotesState {
  const NotesLoading();
}

final class NotesLoaded extends NotesState {
  final List<Note> notes;
  final List<Note> trashNotes;
  final String searchQuery;
  final NoteFilter filter;
  final NoteSortOrder sortOrder;
  final String? selectedTag;
  final List<int>? semanticMatchedIds;
  final bool isSemanticSearching;

  const NotesLoaded({
    required this.notes,
    this.trashNotes = const [],
    this.searchQuery = '',
    this.filter = NoteFilter.all,
    this.sortOrder = NoteSortOrder.newest,
    this.selectedTag,
    this.semanticMatchedIds,
    this.isSemanticSearching = false,
  });

  NotesLoaded copyWith({
    List<Note>? notes,
    List<Note>? trashNotes,
    String? searchQuery,
    NoteFilter? filter,
    NoteSortOrder? sortOrder,
    String? selectedTag,
    bool clearSelectedTag = false,
    List<int>? semanticMatchedIds,
    bool clearSemanticSearch = false,
    bool? isSemanticSearching,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      trashNotes: trashNotes ?? this.trashNotes,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedTag: clearSelectedTag ? null : (selectedTag ?? this.selectedTag),
      semanticMatchedIds: clearSemanticSearch
          ? null
          : (semanticMatchedIds ?? this.semanticMatchedIds),
      isSemanticSearching: isSemanticSearching ?? this.isSemanticSearching,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      semanticMatchedIds != null ||
      filter != NoteFilter.all ||
      sortOrder != NoteSortOrder.newest ||
      selectedTag != null;

  List<String> get allTags {
    final tagsSet = <String>{};
    for (final note in notes) {
      if (!note.isDeleted) {
        tagsSet.addAll(note.tags);
      }
    }
    return tagsSet.toList()..sort();
  }

  List<Note> get filteredNotes {
    final query = searchQuery.trim().toLowerCase();

    var result = notes.where((note) {
      if (note.isDeleted) return false;

      if (selectedTag != null && !note.tags.contains(selectedTag)) {
        return false;
      }

      if (semanticMatchedIds != null) {
        return note.id != null && semanticMatchedIds!.contains(note.id);
      }

      if (query.isEmpty) return true;
      final titleMatch = note.title.toLowerCase().contains(query);
      final bodyMatch = note.body.toLowerCase().contains(query);
      final subtaskMatch = note.subtasks.any(
        (s) => s.title.toLowerCase().contains(query),
      );
      final tagMatch = note.tags.any(
        (t) => t.toLowerCase().contains(query),
      );
      return titleMatch || bodyMatch || subtaskMatch || tagMatch;
    });

    switch (filter) {
      case NoteFilter.all:
        break;
      case NoteFilter.withLocation:
        result = result.where((note) => note.hasLocation);
        break;
      case NoteFilter.withoutLocation:
        result = result.where((note) => !note.hasLocation);
        break;
      case NoteFilter.locked:
        result = result.where((note) => note.isLocked);
        break;
      case NoteFilter.favorites:
        result = result.where((note) => note.isFavorite);
        break;
    }

    final list = result.toList();

    if (semanticMatchedIds != null) {
      list.sort((a, b) {
        final indexA = semanticMatchedIds!.indexOf(a.id ?? -1);
        final indexB = semanticMatchedIds!.indexOf(b.id ?? -1);
        return indexA.compareTo(indexB);
      });
      return list;
    }

    switch (sortOrder) {
      case NoteSortOrder.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSortOrder.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortOrder.titleAz:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    return list;
  }

  List<Note> get pinnedNotes =>
      filteredNotes.where((note) => note.isPinned).toList();

  List<Note> get unpinnedNotes =>
      filteredNotes.where((note) => !note.isPinned).toList();
}

final class NotesError extends NotesState {
  final String message;

  const NotesError({required this.message});
}
