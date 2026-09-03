package com.alislaacademy.jayzanamaz.jaiza_namaz.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.alislaacademy.jayzanamaz.jaiza_namaz.R
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.util.Locale
import kotlin.math.max

/**
 * 4x2 widget: app logo, today's five prayer times, the next prayer + countdown,
 * and the user's location. Informational only — marking lives in the 4x3
 * tracker widget.
 */
private data class TimeCell(val key: String, val timeId: Int)

class JaizaPrayerWidget : HomeWidgetProvider() {

  private val cells =
      listOf(
          TimeCell("fajr", R.id.time_fajr),
          TimeCell("zuhr", R.id.time_zuhr),
          TimeCell("asr", R.id.time_asr),
          TimeCell("maghrib", R.id.time_maghrib),
          TimeCell("isha", R.id.time_isha),
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
      val root = safeJson(widgetData.getString("jaiza_widget_payload", null))
      val times = root.optJSONObject("times") ?: JSONObject()
      val starts = root.optJSONObject("startsEpochMs") ?: JSONObject()
      val tomorrowFajr = root.optLong("tomorrowFajrEpochMs", 0L)

      views.setTextViewText(R.id.widget_title, root.optString("title", "Jaiza · Prayer Times"))
      views.setTextViewText(R.id.widget_location, root.optString("location", "—"))

      val now = System.currentTimeMillis()
      val (nextKey, nextStart) = computeNext(now, starts, tomorrowFajr)
      views.setTextViewText(
          R.id.widget_next,
          "Next: ${titleCasePrayer(nextKey)} · in ${compactDuration(nextStart - now)}",
      )

      for (cell in cells) {
        views.setTextViewText(cell.timeId, times.optString(cell.key, "—"))
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

  private fun computeNext(now: Long, starts: JSONObject, tomorrowFajr: Long): Pair<String, Long> {
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
