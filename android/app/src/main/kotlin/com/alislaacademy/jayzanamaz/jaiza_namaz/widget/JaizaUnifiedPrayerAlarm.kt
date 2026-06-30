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

/** Refreshes the unified widget when the current countdown target changes. */
class JaizaUnifiedPrayerAlarm : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent?) {
    val appWidgetManager = AppWidgetManager.getInstance(context)
    val componentName = ComponentName(context, JaizaUnifiedPrayerWidget::class.java)
    val ids = appWidgetManager.getAppWidgetIds(componentName)
    if (ids.isNotEmpty()) {
      val updateIntent =
          Intent(context, JaizaUnifiedPrayerWidget::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
          }
      context.sendBroadcast(updateIntent)
    }
    schedule(context)
  }

  companion object {
    private const val REQUEST_CODE = 70603

    fun schedule(context: Context) {
      val widgetData = HomeWidgetPlugin.getData(context)
      val payload = widgetData.getString("jaiza_unified_widget_payload", null)
      val root =
          try {
            if (payload.isNullOrEmpty()) JSONObject() else JSONObject(payload)
          } catch (_: Exception) {
            JSONObject()
          }

      val now = System.currentTimeMillis()
      val target = root.optLong("targetEpochMs", 0L)

      val midnight =
          Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
          }.timeInMillis

      var wake = Long.MAX_VALUE
      if (target > now) wake = target
      if (midnight > now && midnight < wake) wake = midnight
      val nextMinute = now + 60_000L
      if (nextMinute > now && nextMinute < wake) wake = nextMinute
      if (wake == Long.MAX_VALUE || wake <= now) wake = now + 60_000L

      val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
      val alarmIntent = Intent(context, JaizaUnifiedPrayerAlarm::class.java)
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
