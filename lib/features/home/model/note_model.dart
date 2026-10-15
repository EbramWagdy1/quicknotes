import 'package:quicknotes/features/home/model/subtask_model.dart';

class Note {
  final int? id;
  final String title;
  final String body;

  final double? latitude;
  final double? longitude;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isLocked;
  final List<Subtask> subtasks;

  final bool isPinned;
  final bool isFavorite;
  final bool isDeleted;
  final List<String> tags;
  final DateTime? reminderAt;
  final String? audioPath;

  const Note({
    this.id,
    required this.title,
    required this.body,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.isLocked = false,
    this.subtasks = const [],
    this.isPinned = false,
    this.isFavorite = false,
    this.isDeleted = false,
    this.tags = const [],
    this.reminderAt,
    this.audioPath,
  });

  bool get hasLocation {
    return latitude != null && longitude != null;
  }

  bool get hasSubtasks => subtasks.isNotEmpty;

  bool get hasTags => tags.isNotEmpty;

  bool get hasReminder => reminderAt != null;

  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;

  bool get isReminderOverdue =>
      reminderAt != null && reminderAt!.isBefore(DateTime.now());

  int get completedSubtasksCount => subtasks.where((s) => s.isCompleted).length;

  double get subtasksProgress =>
      hasSubtasks ? completedSubtasksCount / subtasks.length : 0.0;

  Note copyWith({
    int? id,
    String? title,
    String? body,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLocked,
    List<Subtask>? subtasks,
    bool? isPinned,
    bool? isFavorite,
    bool? isDeleted,
    List<String>? tags,
    DateTime? reminderAt,
    bool clearReminder = false,
    String? audioPath,
    bool clearAudio = false,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocked: isLocked ?? this.isLocked,
      subtasks: subtasks ?? this.subtasks,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      tags: tags ?? this.tags,
      reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      audioPath: clearAudio ? null : (audioPath ?? this.audioPath),
    );
  }
}
