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
import org.json.JSONObject
import java.util.Locale
import kotlin.math.max

private data class TimePrayerRow(
    val key: String,
    val labelId: Int,
    val timeId: Int,
    val doneId: Int,
    val missId: Int,
)

class JaizaPrayerTimesWidget : HomeWidgetProvider() {

  private val rows =
      listOf(
          TimePrayerRow("fajr", R.id.row_fajr_label, R.id.row_fajr_time, R.id.btn_fajr_done, R.id.btn_fajr_miss),
          TimePrayerRow("zuhr", R.id.row_zuhr_label, R.id.row_zuhr_time, R.id.btn_zuhr_done, R.id.btn_zuhr_miss),
          TimePrayerRow("asr", R.id.row_asr_label, R.id.row_asr_time, R.id.btn_asr_done, R.id.btn_asr_miss),
          TimePrayerRow("maghrib", R.id.row_maghrib_label, R.id.row_maghrib_time, R.id.btn_maghrib_done, R.id.btn_maghrib_miss),
          TimePrayerRow("isha", R.id.row_isha_label, R.id.row_isha_time, R.id.btn_isha_done, R.id.btn_isha_miss),
      )

  override fun onEnabled(context: Context) {
    super.onEnabled(context)
    JaizaPrayerTimesAlarm.schedule(context)
  }

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    JaizaPrayerTimesAlarm.schedule(context)

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.jaiza_prayer_times_widget)
      val root = safeJson(widgetData.getString("jaiza_widget_b_payload", null))
      val times = root.optJSONObject("times") ?: JSONObject()
      val starts = root.optJSONObject("startsEpochMs") ?: JSONObject()
      val prayers = root.optJSONObject("prayers") ?: JSONObject()
      val tomorrowFajr = root.optLong("tomorrowFajrEpochMs", 0L)

      views.setTextViewText(R.id.widget_b_title, root.optString("title", "Jaiza · Prayer Times"))
      views.setTextViewText(R.id.widget_b_subtitle, root.optString("subtitle", "Open app to refresh prayer times"))

      val now = System.currentTimeMillis()
      val (nextKey, nextStart) = computeNext(now, starts, tomorrowFajr)
      views.setTextViewText(R.id.widget_b_next_line, "Next: ${titleCasePrayer(nextKey)}")
      views.setTextViewText(R.id.widget_b_countdown, "in ${compactDuration(nextStart - now)}")

      for (row in rows) {
        val status = rootStatus(prayers, row.key)
        val isNext = row.key == nextKey
        val label = "${titleCasePrayer(row.key)}${statusSuffix(status)}"
        val color = Color.parseColor(if (isNext) "#FFD4AF37" else "#FFF7E9C6")
        views.setTextViewText(row.labelId, label)
        views.setTextViewText(row.timeId, times.optString(row.key, "—"))
        views.setTextColor(row.labelId, color)
        views.setTextColor(row.timeId, color)
        views.setOnClickPendingIntent(row.doneId, backgroundPendingIntent(context, row.key, "completed"))
        views.setOnClickPendingIntent(row.missId, backgroundPendingIntent(context, row.key, "missed"))
      }

      appWidgetManager.updateAppWidget(widgetId, views)
    }
  }

  private fun safeJson(raw: String?): JSONObject {
    return try {
      if (raw.isNullOrEmpty()) JSONObject() else JSONObject(raw)
    } catch (_: Exception) {
      JSONObject()
    }
  }

  private fun rootStatus(prayers: JSONObject, key: String): String = prayers.optString(key, "")

  private fun statusSuffix(status: String): String =
      when (status) {
        "completed" -> " ✓"
        "missed" -> " ×"
        else -> ""
      }

  private fun backgroundPendingIntent(
      context: Context,
      prayer: String,
      status: String,
  ) = HomeWidgetBackgroundIntent.getBroadcast(
      context,
      Uri.parse("jaiza://prayer/mark?name=$prayer&status=$status"),
  )

  private fun computeNext(
      now: Long,
      starts: JSONObject,
      tomorrowFajr: Long,
  ): Pair<String, Long> {
    val order = listOf("fajr", "zuhr", "asr", "maghrib", "isha")
    for (k in order) {
      if (!starts.has(k)) continue
      val t = starts.optLong(k, 0L)
      if (t > now) return k to t
    }
    val tf = if (tomorrowFajr > now) tomorrowFajr else now + 60_000L
    return "fajr" to tf
  }

  private fun compactDuration(ms: Long): String {
    val totalMinutes = max(0L, ms / 60_000L)
    val hours = totalMinutes / 60L
    val minutes = totalMinutes % 60L
    return if (hours <= 0L) "${minutes}m" else "${hours}h ${minutes}m"
  }

  private fun titleCasePrayer(key: String): String =
      key.replaceFirstChar {
        if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
      }
}
