import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Int = 0
    @State private var showingDeleteDataConfirmation = false
    @State private var showingDeleteAccountConfirmation = false

    @AppStorage("use_expense_only_mode") private var useExpenseOnlyMode: Bool = false
    @AppStorage("app_theme_selection") private var appThemeSelection: String = "system"
    @AppStorage("enable_ai_advisor") private var enableAIAdvisor: Bool = true

    @ObservedObject private var syncEngine = SyncEngine.shared

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
                    } header: {
                        Text("Pengaturan Dasar")
                    }
                    
                    Section {
                        HStack {
                            Text("Status")
                            Spacer()
                            if syncEngine.isSyncing {
                                ProgressView()
                                    .padding(.trailing, 4)
                            } else {
                                if syncEngine.syncStatusMessage == "Sinkronisasi Selesai" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else if syncEngine.syncStatusMessage == "Koneksi Gagal" || syncEngine.syncStatusMessage == "Cadangan Gagal" {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            Text(syncEngine.syncStatusMessage == "Sinkronisasi Selesai" ? "Tersinkron" : syncEngine.syncStatusMessage)
                                .foregroundColor(
                                    syncEngine.syncStatusMessage == "Sinkronisasi Selesai" ? .green :
                                    (syncEngine.syncStatusMessage == "Koneksi Gagal" || syncEngine.syncStatusMessage == "Cadangan Gagal" ? .red :
                                    (syncEngine.isOnline ? .primary : .secondary))
                                )
                        }
                        
                        HStack {
                            Text("Penyimpanan Cadangan")
                            Spacer()
                            Text(ByteCountFormatter.string(fromByteCount: syncEngine.totalDataSyncedBytes, countStyle: .file))
                                .foregroundColor(.secondary)
                        }
                        
                        if let lastSynced = syncEngine.lastSyncedAt {
                            HStack {
                                Text("Terakhir Diperbarui")
                                Spacer()
                                Text(lastSynced, style: .time)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button {
                            Task {
                                await syncEngine.triggerSync()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text(syncEngine.isSyncing ? "Menyinkronkan..." : "Cadangkan Sekarang")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .disabled(!syncEngine.isOnline || syncEngine.isSyncing)
                    } header: {
                        Text("Penyimpanan Awan")
                    }
                    
                    Section {
                        Toggle("Mode Pengeluaran Saja", isOn: $useExpenseOnlyMode)
                            .tint(Color.accentPrimary)
                        
                        Picker("Tampilan Tema", selection: $appThemeSelection) {
                            Text("Sistem").tag("system")
                            Text("Terang").tag("light")
                            Text("Gelap").tag("dark")
                        }
                        
                        Toggle("Aktifkan AI Advisor", isOn: $enableAIAdvisor)
                            .tint(Color.accentPrimary)
                    } header: {
                        Text("Mode Aplikasi")
                    }

                    Section {
                        Button(role: .destructive) {
                            showingDeleteDataConfirmation = true
                        } label: {
                            Label("Hapus Semua Data & Cloud", systemImage: "trash")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAccountConfirmation = true
                        } label: {
                            Label("Hapus Akun Permanen", systemImage: "person.crop.circle.badge.xmark")
                        }
                    } header: {
                        Text("Keamanan & Penghapusan")
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.bgPrimary)
                .navigationTitle("Pengaturan")
                .confirmationDialog(
                    "Hapus Semua Data?",
                    isPresented: $showingDeleteDataConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Hapus Semua Data", role: .destructive) {
                        Task {
                            try? await SupabaseService.shared.clearCloudData()
                            SyncEngine.shared.clearLocalData(context: modelContext)
                        }
                    }
                    Button("Batal", role: .cancel) {}
                } message: {
                    Text("Tindakan ini akan menghapus permanen semua catatan transaksi di perangkat ini dan cadangan cloud Anda.")
                }
                .confirmationDialog(
                    "Hapus Akun Anda?",
                    isPresented: $showingDeleteAccountConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Hapus Akun Permanen", role: .destructive) {
                        Task {
                            try? await SupabaseService.shared.deleteAccount()
                            SyncEngine.shared.clearLocalData(context: modelContext)
                        }
                    }
                    Button("Batal", role: .cancel) {}
                } message: {
                    Text("Tindakan ini menghapus akun dan seluruh data cadangan di server cloud selamanya.")
                }
            }
            .tabItem {
                Label("Pengaturan", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(Color.accentPrimary)
        .preferredColorScheme(
            appThemeSelection == "light" ? .light : (appThemeSelection == "dark" ? .dark : nil)
        )
    }
}
