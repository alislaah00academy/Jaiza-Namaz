package com.alislaacademy.jayzanamaz.jaiza_namaz.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar
import org.json.JSONObject

/** Fires at the next prayer transition or midnight to refresh Widget B. */
class JaizaPrayerTimesAlarm : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent?) {
    val appWidgetManager = AppWidgetManager.getInstance(context)
    val componentName = ComponentName(context, JaizaPrayerTimesWidget::class.java)
    val ids = appWidgetManager.getAppWidgetIds(componentName)
    if (ids.isNotEmpty()) {
      val updateIntent =
          Intent(context, JaizaPrayerTimesWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
          }
      context.sendBroadcast(updateIntent)
    }
    schedule(context)
  }

  companion object {
    private const val REQUEST_CODE = 70602

    fun schedule(context: Context) {
      val widgetData = HomeWidgetPlugin.getData(context)
      val payload = widgetData.getString("jaiza_widget_b_payload", null)
      val root =
          try {
            if (payload.isNullOrEmpty()) JSONObject() else JSONObject(payload)
          } catch (_: Exception) {
            JSONObject()
          }

      val starts = root.optJSONObject("startsEpochMs") ?: JSONObject()
      val tomorrowFajr = root.optLong("tomorrowFajrEpochMs", 0L)
      val now = System.currentTimeMillis()

      var wake = Long.MAX_VALUE
      val order = listOf("fajr", "zuhr", "asr", "maghrib", "isha")
      for (k in order) {
        if (!starts.has(k)) continue
        val t = starts.getLong(k)
        if (t > now && t < wake) wake = t
      }
      if (tomorrowFajr > now && tomorrowFajr < wake) {
        wake = tomorrowFajr
      }

      val cal = Calendar.getInstance()
      cal.add(Calendar.DAY_OF_YEAR, 1)
      cal.set(Calendar.HOUR_OF_DAY, 0)
      cal.set(Calendar.MINUTE, 0)
      cal.set(Calendar.SECOND, 0)
      cal.set(Calendar.MILLISECOND, 0)
      val nextMidnight = cal.timeInMillis
      if (nextMidnight > now && nextMidnight < wake) {
        wake = nextMidnight
      }

      val nextMinute = now + 60_000L
      if (nextMinute > now && nextMinute < wake) {
        wake = nextMinute
      }

      if (wake == Long.MAX_VALUE || wake <= now) {
        wake = now + 60_000L
      }

      val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
      val alarmIntent = Intent(context, JaizaPrayerTimesAlarm::class.java)
      val pending =
          PendingIntent.getBroadcast(
              context,
              REQUEST_CODE,
              alarmIntent,
              PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
          )

      try {
        alarmManager.setAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            wake,
            pending,
        )
      } catch (_: SecurityException) {
        alarmManager.set(
            AlarmManager.RTC_WAKEUP,
            wake,
            pending,
        )
      }
    }
  }
}
