import SwiftUI
import Charts
import SwiftData

struct ReportsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var viewModel: ReportsViewModel?
    @State private var selectedSegment: Int = 0
    @AppStorage("enable_ai_advisor") private var enableAIAdvisor: Bool = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mode", selection: $selectedSegment) {
                    Text("Analitik").tag(0)
                    Text("Koleksi Stiker").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, Spacing.s16)
                .padding(.top, Spacing.s12)
                .padding(.bottom, Spacing.s8)
                
                if selectedSegment == 0 {
                    ScrollView {
                        VStack(spacing: Spacing.s24) {
                            if let vm = viewModel {
                                // Card Insight
                                if enableAIAdvisor {
                                    insightCard(message: vm.generatedInsight)
                                }

                                // Chart 1: Donut Breakdown
                                categoryBreakdownSection(reports: vm.categoryReports)

                                // Chart 2: Daily Trend Line
                                dailyTrendSection(trends: vm.dailyTrends)

                                // Chart 3: Monthly Comparison Bars
                                monthlyComparisonSection(comparisons: vm.monthlyComparisons)
                            }
                        }
                        .padding(Spacing.s16)
                    }
                } else {
                    GeometryReader { geo in
                        VStack(alignment: .leading, spacing: Spacing.s16) {
                            Text("Stiker Transaksi Bulan Ini")
                                .font(.cashflowSubheadline)
                                .foregroundStyle(Color.textSecondary)
                                .padding(.horizontal, Spacing.s16)
                                .padding(.top, Spacing.s8)
                            
                            StickerPilePhysicsView(
                                transactions: transactions,
                                canvasHeight: min(560, max(280, geo.size.height * 0.75))
                            )
                            .padding(.horizontal, Spacing.s16)
                        }
                    }
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle("Laporan Analitik")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            if viewModel == nil {
                viewModel = ReportsViewModel(modelContext: modelContext)
            }
            await viewModel?.refresh()
        }
    }

    private func insightCard(message: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(Color.accentPrimary)

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text("AI Insight")
                    .font(.cashflowSubheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)

                Text(message)
                    .font(.cashflowCallout)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(nil)
            }
        }
        .padding(Spacing.s16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
    }

    private func categoryBreakdownSection(reports: [CategoryReport]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Breakdown Pengeluaran")
                .font(.cashflowHeadline)
                .foregroundStyle(Color.textPrimary)

            if reports.isEmpty {
                Text("Belum ada pengeluaran bulan ini.")
                    .font(.cashflowBody)
                    .foregroundStyle(Color.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, Spacing.s32)
            } else {
                Chart(reports) { item in
                    SectorMark(
                        angle: .value("Pengeluaran", item.totalAmount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .cornerRadius(4)
                    .foregroundStyle(Color(hex: item.colorHex))
                }
                .frame(height: 200)

                // Legends
                VStack(spacing: Spacing.s8) {
                    ForEach(reports.prefix(4)) { item in
                        HStack {
                            Circle()
                                .fill(Color(hex: item.colorHex))
                                .frame(width: 8, height: 8)
                            Text(item.categoryName)
                                .font(.cashflowCaption1)
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(item.totalAmount.formatted(.currency(code: "IDR").presentation(.narrow)))
                                .font(.cashflowCaption1)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.textPrimary)
                                .cashflowMonospacedDigits()
                        }
                    }
                }
            }
        }
        .padding(Spacing.s16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
    }

    private func dailyTrendSection(trends: [DailyTrend]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Tren Belanja 30 Hari Terakhir")
                .font(.cashflowHeadline)
                .foregroundStyle(Color.textPrimary)

            Chart(trends) { item in
                AreaMark(
                    x: .value("Tanggal", item.date, unit: .day),
                    y: .value("Pengeluaran", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentPrimary.opacity(0.3), Color.accentPrimary.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Tanggal", item.date, unit: .day),
                    y: .value("Pengeluaran", item.amount)
                )
                .foregroundStyle(Color.accentPrimary)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
        }
        .padding(Spacing.s16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
    }

    private func monthlyComparisonSection(comparisons: [MonthlyComparison]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Perbandingan Bulanan")
                .font(.cashflowHeadline)
                .foregroundStyle(Color.textPrimary)

            Chart {
                ForEach(comparisons) { item in
                    BarMark(
                        x: .value("Bulan", item.monthName),
                        y: .value("Pemasukan", item.income)
                    )
                    .foregroundStyle(Color.stateSuccess)

                    BarMark(
                        x: .value("Bulan", item.monthName),
                        y: .value("Pengeluaran", item.expense)
                    )
                    .foregroundStyle(Color.stateCritical)
                }
            }
            .frame(height: 200)
            .chartLegend(position: .bottom, alignment: .center, spacing: 10)
        }
        .padding(Spacing.s16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
    }
}
