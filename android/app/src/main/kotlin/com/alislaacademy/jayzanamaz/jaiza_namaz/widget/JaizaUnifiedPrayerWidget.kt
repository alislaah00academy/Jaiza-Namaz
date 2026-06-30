package com.alislaacademy.jayzanamaz.jaiza_namaz.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import com.alislaacademy.jayzanamaz.jaiza_namaz.MainActivity
import com.alislaacademy.jayzanamaz.jaiza_namaz.R
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import kotlin.math.max

private data class UnifiedFardRow(
    val key: String,
    val labelId: Int,
    val timeId: Int,
    val doneId: Int,
    val missId: Int,
)

class JaizaUnifiedPrayerWidget : HomeWidgetProvider() {

  private val rows =
      listOf(
          UnifiedFardRow("fajr", R.id.unified_fajr_label, R.id.unified_fajr_time, R.id.btn_fajr_done, R.id.btn_fajr_miss),
          UnifiedFardRow("zuhr", R.id.unified_zuhr_label, R.id.unified_zuhr_time, R.id.btn_zuhr_done, R.id.btn_zuhr_miss),
          UnifiedFardRow("asr", R.id.unified_asr_label, R.id.unified_asr_time, R.id.btn_asr_done, R.id.btn_asr_miss),
          UnifiedFardRow("maghrib", R.id.unified_maghrib_label, R.id.unified_maghrib_time, R.id.btn_maghrib_done, R.id.btn_maghrib_miss),
          UnifiedFardRow("isha", R.id.unified_isha_label, R.id.unified_isha_time, R.id.btn_isha_done, R.id.btn_isha_miss),
      )

  override fun onEnabled(context: Context) {
    super.onEnabled(context)
    JaizaUnifiedPrayerAlarm.schedule(context)
  }

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray,
      widgetData: SharedPreferences,
  ) {
    JaizaUnifiedPrayerAlarm.schedule(context)

    appWidgetIds.forEach { widgetId ->
      val views = RemoteViews(context.packageName, R.layout.jaiza_unified_prayer_widget)
      views.setOnClickPendingIntent(
          R.id.unified_root,
          HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
      )

      val root = safeJson(widgetData.getString("jaiza_unified_widget_payload", null))
      views.setTextViewText(R.id.unified_title, root.optString("title", "Jaiza · Today’s Prayers"))
      views.setTextViewText(R.id.unified_first_name, root.optString("firstName", ""))
      views.setTextViewText(R.id.unified_date, root.optString("dateLine", ""))
      views.setTextViewText(R.id.unified_location, root.optString("location", "Open app to refresh location"))
      views.setTextViewText(R.id.unified_status, root.optString("statusLine", "Tap to refresh prayer times"))

      val now = System.currentTimeMillis()
      val target = root.optLong("targetEpochMs", now + 60_000L)
      views.setTextViewText(R.id.unified_countdown, "in ${compactDuration(target - now)}")

      val active = root.optString("activePrayer", "")
      val fard = root.optJSONArray("fard") ?: JSONArray()
      bindFardRows(context, views, fard, active)
      bindNawafil(views, root.optJSONArray("nawafil") ?: JSONArray())

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

  private fun bindFardRows(
      context: Context,
      views: RemoteViews,
      fard: JSONArray,
      active: String,
  ) {
    val byKey = mutableMapOf<String, JSONObject>()
    for (i in 0 until fard.length()) {
      val item = fard.optJSONObject(i) ?: continue
      byKey[item.optString("key", "")] = item
    }

    for (row in rows) {
      val item = byKey[row.key] ?: JSONObject()
      val label = item.optString("label", row.key.replaceFirstChar { it.uppercase() })
      val status = item.optString("status", "")
      val suffix =
          when (status) {
            "completed" -> " ✓"
            "missed" -> " ×"
            else -> ""
          }
      val isActive = row.key == active
      val color = Color.parseColor(if (isActive) "#FFD4AF37" else "#FFF7E9C6")
      views.setTextViewText(row.labelId, "$label$suffix")
      views.setTextViewText(row.timeId, item.optString("time", "—"))
      views.setTextColor(row.labelId, color)
      views.setTextColor(row.timeId, color)
      views.setOnClickPendingIntent(row.doneId, backgroundPendingIntent(context, row.key, "completed"))
      views.setOnClickPendingIntent(row.missId, backgroundPendingIntent(context, row.key, "missed"))
    }
  }

  private fun bindNawafil(views: RemoteViews, nawafil: JSONArray) {
    val ids =
        mapOf(
            "ashraq" to R.id.unified_ashraq,
            "chasht" to R.id.unified_chasht,
            "awwabin" to R.id.unified_awwabin,
        )
    for (id in ids.values) {
      views.setTextViewText(id, "")
    }
    for (i in 0 until nawafil.length()) {
      val item = nawafil.optJSONObject(i) ?: continue
      val id = ids[item.optString("key", "")] ?: continue
      views.setTextViewText(id, "${item.optString("label", "")}  ${item.optString("range", "—")}")
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

  private fun compactDuration(ms: Long): String {
    val totalMinutes = max(0L, ms / 60_000L)
    val hours = totalMinutes / 60L
    val minutes = totalMinutes % 60L
    return if (hours <= 0L) "${minutes}m" else "${hours}h ${minutes}m"
  }
}
