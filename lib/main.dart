import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/notes_list_page.dart';
import 'utils/app_theme.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: AppTheme.lightTheme,
      home: const NotesListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
