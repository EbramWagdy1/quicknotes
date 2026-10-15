import 'package:floor/floor.dart';

final migration3to4 = Migration(3, 4, (database) async {
  await database.execute(
    'ALTER TABLE notes ADD COLUMN reminder_at INTEGER',
  );
});
