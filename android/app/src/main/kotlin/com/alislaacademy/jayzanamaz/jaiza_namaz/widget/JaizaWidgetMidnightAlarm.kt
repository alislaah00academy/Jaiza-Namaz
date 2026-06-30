package com.alislaacademy.jayzanamaz.jaiza_namaz.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import java.util.Calendar

class JaizaWidgetMidnightAlarm : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent?) {
    val appWidgetManager = AppWidgetManager.getInstance(context)
    val componentName = ComponentName(context, JaizaPrayerWidget::class.java)
    val ids = appWidgetManager.getAppWidgetIds(componentName)
    if (ids.isNotEmpty()) {
      val updateIntent = Intent(context, JaizaPrayerWidget::class.java).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
      }
      context.sendBroadcast(updateIntent)
    }

    schedule(context)
  }

  companion object {
    private const val REQUEST_CODE = 70601

    fun schedule(context: Context) {
      val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
      val intent = Intent(context, JaizaWidgetMidnightAlarm::class.java)
      val pending = PendingIntent.getBroadcast(
          context,
          REQUEST_CODE,
          intent,
          PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
      )

      val nextMidnight = Calendar.getInstance().apply {
        add(Calendar.DAY_OF_YEAR, 1)
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
      }

      alarmManager.setAndAllowWhileIdle(
          AlarmManager.RTC_WAKEUP,
          nextMidnight.timeInMillis,
          pending,
      )
    }
  }
}
