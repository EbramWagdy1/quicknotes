import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/database/migrations/migration_1_to_2.dart';
import 'package:quicknotes/core/database/migrations/migration_2_to_3.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Floor Database Migration 1 to 2 Tests', () {
    test('safely upgrades v1 schema to v2 without data loss', () async {
      // 1. Create a database with Version 1 schema
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE `notes` (
              `id` INTEGER PRIMARY KEY AUTOINCREMENT,
              `title` TEXT NOT NULL,
              `body` TEXT NOT NULL,
              `latitude` REAL,
              `longitude` REAL,
              `created_at` INTEGER NOT NULL,
              `updated_at` INTEGER NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX `index_notes_created_at` ON `notes` (`created_at`)',
          );
        },
      );

      // 2. Insert test data in Version 1 format
      final noteId = await db.insert('notes', {
        'title': 'Existing Note from v1',
        'body': 'This note was created before migration',
        'latitude': 37.422,
        'longitude': -122.084,
        'created_at': 1700000000000,
        'updated_at': 1700000000000,
      });

      expect(noteId, greaterThan(0));

      // 3. Execute Migration 1 to 2
      await migration1to2.migrate(db);

      // 4. Query the migrated table
      final rows = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [noteId],
      );
      expect(rows.length, 1);

      final migratedNote = rows.first;
      // Existing data intact:
      expect(migratedNote['title'], 'Existing Note from v1');
      expect(migratedNote['body'], 'This note was created before migration');
      expect(migratedNote['latitude'], 37.422);
      expect(migratedNote['longitude'], -122.084);
      // New columns added safely with proper defaults:
      expect(migratedNote['is_locked'], 0);
      expect(migratedNote['checklist_json'], isNull);

      // 5. Verify inserting v2 record with new columns works
      final newV2Id = await db.insert('notes', {
        'title': 'New v2 Note',
        'body': 'Secret content',
        'latitude': null,
        'longitude': null,
        'created_at': 1700000005000,
        'updated_at': 1700000005000,
        'is_locked': 1,
        'checklist_json': '[{"id":"1","title":"Item 1","isCompleted":true}]',
      });

      final v2Rows = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [newV2Id],
      );
      expect(v2Rows.length, 1);
      expect(v2Rows.first['is_locked'], 1);
      expect(
        v2Rows.first['checklist_json'],
        '[{"id":"1","title":"Item 1","isCompleted":true}]',
      );

      await db.close();
    });
  });

  group('Floor Database Migration 2 to 3 Tests', () {
    test('safely upgrades v2 schema to v3 with pin, favorite, trash and tags', () async {
      // 1. Create a database with Version 2 schema
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE `notes` (
              `id` INTEGER PRIMARY KEY AUTOINCREMENT,
              `title` TEXT NOT NULL,
              `body` TEXT NOT NULL,
              `latitude` REAL,
              `longitude` REAL,
              `created_at` INTEGER NOT NULL,
              `updated_at` INTEGER NOT NULL,
              `is_locked` INTEGER NOT NULL DEFAULT 0,
              `checklist_json` TEXT
            )
          ''');
          await db.execute(
            'CREATE INDEX `index_notes_created_at` ON `notes` (`created_at`)',
          );
        },
      );

      // 2. Insert test data in Version 2 format
      final noteId = await db.insert('notes', {
        'title': 'Existing v2 Note',
        'body': 'Content before v3 migration',
        'latitude': null,
        'longitude': null,
        'created_at': 1700000000000,
        'updated_at': 1700000000000,
        'is_locked': 0,
        'checklist_json': null,
      });

      expect(noteId, greaterThan(0));

      // 3. Execute Migration 2 to 3
      await migration2to3.migrate(db);

      // 4. Query the migrated table
      final rows = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [noteId],
      );
      expect(rows.length, 1);

      final migratedNote = rows.first;
      // Existing data intact:
      expect(migratedNote['title'], 'Existing v2 Note');
      expect(migratedNote['body'], 'Content before v3 migration');
      // New v3 columns added safely with defaults:
      expect(migratedNote['is_pinned'], 0);
      expect(migratedNote['is_favorite'], 0);
      expect(migratedNote['is_deleted'], 0);
      expect(migratedNote['tags_json'], isNull);

      // 5. Verify inserting v3 record with new columns works
      final newV3Id = await db.insert('notes', {
        'title': 'New v3 Note',
        'body': 'Tagged and pinned note',
        'latitude': null,
        'longitude': null,
        'created_at': 1700000010000,
        'updated_at': 1700000010000,
        'is_locked': 0,
        'checklist_json': null,
        'is_pinned': 1,
        'is_favorite': 1,
        'is_deleted': 0,
        'tags_json': '["Ideas","Work"]',
      });

      final v3Rows = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [newV3Id],
      );
      expect(v3Rows.length, 1);
      expect(v3Rows.first['is_pinned'], 1);
      expect(v3Rows.first['is_favorite'], 1);
      expect(v3Rows.first['tags_json'], '["Ideas","Work"]');

      await db.close();
    });
  });
}
