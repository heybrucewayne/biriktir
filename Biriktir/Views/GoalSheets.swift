import SwiftUI
import UIKit

struct AddGoalSheet: View {
    @Environment(SavingsModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var targetInput = ""
    @State private var monthlyInput = ""
    @State private var targetDate = Calendar.current.date(byAdding: .year, value: 1, to: .now) ?? .now
    @State private var selectedSymbol = GoalSymbols.choices[0].0

    private var target: Int { Money.input(targetInput) ?? 0 }
    private var monthly: Int { Money.input(monthlyInput) ?? 0 }
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && target > 0 }

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                sheetHeader(title: "Yeni hedef") { dismiss() }
                    .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 7)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        formSection("Hedef adı") {
                            TextField("Yeni evim", text: $name)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                        }
                        LazyVGrid(columns: columns, spacing: 9) {
                            ForEach(GoalSymbols.choices, id: \.0) { symbol, title in
                                let selected = selectedSymbol == symbol
                                Button { withAnimation(.easeInOut(duration: 0.18)) { selectedSymbol = symbol } } label: {
                                    VStack(spacing: 8) {
                                        Image(systemName: symbol).font(.system(size: 18, weight: .medium))
                                        Text(LocalizedStringKey(title)).font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundStyle(selected ? .white : AppColors.secondary)
                                    .frame(maxWidth: .infinity).frame(height: 70)
                                    .background(selected ? AppColors.lavender.opacity(0.18) : .white.opacity(0.035), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(selected ? AppColors.lavender.opacity(0.55) : .white.opacity(0.08), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        HStack(spacing: 10) {
                            formSection("Hedef tutarı") { moneyField("2.000.000", text: $targetInput) }
                            formSection("Aylık plan") { moneyField("25.000", text: $monthlyInput) }
                        }
                        formSection("Hedef tarihi") {
                            DatePicker("", selection: $targetDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(AppColors.lavender)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Button(action: saveGoal) {
                            Text("Hedefimi oluştur")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!canSave)
                        .opacity(canSave ? 1 : 0.48)
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 20).padding(.top, 17).padding(.bottom, 28)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func saveGoal() {
        guard canSave else { return }
        model.addGoal(name: name.trimmingCharacters(in: .whitespacesAndNewlines), target: target,
                      monthly: monthly, date: targetDate, symbol: selectedSymbol)
        dismiss()
    }
}

struct AddCountdownSheet: View {
    @Environment(SavingsModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var targetDate = Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 20) {
                sheetHeader(title: "Geri sayım ekle") { dismiss() }
                formSection("Geri sayım adı") {
                    TextField("Tatile kalan gün", text: $name)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(false)
                }
                formSection("Tarih") {
                    DatePicker("", selection: $targetDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(AppColors.lavender)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer(minLength: 0)
                Button(action: saveCountdown) {
                    Text("Geri sayım oluştur")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.45)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 23)
        }
        .preferredColorScheme(.dark)
    }

    private func saveCountdown() {
        guard canSave else { return }
        model.addCountdown(name: name.trimmingCharacters(in: .whitespacesAndNewlines), date: targetDate)
        dismiss()
    }
}

struct AdjustmentSheet: View {
    @Environment(SavingsModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let goalID: UUID
    let direction: AdjustmentDirection
    @State private var amountInput = ""

    private var goal: SavingsGoal? { model.goal(id: goalID) }
    private var amount: Int { Money.input(amountInput) ?? 0 }
    private var isDeposit: Bool { direction == .deposit }

    var body: some View {
        ZStack {
            AppBackground()
            VStack(alignment: .leading, spacing: 20) {
                sheetHeader(title: isDeposit ? "Birikim ekle" : "Birikim çıkar") { dismiss() }
                Text(goal?.name ?? "")
                    .font(.system(size: 23, weight: .semibold, design: .rounded)).tracking(-0.3)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("₺").font(.system(size: 24, weight: .medium, design: .rounded)).foregroundStyle(AppColors.secondary)
                    TextField("0", text: $amountInput)
                        .font(.system(size: 38, weight: .semibold, design: .rounded))
                        .keyboardType(.numberPad)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .padding(.horizontal, 18).padding(.vertical, 18)
                .liquidGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(.white.opacity(0.12), lineWidth: 1))
                HStack(spacing: 8) {
                    ForEach([10_000, 25_000, 50_000], id: \.self) { preset in
                        Button { withAnimation(.easeOut(duration: 0.15)) { amountInput = String(preset) } } label: {
                            Text(Money.string(preset))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(AppColors.secondary)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(.white.opacity(0.055), in: Capsule())
                                .overlay(Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                    }
                }
                if let goal {
                    HStack {
                        Text("Mevcut birikim").foregroundStyle(AppColors.secondary)
                        Spacer()
                        Text(Money.string(goal.currentAmount)).foregroundStyle(.white)
                    }
                    .font(.system(size: 13, weight: .medium))
                }
                Spacer(minLength: 0)
                Button(action: saveAdjustment) {
                    Text(LocalizedStringKey(isDeposit ? "Birikime ekle" : "Birikimden çıkar")).frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(amount == 0)
                .opacity(amount == 0 ? 0.45 : 1)
            }
            .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 23)
        }
        .preferredColorScheme(.dark)
    }

    private func saveAdjustment() {
        guard amount > 0 else { return }
        model.adjust(goalID: goalID, by: isDeposit ? amount : -amount)
        if isDeposit {
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.prepare()
            feedback.impactOccurred(intensity: 0.75)
        }
        dismiss()
    }
}

struct CountdownDetailSheet: View {
    @Environment(SavingsModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let countdownID: UUID
    @State private var confirmsDelete = false

    private var countdown: CountdownItem? { model.countdown(id: countdownID) }

    var body: some View {
        ZStack {
            AppBackground()
            if let countdown {
                VStack(spacing: 20) {
                    sheetHeader(title: "Geri sayım") { dismiss() }
                    GlassPanel(radius: 26) {
                        VStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(AppColors.lavender)
                                .frame(width: 48, height: 48)
                                .background(AppColors.lavender.opacity(0.12), in: Circle())
                            Text(countdown.name)
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                            if let days = countdown.daysRemaining() {
                                HStack(alignment: .firstTextBaseline, spacing: 7) {
                                    Text("\(days)")
                                        .font(.system(size: 58, weight: .semibold, design: .rounded))
                                        .tracking(-1.5)
                                        .foregroundStyle(AppColors.lavender)
                                    Text(LocalizedStringKey(days == 0 ? "BUGÜN" : (days == 1 ? "1 GÜN KALDI" : "GÜN KALDI")))
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .tracking(0.9)
                                        .foregroundStyle(AppColors.secondary)
                                }
                            } else {
                                Text("Süre geçti")
                                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.orange)
                            }
                            Text(dateText(countdown.targetDate))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppColors.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    Spacer(minLength: 0)
                    Button(role: .destructive) {
                        confirmsDelete = true
                    } label: {
                        Text("Geri sayımı sil")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.red.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(.red.opacity(0.08), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 23)
                .confirmationDialog("Geri sayım silinsin mi?", isPresented: $confirmsDelete, titleVisibility: .visible) {
                    Button("Geri sayımı sil", role: .destructive) {
                        model.deleteCountdown(id: countdown.id)
                        dismiss()
                    }
                    Button("Vazgeç", role: .cancel) {}
                }
            } else {
                ProgressView().tint(AppColors.lavender)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func dateText(_ date: Date) -> String {
        AppLanguage.dateString(date, dateStyle: .long)
    }
}

struct GoalDetailSheet: View {
    @Environment(SavingsModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let goalID: UUID
    var onAdjust: (AdjustmentDirection) -> Void

    private var goal: SavingsGoal? { model.goal(id: goalID) }

    var body: some View {
        ZStack {
            AppBackground()
            if let goal {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        sheetHeader(title: "Hedef detayı") { dismiss() }
                        GlassPanel(radius: 27) {
                            HStack(spacing: 18) {
                                ZStack {
                                    ProgressRing(progress: goal.progress, size: 86, lineWidth: 6)
                                    Image(systemName: goal.symbol).font(.system(size: 22, weight: .medium)).foregroundStyle(AppColors.blue)
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(goal.name).font(.system(size: 21, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                                    Text(Money.string(goal.currentAmount)).font(.system(size: 23, weight: .semibold, design: .rounded)).foregroundStyle(.white)
                Text("Hedef: \(Money.string(goal.targetAmount))").font(.system(size: 12)).foregroundStyle(AppColors.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                        HStack(spacing: 10) {
                            DetailMetric(title: "Kalan tutar", value: Money.string(max(0, goal.targetAmount - goal.currentAmount)), symbol: "scope")
                            DetailMetric(title: "Aylık plan", value: Money.string(goal.monthlyTarget), symbol: "calendar")
                        }
                        HStack(spacing: 10) {
                            Button { onAdjust(.deposit) } label: { Label("Ekle", systemImage: "plus").frame(maxWidth: .infinity) }
                                .buttonStyle(PrimaryButtonStyle())
                            Button { onAdjust(.withdraw) } label: { Label("Çıkar", systemImage: "minus").frame(maxWidth: .infinity) }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.vertical, 13)
                                .background(.white.opacity(0.08), in: Capsule())
                                .overlay(Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1))
                        }
                        let recentEntries = model.entries(for: goal.id).prefix(8)
                        if !recentEntries.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Son hareketler")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white)
                                VStack(spacing: 0) {
                                    ForEach(Array(recentEntries)) { entry in
                                        EntryRow(entry: entry)
                                        if entry.id != recentEntries.last?.id {
                                            Rectangle().fill(.white.opacity(0.07)).frame(height: 1).padding(.leading, 50)
                                        }
                                    }
                                }
                            }
                            .padding(18)
                            .liquidGlass(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(.white.opacity(0.1), lineWidth: 1))
                        }
                        Spacer(minLength: 12)
                    }
                    .padding(.horizontal, 20).padding(.top, 14).padding(.bottom, 28)
                }
            } else {
                ProgressView().tint(AppColors.lavender)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct DetailMetric: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        GlassPanel(radius: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: symbol).font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.lavender)
                Text(value).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(.white).lineLimit(1).minimumScaleFactor(0.75)
                Text(LocalizedStringKey(title)).font(.system(size: 10, weight: .medium)).foregroundStyle(AppColors.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct EntryRow: View {
    let entry: SavingsEntry
    private var dateText: String {
        AppLanguage.dateString(entry.date, dateStyle: .medium, timeStyle: .short)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.isDeposit ? "arrow.down.left" : "arrow.up.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(entry.isDeposit ? AppColors.mint : .white.opacity(0.75))
                .frame(width: 38, height: 38)
                .background((entry.isDeposit ? AppColors.mint : Color.white).opacity(0.09), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(LocalizedStringKey(entry.isDeposit ? "Birikim eklendi" : "Birikim çıkarıldı"))
                    .font(.system(size: 13, weight: .medium)).foregroundStyle(.white)
                Text(dateText).font(.system(size: 10, weight: .medium)).foregroundStyle(AppColors.secondary)
            }
            Spacer()
            Text("\(entry.isDeposit ? "+" : "−")\(Money.string(abs(entry.amount)))")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(entry.isDeposit ? AppColors.mint : .white.opacity(0.82))
        }
        .padding(.vertical, 9)
    }
}

private func sheetHeader(title: String, close: @escaping () -> Void) -> some View {
    HStack {
        Button(action: close) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.secondary)
                .frame(width: 35, height: 35)
                .background(.white.opacity(0.075), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Kapat")
        Spacer()
        Text(LocalizedStringKey(title)).font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundStyle(.white)
        Spacer()
        Color.clear.frame(width: 35, height: 35)
    }
}

private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(LocalizedStringKey(title)).font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.secondary)
        content()
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 14).frame(minHeight: 48)
            .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.white.opacity(0.09), lineWidth: 1))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

private func moneyField(_ placeholder: String, text: Binding<String>) -> some View {
    HStack(spacing: 5) {
        Text("₺").foregroundStyle(AppColors.secondary)
        TextField(placeholder, text: text).keyboardType(.numberPad)
    }
}
