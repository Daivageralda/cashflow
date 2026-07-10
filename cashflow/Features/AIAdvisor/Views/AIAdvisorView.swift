import SwiftUI
import SwiftData

struct AIAdvisorView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AIAdvisorViewModel?

    private let suggestions = [
        "Berapa proyeksi saldo akhir bulan?",
        "Kategori mana yang paling banyak pengeluarannya?",
        "Apakah pengeluaranku normal bulan ini?",
        "Bagaimana kondisi keuanganku secara umum?",
        "Tips memotong pengeluaran hemat?"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let vm = viewModel {
                    // Chat Area
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: Spacing.s16) {
                                ForEach(vm.messages) { msg in
                                    chatBubble(msg)
                                        .id(msg.id)
                                }

                                if vm.isSending {
                                    loadingBubble
                                        .id("loading")
                                }
                            }
                            .padding(Spacing.s16)
                        }
                        .background(Color.bgPrimary)
                        .onChange(of: vm.messages.count) { _, _ in
                            if let lastId = vm.messages.last?.id {
                                withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                            }
                        }
                        .onChange(of: vm.isSending) { _, new in
                            if new {
                                withAnimation { proxy.scrollTo("loading", anchor: .bottom) }
                            }
                        }
                    }

                    // Predefined suggestions
                    if vm.messages.count == 1 {
                        suggestionChips(vm: vm)
                    }

                    // Input Field Area
                    inputArea(vm: vm)
                }
            }
            .background(Color.bgPrimary)
            .navigationTitle("AI Advisor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        viewModel?.clearChat()
                    }
                    .font(.cashflowSubheadline)
                    .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = AIAdvisorViewModel(modelContext: modelContext)
            }
        }
    }

    private func chatBubble(_ msg: AIMessage) -> some View {
        let isUser = msg.role == "user"

        return HStack {
            if isUser { Spacer() }

            VStack(alignment: isUser ? .trailing : .leading, spacing: Spacing.s4) {
                Text(msg.content)
                    .font(.cashflowBody)
                    .padding(.horizontal, Spacing.s16)
                    .padding(.vertical, Spacing.s12)
                    .foregroundStyle(isUser ? Color.white : Color.textPrimary)
                    .background(
                        isUser ? Color.accentPrimary : Color.bgSecondary,
                        in: RoundedRectangle(cornerRadius: Radius.md)
                    )
            }

            if !isUser { Spacer() }
        }
    }

    private var loadingBubble: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.s4) {
                HStack(spacing: Spacing.s4) {
                    Circle().fill(Color.textTertiary).frame(width: 6, height: 6)
                    Circle().fill(Color.textTertiary).frame(width: 6, height: 6)
                    Circle().fill(Color.textTertiary).frame(width: 6, height: 6)
                }
                .padding(.horizontal, Spacing.s16)
                .padding(.vertical, Spacing.s12)
                .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.md))
            }
            Spacer()
        }
    }

    private func suggestionChips(vm: AIAdvisorViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.s8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        Task { await vm.sendQuery(suggestion) }
                    } label: {
                        Text(suggestion)
                            .font(.cashflowCaption1)
                            .foregroundStyle(Color.accentPrimary)
                            .padding(.horizontal, Spacing.s12)
                            .padding(.vertical, Spacing.s8)
                            .background(Color.bgSecondary, in: Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.accentPrimary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.s16)
            .padding(.vertical, Spacing.s8)
        }
        .background(Color.bgPrimary)
    }

    private func inputArea(vm: AIAdvisorViewModel) -> some View {
        VStack(spacing: 0) {
            Divider().background(Color.borderDefault)

            HStack(spacing: Spacing.s12) {
                TextField("Tanya seputar keuanganmu...", text: Binding(
                    get: { vm.inputQuery },
                    set: { vm.inputQuery = $0 }
                ))
                .font(.cashflowBody)
                .padding(Spacing.s12)
                .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
                .disabled(vm.isSending)

                Button {
                    let query = vm.inputQuery
                    Task { await vm.sendQuery(query) }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(vm.inputQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.textTertiary : Color.accentPrimary)
                }
                .disabled(vm.inputQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
            }
            .padding(Spacing.s12)
            .background(Color.bgPrimary)
        }
    }
}
