package com.example.notu

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class NotesWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.notes_widget_layout
            ).apply {
                // Get data from shared preferences
                val widgetData = HomeWidgetPlugin.getData(context)
                val title = widgetData.getString("widget_title", "No notes yet")
                val content = widgetData.getString("widget_content", "Create your first note!")
                val notesCount = widgetData.getInt("notes_count", 0)

                // Set the text
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_content, content)
                setTextViewText(R.id.widget_notes_count, "$notesCount notes")

               val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java)

                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}