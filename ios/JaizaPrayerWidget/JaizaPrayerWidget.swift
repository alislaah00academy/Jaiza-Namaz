import WidgetKit
import SwiftUI

private let appGroupId = "group.com.alislaacademy.jayzanamaz.jaizaNamaz"
private let payloadKey = "jaiza_widget_payload"

struct PrayerRowModel: Identifiable {
    let id: String
    let title: String
    let status: String
}

struct JaizaWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let greeting: String
    let dateLine: String
    let prayers: [PrayerRowModel]
}

struct JaizaPrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> JaizaWidgetEntry {
        JaizaWidgetEntry(
            date: Date(),
            title: "Jaiza · Today's Prayers",
            greeting: "Assalamu alaikum",
            dateLine: "Fri, 1 May 2026 · 14 Dhu al-Qa'dah 1447 AH",
            prayers: [
                PrayerRowModel(id: "fajr", title: "Fajr", status: "—"),
                PrayerRowModel(id: "zuhr", title: "Zuhr", status: "—"),
                PrayerRowModel(id: "asr", title: "Asr", status: "—"),
                PrayerRowModel(id: "maghrib", title: "Maghrib", status: "—"),
                PrayerRowModel(id: "isha", title: "Isha", status: "—"),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (JaizaWidgetEntry) -> Void) {
        completion(readEntry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JaizaWidgetEntry>) -> Void) {
        let now = Date()
        let midnight = nextMidnight(after: now)
        let entries = [
            readEntry(for: now),
            readEntry(for: midnight),
        ]
        completion(Timeline(entries: entries, policy: .after(midnight)))
    }

    private func nextMidnight(after date: Date) -> Date {
        Calendar.current.nextDate(
            after: date,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime,
            direction: .forward
        ) ?? date.addingTimeInterval(3600)
    }

    private func localDateKey(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    private func readEntry(for now: Date) -> JaizaWidgetEntry {
        guard
            let defaults = UserDefaults(suiteName: appGroupId),
            let payload = defaults.string(forKey: payloadKey),
            let data = payload.data(using: .utf8),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return placeholder(in: .init())
        }

        let title = (root["title"] as? String) ?? "Jaiza · Today's Prayers"
        let greeting = (root["greeting"] as? String) ?? "Assalamu alaikum"

        let today = (root["today"] as? [String: Any]) ?? [:]
        let tomorrow = (root["tomorrow"] as? [String: Any]) ?? [:]
        let prayersDict = (root["prayers"] as? [String: String]) ?? [:]

        let nowKey = localDateKey(now)
        let todayKey = today["dateKey"] as? String ?? ""
        let tomorrowKey = tomorrow["dateKey"] as? String ?? ""

        let dateLine: String
        let shouldResetRows: Bool
        if nowKey == todayKey {
            dateLine = today["dateLine"] as? String ?? ""
            shouldResetRows = false
        } else if nowKey == tomorrowKey {
            dateLine = tomorrow["dateLine"] as? String ?? ""
            shouldResetRows = true
        } else {
            dateLine = ""
            shouldResetRows = true
        }

        let order: [(String, String)] = [
            ("fajr", "Fajr"),
            ("zuhr", "Zuhr"),
            ("asr", "Asr"),
            ("maghrib", "Maghrib"),
            ("isha", "Isha"),
        ]

        let rows = order.map { key, label in
            let raw = shouldResetRows ? "" : (prayersDict[key] ?? "")
            let status: String = raw == "completed" ? "Prayed" : (raw == "missed" ? "Missed" : "—")
            return PrayerRowModel(id: key, title: label, status: status)
        }

        return JaizaWidgetEntry(
            date: now,
            title: title,
            greeting: greeting,
            dateLine: dateLine,
            prayers: rows
        )
    }
}

struct JaizaPrayerWidgetEntryView: View {
    var entry: JaizaPrayerProvider.Entry

    private func color(for status: String) -> Color {
        if status == "Prayed" { return Color(red: 0.25, green: 0.48, blue: 0.42) }
        if status == "Missed" { return Color(red: 0.70, green: 0.15, blue: 0.12) }
        return Color(red: 0.48, green: 0.42, blue: 0.36)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.24, green: 0.18, blue: 0.15))
            Text(entry.greeting)
                .font(.system(size: 10))
                .foregroundStyle(Color(red: 0.48, green: 0.42, blue: 0.36))
            Text(entry.dateLine)
                .font(.system(size: 9))
                .foregroundStyle(Color(red: 0.48, green: 0.42, blue: 0.36))

            ForEach(entry.prayers) { prayer in
                HStack(spacing: 6) {
                    Text(prayer.title)
                        .font(.system(size: 11, weight: .semibold))
                    Spacer()
                    Text(prayer.status)
                        .font(.system(size: 10))
                        .foregroundStyle(color(for: prayer.status))
                    Link("✓", destination: URL(string: "jaiza://prayer/mark?name=\(prayer.id)&status=completed")!)
                        .font(.system(size: 12, weight: .bold))
                    Link("✗", destination: URL(string: "jaiza://prayer/mark?name=\(prayer.id)&status=missed")!)
                        .font(.system(size: 12, weight: .bold))
                }
            }
        }
        .padding(12)
        .containerBackground(Color(red: 0.984, green: 0.965, blue: 0.925), for: .widget)
    }
}

struct JaizaPrayerWidget: Widget {
    let kind: String = "JaizaPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JaizaPrayerProvider()) { entry in
            JaizaPrayerWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Jaiza Prayer Tracker")
        .description("Mark today’s five daily prayers from the home screen.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    JaizaPrayerWidget()
} timeline: {
    JaizaWidgetEntry(
        date: Date(),
        title: "Jaiza · Today's Prayers",
        greeting: "Assalamu — Muslim",
        dateLine: "Fri, 1 May 2026 · 14 Dhu al-Qa'dah 1447 AH",
        prayers: [
            PrayerRowModel(id: "fajr", title: "Fajr", status: "Prayed"),
            PrayerRowModel(id: "zuhr", title: "Zuhr", status: "—"),
            PrayerRowModel(id: "asr", title: "Asr", status: "Missed"),
            PrayerRowModel(id: "maghrib", title: "Maghrib", status: "—"),
            PrayerRowModel(id: "isha", title: "Isha", status: "—"),
        ]
    )
}
