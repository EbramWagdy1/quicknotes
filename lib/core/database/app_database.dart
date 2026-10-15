import 'dart:async';

import 'package:floor/floor.dart';
import 'package:quicknotes/core/database/daos/note_dao.dart';
import 'package:quicknotes/core/database/entities/note_entity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'date_time_converter.dart';

part 'app_database.g.dart';

// ignore: experimental_member_use
@TypeConverters([DateTimeConverter, NullableDateTimeConverter])
@Database(version: 5, entities: [NoteEntity])
abstract class AppDatabase extends FloorDatabase {
  NoteDao get noteDao;
}
