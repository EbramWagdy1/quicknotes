import 'package:floor/floor.dart';

@Entity(
  tableName: 'notes',
  indices: [
    Index(value: ['created_at']),
  ],
)
class NoteEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String body;

  final double? latitude;
  final double? longitude;

  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;

  @ColumnInfo(name: 'updated_at')
  final DateTime updatedAt;

  @ColumnInfo(name: 'is_locked')
  final bool isLocked;

  @ColumnInfo(name: 'checklist_json')
  final String? checklistJson;

  @ColumnInfo(name: 'is_pinned')
  final bool isPinned;

  @ColumnInfo(name: 'is_favorite')
  final bool isFavorite;

  @ColumnInfo(name: 'is_deleted')
  final bool isDeleted;

  @ColumnInfo(name: 'tags_json')
  final String? tagsJson;

  @ColumnInfo(name: 'reminder_at')
  final DateTime? reminderAt;

  @ColumnInfo(name: 'audio_path')
  final String? audioPath;

  NoteEntity({
    this.id,
    required this.title,
    required this.body,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.isLocked = false,
    this.checklistJson,
    this.isPinned = false,
    this.isFavorite = false,
    this.isDeleted = false,
    this.tagsJson,
    this.reminderAt,
    this.audioPath,
  });
}
