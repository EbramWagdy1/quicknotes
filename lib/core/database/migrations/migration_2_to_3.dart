import 'package:floor/floor.dart';

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute(
    'ALTER TABLE notes ADD COLUMN is_pinned INTEGER NOT NULL DEFAULT 0',
  );
  await database.execute(
    'ALTER TABLE notes ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
  );
  await database.execute(
    'ALTER TABLE notes ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
  );
  await database.execute(
    'ALTER TABLE notes ADD COLUMN tags_json TEXT',
  );
});
