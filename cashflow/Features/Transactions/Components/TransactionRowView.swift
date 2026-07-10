import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: Spacing.s12) {
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: transaction.category?.icon ?? "questionmark.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(categoryColor)
            }

            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(transaction.category?.name ?? "Lainnya")
                    .font(.cashflowSubheadline)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)

                HStack(spacing: Spacing.s4) {
                    if !transaction.note.isEmpty {
                        Text(transaction.note)
                            .font(.cashflowFootnote)
                            .foregroundStyle(Color.textTertiary)
                            .lineLimit(1)
                    } else {
                        Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.cashflowFootnote)
                            .foregroundStyle(Color.textTertiary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Spacing.s4) {
                Text(amountText)
                    .font(.cashflowSubheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(amountColor)
                    .cashflowMonospacedDigits()

                Text(transaction.date.formatted(.dateTime.hour().minute()))
                    .font(.cashflowCaption1)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(.horizontal, Spacing.s16)
        .padding(.vertical, Spacing.s12)
        .contentShape(Rectangle())
    }

    private var categoryColor: Color {
        Color(hex: transaction.category?.colorHex ?? "#8A877E")
    }

    private var amountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return prefix + transaction.amount.formatted(.currency(code: "IDR").presentation(.narrow))
    }

    private var amountColor: Color {
        transaction.type == .income ? Color.stateSuccess : Color.textPrimary
    }
}
