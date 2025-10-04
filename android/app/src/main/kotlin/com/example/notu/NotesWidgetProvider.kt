package com.example.notu

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.graphics.Color
import android.view.View

class NotesWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_UPDATE_WIDGET) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, NotesWidgetProvider::class.java)
            )
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }
    }

    companion object {
        const val ACTION_UPDATE_WIDGET = "com.example.notu.UPDATE_WIDGET"
        private const val PREFS_NAME = "NotesWidgetPrefs"
        private const val PREF_HAS_PINNED = "hasPinnedNotes"
        private const val PREF_TITLE = "title"
        private const val PREF_CONTENT = "content"
        // private const val PREF_COLOR = "color"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val hasPinnedNotes = prefs.getBoolean(PREF_HAS_PINNED, false)
            
            val views = RemoteViews(context.packageName, R.layout.notes_widget_layout)

            if (hasPinnedNotes) {
                val title = prefs.getString(PREF_TITLE, "No Title") ?: "No Title"
                val content = prefs.getString(PREF_CONTENT, "No Content") ?: "No Content"
                // val colorInt = prefs.getInt(PREF_COLOR, Color.WHITE)

                views.setViewVisibility(R.id.empty_state, View.GONE)
                views.setViewVisibility(R.id.note_container, View.VISIBLE)
                
                views.setTextViewText(R.id.widget_title, title)
                views.setTextViewText(R.id.widget_content, content)
                // views.setInt(R.id.widget_background, "setBackgroundColor", colorInt)
            } else {
                views.setViewVisibility(R.id.empty_state, View.VISIBLE)
                views.setViewVisibility(R.id.note_container, View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun saveWidgetData(
            context: Context,
            hasPinnedNotes: Boolean,
            title: String,
            content: String,
            // color: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putBoolean(PREF_HAS_PINNED, hasPinnedNotes)
                putString(PREF_TITLE, title)
                putString(PREF_CONTENT, content)
                // putInt(PREF_COLOR, color)
                apply()
            }
        }
    }
}