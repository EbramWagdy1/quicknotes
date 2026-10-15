import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/database/migrations/migration_3_to_4.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Floor Database Migration 3 to 4 Tests', () {
    test('safely upgrades v3 schema to v4 by adding reminder_at column without data loss', () async {
      // 1. Create a database with Version 3 schema
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 3,
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
              `checklist_json` TEXT,
              `is_pinned` INTEGER NOT NULL DEFAULT 0,
              `is_favorite` INTEGER NOT NULL DEFAULT 0,
              `is_deleted` INTEGER NOT NULL DEFAULT 0,
              `tags_json` TEXT
            )
          ''');
          await db.execute(
            'CREATE INDEX `index_notes_created_at` ON `notes` (`created_at`)',
          );
        },
      );

      // 2. Insert test data in Version 3 format
      final noteId = await db.insert('notes', {
        'title': 'Existing v3 Note',
        'body': 'Content before v4 migration',
        'latitude': 30.0444,
        'longitude': 31.2357,
        'created_at': 1700000000000,
        'updated_at': 1700000000000,
        'is_locked': 1,
        'checklist_json': '[{"id":"1","title":"Item 1","isCompleted":false}]',
        'is_pinned': 1,
        'is_favorite': 1,
        'is_deleted': 0,
        'tags_json': '["Important","Urgent"]',
      });

      expect(noteId, greaterThan(0));

      // 3. Execute Migration 3 to 4
      await migration3to4.migrate(db);

      // 4. Query the migrated table
      final rows = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [noteId],
      );
      expect(rows.length, 1);

      final migratedNote = rows.first;
      // Existing data intact:
      expect(migratedNote['title'], 'Existing v3 Note');
      expect(migratedNote['body'], 'Content before v4 migration');
      expect(migratedNote['latitude'], 30.0444);
      expect(migratedNote['longitude'], 31.2357);
      expect(migratedNote['is_pinned'], 1);
      expect(migratedNote['is_favorite'], 1);
      expect(migratedNote['is_deleted'], 0);
      expect(migratedNote['tags_json'], '["Important","Urgent"]');
      // New v4 column reminder_at is null for existing rows:
      expect(migratedNote['reminder_at'], isNull);

      // 5. Verify inserting v4 record with reminder_at works
      final scheduledTimestamp = 1750000000000;
      final newV4Id = await db.insert('notes', {
        'title': 'New v4 Note with Reminder',
        'body': 'Call doctor at 5 PM',
        'latitude': null,
        'longitude': null,
        'created_at': 1700000010000,
        'updated_at': 1700000010000,
        'is_locked': 0,
        'checklist_json': null,
        'is_pinned': 0,
        'is_favorite': 0,
        'is_deleted': 0,
        'tags_json': '["Health"]',
        'reminder_at': scheduledTimestamp,
      });

      final v4Rows = await db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [newV4Id],
      );
      expect(v4Rows.length, 1);
      expect(v4Rows.first['title'], 'New v4 Note with Reminder');
      expect(v4Rows.first['reminder_at'], scheduledTimestamp);

      await db.close();
    });
  });
}
