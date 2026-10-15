import 'package:floor/floor.dart';
import 'package:quicknotes/core/database/entities/note_entity.dart';

@dao
abstract class NoteDao {
  @Query('SELECT * FROM notes ORDER BY is_pinned DESC, created_at DESC')
  Future<List<NoteEntity>> getAllNotes();

  @Query('SELECT * FROM notes WHERE is_deleted = 0 ORDER BY is_pinned DESC, created_at DESC')
  Future<List<NoteEntity>> getAllActiveNotes();

  @Query('SELECT * FROM notes WHERE is_deleted = 1 ORDER BY updated_at DESC')
  Future<List<NoteEntity>> getTrashNotes();

  @Query('SELECT * FROM notes WHERE id = :id LIMIT 1')
  Future<NoteEntity?> getNoteById(int id);

  @insert
  Future<int> insertNote(NoteEntity note);

  @update
  Future<void> updateNote(NoteEntity note);

  @delete
  Future<void> deleteNote(NoteEntity note);

  @Query('DELETE FROM notes WHERE is_deleted = 1')
  Future<void> emptyTrash();

  @Query('DELETE FROM notes')
  Future<void> deleteAllNotes();
}
