import 'package:home_widget/home_widget.dart';

import '../models/note.dart';

class WidgetService {
  static Future<void> updateWidget(List<Note> notes) async {
    try {
      if (notes.isEmpty) {
        // Set default data when no notes
        await HomeWidget.saveWidgetData<String>('widget_title', 'No notes yet');
        await HomeWidget.saveWidgetData<String>(
          'widget_content',
          'Tap to create your first note!',
        );
        await HomeWidget.saveWidgetData<int>('notes_count', 0);
      } else {
        // Get latest note
        final latestNote = notes.first;

        // Save data for widget
        await HomeWidget.saveWidgetData<String>(
          'widget_title',
          latestNote.title.isEmpty ? 'Untitled' : latestNote.title,
        );
        await HomeWidget.saveWidgetData<String>(
          'widget_content',
          latestNote.content.isEmpty ? 'No content' : latestNote.content,
        );
        await HomeWidget.saveWidgetData<int>('notes_count', notes.length);
      }

      // Update widget
      await HomeWidget.updateWidget(
        androidName: 'NotesWidgetProvider',
        iOSName: 'NotesWidget',
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  static Future<void> initializeWidget() async {
    try {
      // Set up any initial widget configuration
      await HomeWidget.setAppGroupId('group.com.example.notu');
    } catch (e) {
      print('Error initializing widget: $e');
    }
  }
}
