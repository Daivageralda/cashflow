import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Int = 0

    @AppStorage("use_expense_only_mode") private var useExpenseOnlyMode: Bool = false

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

            ReportsView()
                .tabItem {
                    Label("Laporan", systemImage: "chart.bar.fill")
                }
                .tag(2)

            BudgetListView()
                .tabItem {
                    Label("Budget", systemImage: "target")
                }
                .tag(3)

            NavigationStack {
                List {
                    Section {
                        NavigationLink("Edit Profil") { ProfileEditView() }
                        NavigationLink("Tagihan") { BillsListView() }
                        NavigationLink("Kategori") { CategoryListView() }
                    }
                    
                    Section("Mode Aplikasi") {
                        Toggle("Mode Pengeluaran Saja", isOn: $useExpenseOnlyMode)
                            .tint(Color.accentPrimary)
                    }
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
