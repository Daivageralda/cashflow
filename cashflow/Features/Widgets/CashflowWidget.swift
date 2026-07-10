import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let balance: Double
    let totalSpent: Double
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), balance: 5000000, totalSpent: 1200000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.dumeg.cashflow")
        let balance = sharedDefaults?.double(forKey: "totalBalance") ?? 0.0
        let totalSpent = sharedDefaults?.double(forKey: "totalSpent") ?? 0.0
        let entry = SimpleEntry(date: Date(), balance: balance, totalSpent: totalSpent)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.dumeg.cashflow")
        let balance = sharedDefaults?.double(forKey: "totalBalance") ?? 0.0
        let totalSpent = sharedDefaults?.double(forKey: "totalSpent") ?? 0.0

        let entry = SimpleEntry(date: Date(), balance: balance, totalSpent: totalSpent)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct CashflowWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "wallet.pass.fill")
                    .font(.footnote)
                    .foregroundStyle(Color.accentColor)
                Text("Cashflow")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }

            Text("Total Saldo")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(entry.balance.formatted(.currency(code: "IDR").presentation(.narrow)))
                .font(family == .systemSmall ? .subheadline : .title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            if family != .systemSmall {
                Divider()

                HStack {
                    VStack(alignment: .leading) {
                        Text("Belanja Bulan Ini")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(entry.totalSpent.formatted(.currency(code: "IDR").presentation(.narrow)))
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }
            }
        }
        .containerBackground(.background, for: .widget)
    }
}

struct CashflowWidget: Widget {
    let kind: String = "CashflowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CashflowWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ringkasan Cashflow")
        .description("Pantau saldo dan total belanja bulananmu secara langsung.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
