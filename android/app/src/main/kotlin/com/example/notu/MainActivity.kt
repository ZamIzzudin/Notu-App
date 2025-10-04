package com.example.notu

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.notu/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                try {
                    val hasPinnedNotes = call.argument<Boolean>("hasPinnedNotes") ?: false
                    val title = call.argument<String>("title") ?: ""
                    val content = call.argument<String>("content") ?: ""
                    // Terima color sebagai integer (bukan Color object)
                    // val color = call.argument<Int>("color") ?: 0xFFFFFFFF.toInt()

                    // Simpan data ke SharedPreferences
                    NotesWidgetProvider.saveWidgetData(
                        this,
                        hasPinnedNotes,
                        title,
                        content,
                        // color
                    )

                    // Update widget
                    val appWidgetManager = AppWidgetManager.getInstance(this)
                    val appWidgetIds = appWidgetManager.getAppWidgetIds(
                        ComponentName(this, NotesWidgetProvider::class.java)
                    )
                    
                    for (appWidgetId in appWidgetIds) {
                        NotesWidgetProvider.updateAppWidget(this, appWidgetManager, appWidgetId)
                    }

                    // Kirim broadcast untuk update
                    val intent = Intent(this, NotesWidgetProvider::class.java)
                    intent.action = NotesWidgetProvider.ACTION_UPDATE_WIDGET
                    sendBroadcast(intent)

                    result.success(true)
                } catch (e: Exception) {
                    result.error("WIDGET_ERROR", "Failed to update widget: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}