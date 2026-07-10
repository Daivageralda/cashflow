import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Beranda", systemImage: "house.fill")
                }
                .tag(0)

            TransactionListView()
                .tabItem {
                    Label("Transaksi", systemImage: "arrow.left.arrow.right")
                }
                .tag(1)

            BudgetListView()
                .tabItem {
                    Label("Budget", systemImage: "target")
                }
                .tag(2)

            AIAdvisorView()
                .tabItem {
                    Label("AI", systemImage: "sparkles")
                }
                .tag(3)

            NavigationStack {
                List {
                    NavigationLink("Laporan") { ReportsView() }
                    NavigationLink("Tagihan") { BillsListView() }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.bgPrimary)
                .navigationTitle("Lainnya")
            }
            .tabItem {
                Label("Lainnya", systemImage: "ellipsis")
            }
            .tag(4)
        }
        .tint(Color.accentPrimary)
    }
}
