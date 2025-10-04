package com.example.notu

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import java.io.File

class NotesWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.notes_widget_layout)
            
            // Get widget data
            val hasPinnedNote = widgetData.getBoolean("has_pinned_note", false)
            val title = widgetData.getString("widget_title", "No Pinned Note") ?: "No Pinned Note"
            val content = widgetData.getString("widget_content", "Pin a note to display it here") ?: ""
            val colorHex = widgetData.getString("widget_color", "#FFFFFF") ?: "#FFFFFF"
            val imagePath = widgetData.getString("widget_image", "") ?: ""

            // Set title
            views.setTextViewText(R.id.widget_title, title)
            
            // Set content
            views.setTextViewText(R.id.widget_content, content)

            // Set background color
            try {
                val color = android.graphics.Color.parseColor(colorHex)
                views.setInt(R.id.widget_background, "setBackgroundColor", color)
            } catch (e: Exception) {
                // Use default white if color parsing fails
                views.setInt(
                    R.id.widget_background, 
                    "setBackgroundColor", 
                    android.graphics.Color.WHITE
                )
            }

            // Set image if available
            if (imagePath.isNotEmpty()) {
                try {
                    val imageFile = File(imagePath)
                    if (imageFile.exists()) {
                        val bitmap = BitmapFactory.decodeFile(imagePath)
                        if (bitmap != null) {
                            // Scale bitmap if too large
                            val scaledBitmap = scaleBitmap(bitmap, 400, 300)
                            views.setImageViewBitmap(R.id.widget_image, scaledBitmap)
                            views.setViewVisibility(R.id.widget_image, android.view.View.VISIBLE)
                            
                            // Recycle original if scaled
                            if (scaledBitmap !== bitmap) {
                                bitmap.recycle()
                            }
                        } else {
                            views.setViewVisibility(R.id.widget_image, android.view.View.GONE)
                        }
                    } else {
                        views.setViewVisibility(R.id.widget_image, android.view.View.GONE)
                    }
                } catch (e: Exception) {
                    views.setViewVisibility(R.id.widget_image, android.view.View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.widget_image, android.view.View.GONE)
            }

            // Show pin indicator if note is pinned
            if (hasPinnedNote) {
                views.setViewVisibility(R.id.widget_pin_indicator, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_pin_indicator, android.view.View.GONE)
            }

            // Set click intent to open app
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_background, pendingIntent)

            // Update widget
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun scaleBitmap(bitmap: Bitmap, maxWidth: Int, maxHeight: Int): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        
        if (width <= maxWidth && height <= maxHeight) {
            return bitmap
        }

        val ratio = Math.min(
            maxWidth.toFloat() / width.toFloat(),
            maxHeight.toFloat() / height.toFloat()
        )

        val newWidth = (width * ratio).toInt()
        val newHeight = (height * ratio).toInt()

        return Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true)
    }
}