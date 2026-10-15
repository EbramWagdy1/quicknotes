// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  NoteDao? _noteDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 5,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `notes` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `body` TEXT NOT NULL, `latitude` REAL, `longitude` REAL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `is_locked` INTEGER NOT NULL, `checklist_json` TEXT, `is_pinned` INTEGER NOT NULL, `is_favorite` INTEGER NOT NULL, `is_deleted` INTEGER NOT NULL, `tags_json` TEXT, `reminder_at` INTEGER, `audio_path` TEXT)');
        await database.execute(
            'CREATE INDEX `index_notes_created_at` ON `notes` (`created_at`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  NoteDao get noteDao {
    return _noteDaoInstance ??= _$NoteDao(database, changeListener);
  }
}

class _$NoteDao extends NoteDao {
  _$NoteDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _noteEntityInsertionAdapter = InsertionAdapter(
            database,
            'notes',
            (NoteEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'body': item.body,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt),
                  'is_locked': item.isLocked ? 1 : 0,
                  'checklist_json': item.checklistJson,
                  'is_pinned': item.isPinned ? 1 : 0,
                  'is_favorite': item.isFavorite ? 1 : 0,
                  'is_deleted': item.isDeleted ? 1 : 0,
                  'tags_json': item.tagsJson,
                  'reminder_at':
                      _nullableDateTimeConverter.encode(item.reminderAt),
                  'audio_path': item.audioPath
                }),
        _noteEntityUpdateAdapter = UpdateAdapter(
            database,
            'notes',
            ['id'],
            (NoteEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'body': item.body,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt),
                  'is_locked': item.isLocked ? 1 : 0,
                  'checklist_json': item.checklistJson,
                  'is_pinned': item.isPinned ? 1 : 0,
                  'is_favorite': item.isFavorite ? 1 : 0,
                  'is_deleted': item.isDeleted ? 1 : 0,
                  'tags_json': item.tagsJson,
                  'reminder_at':
                      _nullableDateTimeConverter.encode(item.reminderAt),
                  'audio_path': item.audioPath
                }),
        _noteEntityDeletionAdapter = DeletionAdapter(
            database,
            'notes',
            ['id'],
            (NoteEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'body': item.body,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'created_at': _dateTimeConverter.encode(item.createdAt),
                  'updated_at': _dateTimeConverter.encode(item.updatedAt),
                  'is_locked': item.isLocked ? 1 : 0,
                  'checklist_json': item.checklistJson,
                  'is_pinned': item.isPinned ? 1 : 0,
                  'is_favorite': item.isFavorite ? 1 : 0,
                  'is_deleted': item.isDeleted ? 1 : 0,
                  'tags_json': item.tagsJson,
                  'reminder_at':
                      _nullableDateTimeConverter.encode(item.reminderAt),
                  'audio_path': item.audioPath
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<NoteEntity> _noteEntityInsertionAdapter;

  final UpdateAdapter<NoteEntity> _noteEntityUpdateAdapter;

  final DeletionAdapter<NoteEntity> _noteEntityDeletionAdapter;

  @override
  Future<List<NoteEntity>> getAllNotes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes ORDER BY is_pinned DESC, created_at DESC',
        mapper: (Map<String, Object?> row) => NoteEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            body: row['body'] as String,
            latitude: row['latitude'] as double?,
            longitude: row['longitude'] as double?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int),
            isLocked: (row['is_locked'] as int) != 0,
            checklistJson: row['checklist_json'] as String?,
            isPinned: (row['is_pinned'] as int) != 0,
            isFavorite: (row['is_favorite'] as int) != 0,
            isDeleted: (row['is_deleted'] as int) != 0,
            tagsJson: row['tags_json'] as String?,
            reminderAt:
                _nullableDateTimeConverter.decode(row['reminder_at'] as int?),
            audioPath: row['audio_path'] as String?));
  }

  @override
  Future<List<NoteEntity>> getAllActiveNotes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes WHERE is_deleted = 0 ORDER BY is_pinned DESC, created_at DESC',
        mapper: (Map<String, Object?> row) => NoteEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            body: row['body'] as String,
            latitude: row['latitude'] as double?,
            longitude: row['longitude'] as double?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int),
            isLocked: (row['is_locked'] as int) != 0,
            checklistJson: row['checklist_json'] as String?,
            isPinned: (row['is_pinned'] as int) != 0,
            isFavorite: (row['is_favorite'] as int) != 0,
            isDeleted: (row['is_deleted'] as int) != 0,
            tagsJson: row['tags_json'] as String?,
            reminderAt:
                _nullableDateTimeConverter.decode(row['reminder_at'] as int?),
            audioPath: row['audio_path'] as String?));
  }

  @override
  Future<List<NoteEntity>> getTrashNotes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM notes WHERE is_deleted = 1 ORDER BY updated_at DESC',
        mapper: (Map<String, Object?> row) => NoteEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            body: row['body'] as String,
            latitude: row['latitude'] as double?,
            longitude: row['longitude'] as double?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int),
            isLocked: (row['is_locked'] as int) != 0,
            checklistJson: row['checklist_json'] as String?,
            isPinned: (row['is_pinned'] as int) != 0,
            isFavorite: (row['is_favorite'] as int) != 0,
            isDeleted: (row['is_deleted'] as int) != 0,
            tagsJson: row['tags_json'] as String?,
            reminderAt:
                _nullableDateTimeConverter.decode(row['reminder_at'] as int?),
            audioPath: row['audio_path'] as String?));
  }

  @override
  Future<NoteEntity?> getNoteById(int id) async {
    return _queryAdapter.query('SELECT * FROM notes WHERE id = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => NoteEntity(
            id: row['id'] as int?,
            title: row['title'] as String,
            body: row['body'] as String,
            latitude: row['latitude'] as double?,
            longitude: row['longitude'] as double?,
            createdAt: _dateTimeConverter.decode(row['created_at'] as int),
            updatedAt: _dateTimeConverter.decode(row['updated_at'] as int),
            isLocked: (row['is_locked'] as int) != 0,
            checklistJson: row['checklist_json'] as String?,
            isPinned: (row['is_pinned'] as int) != 0,
            isFavorite: (row['is_favorite'] as int) != 0,
            isDeleted: (row['is_deleted'] as int) != 0,
            tagsJson: row['tags_json'] as String?,
            reminderAt:
                _nullableDateTimeConverter.decode(row['reminder_at'] as int?),
            audioPath: row['audio_path'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> emptyTrash() async {
    await _queryAdapter.queryNoReturn('DELETE FROM notes WHERE is_deleted = 1');
  }

  @override
  Future<void> deleteAllNotes() async {
    await _queryAdapter.queryNoReturn('DELETE FROM notes');
  }

  @override
  Future<int> insertNote(NoteEntity note) {
    return _noteEntityInsertionAdapter.insertAndReturnId(
        note, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateNote(NoteEntity note) async {
    await _noteEntityUpdateAdapter.update(note, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteNote(NoteEntity note) async {
    await _noteEntityDeletionAdapter.delete(note);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _nullableDateTimeConverter = NullableDateTimeConverter();
