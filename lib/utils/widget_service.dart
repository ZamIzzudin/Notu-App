import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import '../utils/app_theme.dart';
import 'database_helper.dart';

// import 'dart:convert';
// import '../models/note.dart';

class WidgetService {
  static const String androidWidgetName = 'NotesWidgetProvider';
  static const String iosWidgetName = 'NotesWidget';

  // Update widget dengan pinned note
  static Future<void> updateWidget() async {
    try {
      // Get pinned note from database
      final pinnedNote = await DatabaseHelper.instance.getPinnedNote();

      if (pinnedNote != null) {
        // Save pinned note data to widget
        await HomeWidget.saveWidgetData<String>(
          'widget_title',
          pinnedNote.title,
        );
        await HomeWidget.saveWidgetData<String>(
          'widget_content',
          pinnedNote.content,
        );
        await HomeWidget.saveWidgetData<Color>(
          'widget_color',
          AppTheme.noteColors[pinnedNote.color],
        );
        await HomeWidget.saveWidgetData<String>(
          'widget_image',
          pinnedNote.imagePath ?? '',
        );
        await HomeWidget.saveWidgetData<bool>('has_pinned_note', true);
      } else {
        // No pinned note
        await HomeWidget.saveWidgetData<String>(
          'widget_title',
          'No Pinned Note',
        );
        await HomeWidget.saveWidgetData<String>(
          'widget_content',
          'Pin a note to display it here',
        );
        await HomeWidget.saveWidgetData<String>('widget_color', '#FFFFFF');
        await HomeWidget.saveWidgetData<String>('widget_image', '');
        await HomeWidget.saveWidgetData<bool>('has_pinned_note', false);
      }

      // Update widget on both platforms
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
        iOSName: iosWidgetName,
      );

      print('Widget updated successfully');
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  // Initialize widget
  static Future<void> initializeWidget() async {
    try {
      await updateWidget();
    } catch (e) {
      print('Error initializing widget: $e');
    }
  }

  // Handle widget click (untuk membuka note yang di-pin)
  static Future<void> setUpWidgetInteraction() async {
    try {
      // Set up callback for widget tap
      HomeWidget.setAppGroupId('YOUR_APP_GROUP_ID'); // For iOS

      // Register for widget updates
      HomeWidget.registerBackgroundCallback(backgroundCallback);
    } catch (e) {
      print('Error setting up widget interaction: $e');
    }
  }

  // Background callback untuk handle widget interaction
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri != null) {
      // Handle widget tap action
      print('Widget tapped with URI: $uri');
    }
  }
}
