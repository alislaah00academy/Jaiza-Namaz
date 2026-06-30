package com.alislaacademy.jayzanamaz.jaiza_namaz.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import com.alislaacademy.jayzanamaz.jaiza_namaz.R
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import org.json.JSONObject

private data class PrayerRow(
    val key: String,
    val statusId: Int,
    val doneId: Int,
    val missId: Int,
)

class JaizaPrayerWidget : HomeWidgetProvider() {

  private val rows =
      listOf(
          PrayerRow("fajr", R.id.row_fajr_status, R.id.btn_fajr_done, R.id.btn_fajr_miss),
          PrayerRow("zuhr", R.id.row_zuhr_status, R.id.btn_zuhr_done, R.id.btn_zuhr_miss),
          PrayerRow("asr", R.id.row_asr_status, R.id.btn_asr_done, R.id.btn_asr_miss),
          PrayerRow("maghrib", R.id.row_maghrib_status, R.id.btn_maghrib_done, R.id.btn_maghrib_miss),
          PrayerRow("isha", R.id.row_isha_status, R.id.btn_isha_done, R.id.btn_isha_miss),
      )

  override fun onEnabled(context: Context) {
    super.onEnabled(context)
    JaizaWidgetMidnightAlarm.schedule(context)
  }

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    JaizaWidgetMidnightAlarm.schedule(context)

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.jaiza_prayer_widget)

      val payload = widgetData.getString("jaiza_widget_payload", null)
      val root = if (payload != null) JSONObject(payload) else JSONObject()

      val title = root.optString("title", "Jaiza · Today's Prayers")
      val greeting = root.optString("greeting", "Assalamu alaikum")
      val today = root.optJSONObject("today") ?: JSONObject()
      val prayers = root.optJSONObject("prayers") ?: JSONObject()

      views.setTextViewText(R.id.widget_title, title)
      views.setTextViewText(R.id.widget_greeting, greeting)

      val nowDateKey = localDateKey(Date())
      val todayKey = today.optString("dateKey", "")
      val shouldResetRows = todayKey != nowDateKey

      for (row in rows) {
        val raw = if (shouldResetRows) "" else prayers.optString(row.key, "")
        applyStatus(views, row.statusId, raw)
        views.setOnClickPendingIntent(row.doneId, backgroundPendingIntent(context, row.key, "completed"))
        views.setOnClickPendingIntent(row.missId, backgroundPendingIntent(context, row.key, "missed"))
      }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  private fun applyStatus(views: RemoteViews, statusViewId: Int, raw: String) {
    when (raw) {
      "completed" -> {
        views.setTextViewText(statusViewId, "Prayed")
        views.setTextColor(statusViewId, Color.parseColor("#3F7A6A"))
      }
      "missed" -> {
        views.setTextViewText(statusViewId, "Missed")
        views.setTextColor(statusViewId, Color.parseColor("#B3261E"))
      }
      else -> {
        views.setTextViewText(statusViewId, "—")
        views.setTextColor(statusViewId, Color.parseColor("#7B6B5C"))
      }
    }
  }

  private fun backgroundPendingIntent(
      context: Context,
      prayer: String,
      status: String,
  ) = HomeWidgetBackgroundIntent.getBroadcast(
      context,
      Uri.parse("jaiza://prayer/mark?name=$prayer&status=$status"),
  )

  private fun localDateKey(now: Date): String {
    val fmt = SimpleDateFormat("yyyy-MM-dd", Locale.US)
    return fmt.format(now)
  }
}
