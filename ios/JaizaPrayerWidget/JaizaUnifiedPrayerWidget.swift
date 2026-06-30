import SwiftUI
import WidgetKit

private let unifiedAppGroupId = "group.com.alislaacademy.jayzanamaz.jaizaNamaz"
private let unifiedPayloadKey = "jaiza_unified_widget_payload"

struct UnifiedPrayerRow: Identifiable {
    let id: String
    let label: String
    let value: String
    let status: String
}

struct JaizaUnifiedPrayerEntry: TimelineEntry {
    let date: Date
    let title: String
    let firstName: String
    let dateLine: String
    let location: String
    let statusLine: String
    let activePrayer: String
    let targetDate: Date
    let fard: [UnifiedPrayerRow]
    let nawafil: [UnifiedPrayerRow]
}

struct JaizaUnifiedPrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> JaizaUnifiedPrayerEntry {
        JaizaUnifiedPrayerEntry(
            date: Date(),
            title: "Jaiza · Today’s Prayers",
            firstName: "Hamza",
            dateLine: "Fri, 1 May 2026 · 14 Dhu Al-Qi'dah 1447 AH",
            location: "Shahpur Kanjra, Lahore, Punjab, Pakistan",
            statusLine: "Zuhr ends in 2h 15m",
            activePrayer: "zuhr",
            targetDate: Date().addingTimeInterval(8100),
            fard: [
                UnifiedPrayerRow(id: "fajr", label: "Fajr", value: "03:49 AM", status: ""),
                UnifiedPrayerRow(id: "zuhr", label: "Zuhr", value: "12:01 PM", status: ""),
                UnifiedPrayerRow(id: "asr", label: "Asr", value: "04:47 PM", status: ""),
                UnifiedPrayerRow(id: "maghrib", label: "Maghrib", value: "06:45 PM", status: ""),
                UnifiedPrayerRow(id: "isha", label: "Isha", value: "08:10 PM", status: ""),
            ],
            nawafil: [
                UnifiedPrayerRow(id: "ashraq", label: "Ashraq", value: "06:00 AM – 12:01 PM", status: ""),
                UnifiedPrayerRow(id: "chasht", label: "Chasht", value: "06:40 AM – 11:51 AM", status: ""),
                UnifiedPrayerRow(id: "awwabin", label: "Awwabin", value: "06:50 PM – 08:10 PM", status: ""),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (JaizaUnifiedPrayerEntry) -> Void) {
        completion(readEntry(reference: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<JaizaUnifiedPrayerEntry>) -> Void) {
        let now = Date()
        let entry = readEntry(reference: now)
        let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime,
            direction: .forward
        ) ?? now.addingTimeInterval(86_400)
        let nextWake = entry.targetDate > now ? min(entry.targetDate, midnight) : midnight
        completion(Timeline(entries: [entry], policy: .after(nextWake)))
    }

    private func readEntry(reference: Date) -> JaizaUnifiedPrayerEntry {
        guard
            let defaults = UserDefaults(suiteName: unifiedAppGroupId),
            let payload = defaults.string(forKey: unifiedPayloadKey),
            let data = payload.data(using: .utf8),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return placeholder(in: .init())
        }

        return JaizaUnifiedPrayerEntry(
            date: reference,
            title: (root["title"] as? String) ?? "Jaiza · Today’s Prayers",
            firstName: (root["firstName"] as? String) ?? "",
            dateLine: (root["dateLine"] as? String) ?? "",
            location: (root["location"] as? String) ?? "",
            statusLine: (root["statusLine"] as? String) ?? "Tap to refresh prayer times",
            activePrayer: (root["activePrayer"] as? String) ?? "",
            targetDate: dateFromMillis(root["targetEpochMs"] ?? 0, fallback: reference.addingTimeInterval(60)),
            fard: readRows(root["fard"] as? [[String: Any]], valueKey: "time"),
            nawafil: readRows(root["nawafil"] as? [[String: Any]], valueKey: "range")
        )
    }

    private func readRows(_ raw: [[String: Any]]?, valueKey: String) -> [UnifiedPrayerRow] {
        (raw ?? []).map {
            UnifiedPrayerRow(
                id: ($0["key"] as? String) ?? "",
                label: ($0["label"] as? String) ?? "",
                value: ($0[valueKey] as? String) ?? "—",
                status: ($0["status"] as? String) ?? ""
            )
        }
    }

    private func dateFromMillis(_ value: Any, fallback: Date) -> Date {
        let ms: Double
        if let d = value as? Double {
            ms = d
        } else if let i = value as? Int {
            ms = Double(i)
        } else if let i = value as? Int64 {
            ms = Double(i)
        } else {
            return fallback
        }
        let date = Date(timeIntervalSince1970: ms / 1000)
        return date > Date() ? date : fallback
    }
}

struct JaizaUnifiedPrayerEntryView: View {
    var entry: JaizaUnifiedPrayerProvider.Entry

    private let cream = Color(red: 0.97, green: 0.91, blue: 0.76)
    private let muted = Color(red: 0.90, green: 0.86, blue: 0.78).opacity(0.78)
    private let gold = Color(red: 0.83, green: 0.69, blue: 0.22)

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(entry.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(cream)
                Spacer()
                Text(entry.firstName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
            }

            Text(entry.dateLine)
                .font(.system(size: 9))
                .foregroundStyle(muted)
                .lineLimit(1)
            Text(entry.location)
                .font(.system(size: 8))
                .foregroundStyle(muted)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.statusLine)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(cream)
                Text(entry.targetDate, style: .relative)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(gold)
            }
            .padding(7)
            .background(.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            ForEach(entry.fard) { row in
                HStack {
                    Text(labelWithStatus(row))
                        .font(.system(size: 10, weight: row.id == entry.activePrayer ? .bold : .medium))
                    Spacer()
                    Text(row.value)
                        .font(.system(size: 10, weight: row.id == entry.activePrayer ? .bold : .regular))
                    Link("✓", destination: URL(string: "jaiza://prayer/mark?name=\(row.id)&status=completed")!)
                        .font(.system(size: 9, weight: .bold))
                    Link("×", destination: URL(string: "jaiza://prayer/mark?name=\(row.id)&status=missed")!)
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(row.id == entry.activePrayer ? gold : cream)
            }

            Divider().overlay(.white.opacity(0.18))

            ForEach(entry.nawafil) { row in
                HStack {
                    Text(row.label)
                    Spacer()
                    Text(row.value)
                }
                .font(.system(size: 8))
                .foregroundStyle(muted)
            }

            Text("Tap to open app")
                .font(.system(size: 8))
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(13)
        .containerBackground(
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.24, blue: 0.20).opacity(0.82),
                    Color(red: 0.08, green: 0.13, blue: 0.11).opacity(0.68),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .widget
        )
        .widgetURL(URL(string: "jaiza://app/home"))
    }

    private func labelWithStatus(_ row: UnifiedPrayerRow) -> String {
        if row.status == "completed" { return "\(row.label) ✓" }
        if row.status == "missed" { return "\(row.label) ×" }
        return row.label
    }
}

struct JaizaUnifiedPrayerWidget: Widget {
    let kind: String = "JaizaUnifiedPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: JaizaUnifiedPrayerProvider()) { entry in
            JaizaUnifiedPrayerEntryView(entry: entry)
        }
        .configurationDisplayName("Jaiza Today’s Prayers")
        .description("Glass-style dashboard with Fard, Nawafil, location, and countdown.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
