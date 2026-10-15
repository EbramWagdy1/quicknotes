import 'package:flutter/material.dart';
import 'package:quicknotes/app/quick_note.dart';
import 'package:quicknotes/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const QuickNoteApp());
}
 