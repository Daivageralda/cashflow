import WidgetKit
import SwiftUI

// MARK: - Model

struct CashflowEntry: TimelineEntry {
    let date: Date
    let isExpenseOnlyMode: Bool
    let balance: Double
    let totalSpent: Double
    let monthlyExpenseCount: Int
    let lastTransactionName: String
    let lastTransactionAmount: Double
    let lastTransactionIsExpense: Bool
    let lastTransactionDate: Date?
}

// MARK: - Provider

struct CashflowProvider: TimelineProvider {
    func placeholder(in context: Context) -> CashflowEntry {
        CashflowEntry(
            date: Date(),
            isExpenseOnlyMode: false,
            balance: 12_500_000,
            totalSpent: 3_240_000,
            monthlyExpenseCount: 14,
            lastTransactionName: "Makan siang",
            lastTransactionAmount: 45_000,
            lastTransactionIsExpense: true,
            lastTransactionDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date())
        )
    }

    private func readEntry() -> CashflowEntry {
        let ud = UserDefaults(suiteName: "group.com.dumeg.cashflow")
        return CashflowEntry(
            date: Date(),
            isExpenseOnlyMode: ud?.bool(forKey: "isExpenseOnlyMode") ?? false,
            balance: ud?.double(forKey: "totalBalance") ?? 0,
            totalSpent: ud?.double(forKey: "totalSpent") ?? 0,
            monthlyExpenseCount: ud?.integer(forKey: "monthlyExpenseCount") ?? 0,
            lastTransactionName: ud?.string(forKey: "lastTransactionName") ?? "",
            lastTransactionAmount: ud?.double(forKey: "lastTransactionAmount") ?? 0,
            lastTransactionIsExpense: (ud?.string(forKey: "lastTransactionType") ?? "expense") == "expense",
            lastTransactionDate: ud?.object(forKey: "lastTransactionDate") as? Date
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (CashflowEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CashflowEntry>) -> Void) {
        completion(Timeline(entries: [readEntry()], policy: .atEnd))
    }
}

// MARK: - Helpers

private extension Double {
    func compactIDR() -> String {
        let abs = Swift.abs(self)
        let sign = self < 0 ? "-" : ""
        switch abs {
        case 1_000_000_000...: return "\(sign)Rp\(String(format: "%.1f", abs / 1_000_000_000))M"
        case 1_000_000...:     return "\(sign)Rp\(String(format: "%.1f", abs / 1_000_000))Jt"
        case 1_000...:         return "\(sign)Rp\(String(format: "%.0f", abs / 1_000))Rb"
        default:               return "\(sign)Rp\(String(format: "%.0f", abs))"
        }
    }
}

// MARK: - Normal Mode Views

private struct NormalSmallView: View {
    let entry: CashflowEntry

    private var burnRatio: Double {
        guard entry.balance > 0 else { return 0 }
        return min(entry.totalSpent / entry.balance, 1.0)
    }
    private var burnColor: Color {
        burnRatio < 0.5 ? Color(UIColor.systemGreen) : burnRatio < 0.8 ? Color(UIColor.systemOrange) : Color(UIColor.systemRed)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppMark()
            Spacer()
            VStack(alignment: .leading, spacing: 3) {
                SectionLabel("SALDO BERSIH")
                Text(entry.balance.compactIDR())
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(Color(UIColor.label))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            Spacer()
            HStack(spacing: 6) {
                Circle()
                    .fill(burnColor)
                    .frame(width: 6, height: 6)
                Text(entry.totalSpent.compactIDR())
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(burnColor)
                    .lineLimit(1)
                Spacer()
            }
        }
        .padding(14)
        .containerBackground(Color(UIColor.systemBackground), for: .widget)
    }
}

private struct NormalMediumView: View {
    let entry: CashflowEntry

    private var burnRatio: Double {
        guard entry.balance > 0 else { return 0 }
        return min(entry.totalSpent / entry.balance, 1.0)
    }
    private var burnColor: Color {
        burnRatio < 0.5 ? Color(UIColor.systemGreen) : burnRatio < 0.8 ? Color(UIColor.systemOrange) : Color(UIColor.systemRed)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left: balance
            VStack(alignment: .leading, spacing: 0) {
                AppMark()
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    SectionLabel("SALDO BERSIH")
                    Text(entry.balance.compactIDR())
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color(UIColor.label))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                    if let txDate = entry.lastTransactionDate {
                        Text(txDate, format: .dateTime.day().month(.abbreviated).hour().minute())
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    } else {
                        Text("Diperbarui")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(width: 0.5)
                .padding(.vertical, 4)
                .padding(.horizontal, 14)

            // Right: spending
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    SectionLabel("BELANJA BULAN INI")
                    Text(entry.totalSpent.compactIDR())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(burnColor)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                VStack(alignment: .leading, spacing: 5) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color(UIColor.systemFill)).frame(height: 4)
                            RoundedRectangle(cornerRadius: 2).fill(burnColor).frame(width: geo.size.width * burnRatio, height: 4)
                        }
                    }
                    .frame(height: 4)
                    Text("\(Int(burnRatio * 100))% dari saldo bersih")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                Spacer()
                StatusChip(burnRatio: burnRatio, color: burnColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .containerBackground(Color(UIColor.systemBackground), for: .widget)
    }
}

// MARK: - Expense-Only Mode Views

private struct ExpenseSmallView: View {
    let entry: CashflowEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AppMark()
            Spacer()
            VStack(alignment: .leading, spacing: 3) {
                SectionLabel("TOTAL PENGELUARAN")
                // In expense-only mode, entry.balance = sum of ALL expenses
                Text(entry.balance.compactIDR())
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(Color(UIColor.systemRed))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            Spacer()
            HStack(spacing: 5) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                Text("\(entry.monthlyExpenseCount) transaksi bulan ini")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                Spacer()
            }
        }
        .padding(14)
        .containerBackground(Color(UIColor.systemBackground), for: .widget)
    }
}

private struct ExpenseMediumView: View {
    let entry: CashflowEntry

    var body: some View {
        HStack(spacing: 0) {
            // Left: total expense
            VStack(alignment: .leading, spacing: 0) {
                AppMark()
                Spacer()
                VStack(alignment: .leading, spacing: 3) {
                    SectionLabel("TOTAL PENGELUARAN")
                    // In expense-only mode, entry.balance = sum of ALL expenses
                    Text(entry.balance.compactIDR())
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(Color(UIColor.systemRed))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                Spacer()
                HStack(spacing: 5) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                    Text("\(entry.monthlyExpenseCount) transaksi bulan ini")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(width: 0.5)
                .padding(.vertical, 4)
                .padding(.horizontal, 14)

            // Right: last transaction
            VStack(alignment: .leading, spacing: 0) {
                SectionLabel("TRANSAKSI TERAKHIR")
                Spacer(minLength: 8)

                if entry.lastTransactionName.isEmpty {
                    Text("Belum ada transaksi.\nCatat pengeluaran pertamamu.")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .lineLimit(3)
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(entry.lastTransactionName)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(UIColor.label))
                            .lineLimit(2)

                        HStack(spacing: 4) {
                            Image(systemName: entry.lastTransactionIsExpense ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(entry.lastTransactionIsExpense ? Color(UIColor.systemRed) : Color(UIColor.systemGreen))
                            Text(entry.lastTransactionAmount.compactIDR())
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(entry.lastTransactionIsExpense ? Color(UIColor.systemRed) : Color(UIColor.systemGreen))
                        }
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                    if let txDate = entry.lastTransactionDate {
                        Text(txDate, format: .dateTime.day().month(.abbreviated).hour().minute())
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    } else {
                        Text("Diperbarui")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .containerBackground(Color(UIColor.systemBackground), for: .widget)
    }
}

// MARK: - Shared Sub-components

private struct AppMark: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "wallet.pass.fill")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tint)
            Text("Cashflow")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color(UIColor.secondaryLabel))
        }
    }
}

private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold, design: .rounded))
            .kerning(0.5)
            .foregroundStyle(Color(UIColor.secondaryLabel))
    }
}

private struct StatusChip: View {
    let burnRatio: Double
    let color: Color
    var label: String {
        burnRatio < 0.5 ? "Aman" : burnRatio < 0.8 ? "Waspada" : "Kritis"
    }
    var icon: String {
        burnRatio < 0.8 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 9, weight: .semibold))
            Text(label).font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Entry View Router

struct CashflowWidgetEntryView: View {
    var entry: CashflowEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.isExpenseOnlyMode {
            switch family {
            case .systemSmall: ExpenseSmallView(entry: entry)
            default:           ExpenseMediumView(entry: entry)
            }
        } else {
            switch family {
            case .systemSmall: NormalSmallView(entry: entry)
            default:           NormalMediumView(entry: entry)
            }
        }
    }
}

// MARK: - Widget Config

struct CashflowWidget: Widget {
    let kind: String = "CashflowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CashflowProvider()) { entry in
            CashflowWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ringkasan Cashflow")
        .description("Pantau keuangan langsung dari layar utama.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
