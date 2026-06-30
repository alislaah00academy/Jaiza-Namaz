import SwiftUI
import WidgetKit

private let appGroupId = "group.com.alislaacademy.jayzanamaz.jaizaNamaz"
private let payloadKeyB = "jaiza_widget_b_payload"

struct JaizaPrayerTimesEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let times: [String: String]
    let statuses: [String: String]
    let nextPrayerKey: String
    let nextStart: Date
}

struct JaizaPrayerTimesProvider: TimelineProvider {
    func placeholder(in context: Context) -> JaizaPrayerTimesEntry {
        JaizaPrayerTimesEntry(
            date: Date(),
            title: "Jaiza · Prayer times",
            subtitle: "Karachi · Hanafi · Lahore",
            times: [
                "fajr": "05:12",
                "zuhr": "12:18",
                "asr": "16:05",
                "maghrib": "18:42",
                "isha": "19:55",
            ],
            statuses: [:],
            nextPrayerKey: "zuhr",
            nextStart: Date().addingTimeInterval(3600),
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (JaizaPrayerTimesEntry) -> Void) {
        completion(readEntry(reference: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JaizaPrayerTimesEntry>) -> Void) {
        let now = Date()
        let entry = readEntry(reference: now)
        var nextWake = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime,
            direction: .forward,
        ) ?? now.addingTimeInterval(86_400)

        if let defaults = UserDefaults(suiteName: appGroupId),
           let payload = defaults.string(forKey: payloadKeyB),
           let data = payload.data(using: .utf8),
           let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let starts = root["startsEpochMs"] as? [String: Any] {
            for (_, v) in starts {
                let ms = doubleFromJson(v)
                let d = Date(timeIntervalSince1970: ms / 1000)
                if d > now, d < nextWake { nextWake = d }
            }
            if let tf = root["tomorrowFajrEpochMs"] {
                let ms = doubleFromJson(tf)
                let d = Date(timeIntervalSince1970: ms / 1000)
                if d > now, d < nextWake { nextWake = d }
            }
        }

        completion(Timeline(entries: [entry], policy: .after(nextWake)))
    }

    private func doubleFromJson(_ v: Any) -> Double {
        if let d = v as? Double { return d }
        if let i = v as? Int { return Double(i) }
        if let i = v as? Int64 { return Double(i) }
        return 0
    }

    private func readEntry(reference: Date) -> JaizaPrayerTimesEntry {
        let nowMs = reference.timeIntervalSince1970 * 1000
        guard
            let defaults = UserDefaults(suiteName: appGroupId),
            let payload = defaults.string(forKey: payloadKeyB),
            let data = payload.data(using: .utf8),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return placeholder(in: .init())
        }

        let title = (root["title"] as? String) ?? "Jaiza · Prayer times"
        let subtitle = (root["subtitle"] as? String) ?? ""
        let times = (root["times"] as? [String: String]) ?? [:]
        let statuses = (root["prayers"] as? [String: String]) ?? [:]
        let starts = (root["startsEpochMs"] as? [String: Any]) ?? [:]
        let tomorrowMs = doubleFromJson(root["tomorrowFajrEpochMs"] ?? 0)

        let order = ["fajr", "zuhr", "asr", "maghrib", "isha"]
        var nextKey = "fajr"
        var nextStart = reference.addingTimeInterval(60)

        for k in order {
            guard let raw = starts[k] else { continue }
            let ms = doubleFromJson(raw)
            if ms > nowMs {
                nextKey = k
                nextStart = Date(timeIntervalSince1970: ms / 1000)
                break
            }
        }
        if nextStart <= reference, tomorrowMs > nowMs {
            nextKey = "fajr"
            nextStart = Date(timeIntervalSince1970: tomorrowMs / 1000)
        }

        return JaizaPrayerTimesEntry(
            date: reference,
            title: title,
            subtitle: subtitle,
            times: times,
            statuses: statuses,
            nextPrayerKey: nextKey,
            nextStart: nextStart,
        )
    }
}

struct JaizaPrayerTimesWidgetEntryView: View {
    var entry: JaizaPrayerTimesProvider.Entry

    private func label(for key: String) -> String {
        switch key {
        case "fajr": return "Fajr"
        case "zuhr": return "Zuhr"
        case "asr": return "Asr"
        case "maghrib": return "Maghrib"
        case "isha": return "Isha"
        default: return key
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color(red: 0.24, green: 0.18, blue: 0.15))
            Text(entry.subtitle)
                .font(.system(size: 9))
                .foregroundStyle(Color(red: 0.48, green: 0.42, blue: 0.36))
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Divider().opacity(0.35)

            row("fajr", "Fajr")
            row("zuhr", "Zuhr")
            row("asr", "Asr")
            row("maghrib", "Maghrib")
            row("isha", "Isha")

            Divider().opacity(0.35)

            Text("Next: \(label(for: entry.nextPrayerKey))")
                .font(.system(size: 10))
                .foregroundStyle(Color(red: 0.48, green: 0.42, blue: 0.36))
            Text(entry.nextStart, style: .relative)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(red: 0.24, green: 0.18, blue: 0.15))
        }
        .padding(12)
        .containerBackground(Color(red: 0.984, green: 0.965, blue: 0.925), for: .widget)
    }

    @ViewBuilder
    private func row(_ key: String, _ name: String) -> some View {
        HStack {
            Text(name)
                .font(.system(size: 11, weight: .semibold))
            Spacer()
            Text(entry.times[key] ?? "—")
                .font(.system(size: 11))
            if entry.statuses[key] == "completed" {
                Text("✓")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 0.25, green: 0.48, blue: 0.42))
            } else if entry.statuses[key] == "missed" {
                Text("×")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(red: 0.70, green: 0.15, blue: 0.12))
            }
            if entry.nextPrayerKey == key {
                Text("◀")
                    .font(.system(size: 9))
                    .foregroundStyle(Color(red: 0.25, green: 0.48, blue: 0.42))
            }
            Link("✓", destination: URL(string: "jaiza://prayer/mark?name=\(key)&status=completed")!)
                .font(.system(size: 10, weight: .bold))
            Link("×", destination: URL(string: "jaiza://prayer/mark?name=\(key)&status=missed")!)
                .font(.system(size: 10, weight: .bold))
        }
    }
}

struct JaizaPrayerTimesHomeWidget: Widget {
    let kind: String = "JaizaPrayerTimesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JaizaPrayerTimesProvider()) { entry in
            JaizaPrayerTimesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Jaiza Prayer Times")
        .description("Today’s five prayer times and countdown to the next salah.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
