import 'package:floor/floor.dart';

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute(
    'ALTER TABLE notes ADD COLUMN is_locked INTEGER NOT NULL DEFAULT 0',
  );
  await database.execute('ALTER TABLE notes ADD COLUMN checklist_json TEXT');
});
