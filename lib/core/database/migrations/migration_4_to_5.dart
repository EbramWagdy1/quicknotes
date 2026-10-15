import 'package:floor/floor.dart';

final migration4to5 = Migration(4, 5, (database) async {
  await database.execute(
    'ALTER TABLE notes ADD COLUMN audio_path TEXT',
  );
});
