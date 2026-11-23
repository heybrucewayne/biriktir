import SwiftUI

struct HomeView: View {
    @Environment(SavingsModel.self) private var model
    var onAddGoal: () -> Void
    var onAddCountdown: () -> Void
    var onAdjust: (UUID, AdjustmentDirection) -> Void
    var onDetail: (UUID) -> Void
    var onCountdownDetail: (UUID) -> Void
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header
                if model.activeGoals.isEmpty {
                    emptyState
                } else {
                    goalSection
                    monthlyCard
                        .offset(y: appeared ? 0 : 16)
                        .opacity(appeared ? 1 : 0)
                }
                if !model.countdowns.isEmpty {
                    countdownSection
                        .offset(y: appeared ? 0 : 18)
                        .opacity(appeared ? 1 : 0)
                }
                Spacer(minLength: 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 22)
        }
        .onAppear { withAnimation(.easeOut(duration: 0.65)) { appeared = true } }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Biriktir")
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .tracking(-0.8)
                .foregroundStyle(.white)
            Spacer()
            Menu {
                Button(action: onAddGoal) {
                    Label("Hedef oluştur", systemImage: "target")
                }
                Button(action: onAddCountdown) {
                    Label("Geri sayım ekle", systemImage: "calendar")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .liquidGlass(in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.17), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Yeni ekle")
        }
    }

    private var monthlyCard: some View {
        let months = model.monthlyTotals()
        let shape = RoundedRectangle(cornerRadius: 23, style: .continuous)
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.mint)
                    Eyebrow(title: "Bu ay biriktirdin")
                }
                Text(Money.string(model.currentMonthDeposits))
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .tracking(-0.6)
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
            Spacer(minLength: 0)
            MiniSparkline(values: months.map(\.amount), color: AppColors.lavender)
                .frame(width: 106, height: 40)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(in: shape)
        .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.20), .white.opacity(0.045)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .shadow(color: .black.opacity(0.2), radius: 18, y: 9)
    }

    private var goalSection: some View {
        VStack(spacing: 12) {
            ForEach(model.orderedGoals) { goal in
                GoalWidget(
                    goal: goal,
                    onDetail: { onDetail(goal.id) },
                    onAdjust: { direction in onAdjust(goal.id, direction) }
                )
            }
        }
    }

    private var countdownSection: some View {
        VStack(spacing: 12) {
            ForEach(model.orderedCountdowns) { countdown in
                CountdownCard(countdown: countdown) {
                    onCountdownDetail(countdown.id)
                }
            }
        }
    }

    private var emptyState: some View {
        GlassPanel {
            VStack(spacing: 12) {
                AnimatedGIFView(resourceName: "BiriktirCatStanding")
                    .frame(width: 132, height: 124)
                    .accessibilityHidden(true)
                Text("İlk hedefini belirle").font(.system(size: 20, weight: .semibold, design: .rounded))
                Button(action: onAddGoal) { Label("Hedef oluştur", systemImage: "plus") }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
        }
    }
}

struct GoalWidget: View {
    let goal: SavingsGoal
    var onDetail: () -> Void
    var onAdjust: (AdjustmentDirection) -> Void

    var body: some View {
        VStack(spacing: 14) {
            Button(action: onDetail) {
                VStack(alignment: .leading, spacing: 13) {
                    HStack(spacing: 8) {
                        Image(systemName: goal.symbol)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.blue)
                        Text(goal.name)
                            .font(.system(size: 19, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        Spacer(minLength: 4)
                        Text(verbatim: AppLanguage.current == .english
                             ? "\(Money.percent(goal.progress * 100))%"
                             : "%\(Money.percent(goal.progress * 100))")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.lavender)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(AppColors.lavender.opacity(0.10), in: Capsule())
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.42))
                    }

                    HStack(alignment: .bottom, spacing: 12) {
                        progressAmount(title: "Biriken", amount: goal.currentAmount, alignment: .leading)
                        Spacer(minLength: 8)
                        progressAmount(title: "Kalan", amount: max(0, goal.targetAmount - goal.currentAmount), alignment: .trailing)
                    }

                    LuminousGoalProgressBar(progress: goal.progress)
                        .frame(height: 15)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(goal.name), \(Money.string(goal.currentAmount)) birikti, \(Money.string(max(0, goal.targetAmount - goal.currentAmount))) kaldı, ayrıntıları aç")

            HStack(spacing: 8) {
                ActionTile(title: "Ekle", symbol: "plus", tint: AppColors.mint) { onAdjust(.deposit) }
                ActionTile(title: "Çıkar", symbol: "minus", tint: .white.opacity(0.84)) { onAdjust(.withdraw) }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.12, green: 0.125, blue: 0.17).opacity(0.62), Color(red: 0.055, green: 0.06, blue: 0.08).opacity(0.74)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .liquidGlass(in: RoundedRectangle(cornerRadius: 25, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 25, style: .continuous).strokeBorder(LinearGradient(colors: [.white.opacity(0.20), .white.opacity(0.045)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .shadow(color: AppColors.lavender.opacity(0.055), radius: 16, y: 8)
    }

    private func progressAmount(title: String, amount: Int, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 3) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .tracking(0.7)
                .textCase(.uppercase)
                .foregroundStyle(AppColors.secondary)
            Text(Money.string(amount))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .tracking(-0.2)
                .foregroundStyle(.white.opacity(0.94))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .contentTransition(.numericText())
        }
    }
}

private struct LuminousGoalProgressBar: View {
    let progress: Double
    @State private var animatedProgress = 0.0

    var body: some View {
        GeometryReader { geometry in
            let fillWidth = geometry.size.width * min(max(animatedProgress, 0), 1)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LinearGradient(colors: [AppColors.lavender.opacity(0.14), .white.opacity(0.075)], startPoint: .leading, endPoint: .trailing))
                if fillWidth > 0 {
                    Capsule()
                        .fill(AppColors.lavender.opacity(0.52))
                        .frame(width: fillWidth)
                        .blur(radius: 8)
                    Capsule()
                        .fill(LinearGradient(colors: [AppColors.blue, AppColors.lavender, .white.opacity(0.96)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: fillWidth)
                        .overlay(alignment: .trailing) {
                            if fillWidth > 9 {
                                Capsule().fill(.white.opacity(0.92)).frame(width: 2, height: 9).padding(.trailing, 2)
                            }
                        }
                        .shadow(color: AppColors.lavender.opacity(0.78), radius: 8, y: 0)
                }
                Capsule().strokeBorder(.white.opacity(0.14), lineWidth: 1)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.9, dampingFraction: 0.82).delay(0.12)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.84)) {
                animatedProgress = newValue
            }
        }
        .accessibilityHidden(true)
    }
}

private struct CountdownCard: View {
    let countdown: CountdownItem
    var action: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let days = countdown.daysRemaining(asOf: context.date)
            let accessibilityDays = days.map { value in
                if value == 0 { return AppLanguage.current == .english ? "today" : "bugün" }
                if AppLanguage.current == .english { return value == 1 ? "1 day left" : "\(value) days left" }
                return "\(value) gün kaldı"
            } ?? (AppLanguage.current == .english ? "expired" : "süre geçti")
            Button(action: action) {
                GlassPanel(radius: 23) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(countdown.name)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .tracking(-0.3)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            if let days {
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text("\(days)")
                                        .font(.system(size: 46, weight: .semibold, design: .rounded))
                                        .tracking(-1.2)
                                        .foregroundStyle(AppColors.lavender)
                                        .contentTransition(.numericText())
                                    Text(LocalizedStringKey(days == 0 ? "BUGÜN" : (days == 1 ? "1 GÜN KALDI" : "GÜN KALDI")))
                                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                                        .tracking(0.9)
                                        .foregroundStyle(AppColors.secondary)
                                }
                            } else {
                                Text("SÜRE GEÇTİ")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .tracking(0.6)
                                    .foregroundStyle(.orange)
                            }
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.48))
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.055), in: Circle())
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(countdown.name), \(accessibilityDays)")
            .accessibilityHint("Geri sayım ayrıntılarını görüntüle")
            .animation(.easeInOut(duration: 0.25), value: days)
        }
    }
}

struct GoalCelebrationToast: View {
    let milestone: Int?
    let goalName: String

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)
        HStack(spacing: 10) {
            AnimatedGIFView(resourceName: "BiriktirCat")
                .frame(width: 42, height: 42)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    if let milestone {
                        HStack(spacing: 3) {
                            Text(verbatim: AppLanguage.current == .english ? "\(milestone)%" : "%\(milestone)")
                            Text("tamamlandı")
                        }
                    } else {
                        Text("Hedef tamamlandı")
                    }
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                Text(goalName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColors.lavender)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .liquidGlass(in: shape)
        .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.24), .white.opacity(0.07)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .shadow(color: AppColors.lavender.opacity(0.24), radius: 18, y: 8)
        .accessibilityElement(children: .combine)
    }
}

private struct ActionTile: View {
    let title: String
    let symbol: String
    let tint: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tint)
                Text(LocalizedStringKey(title))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(.white.opacity(0.12), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct GoalRow: View {
    let goal: SavingsGoal
    var isPrimary = false
    var onOpen: () -> Void
    var onSetPrimary: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onOpen) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().stroke(.white.opacity(0.10), lineWidth: 3)
                        Circle().trim(from: 0, to: goal.progress).stroke(AppColors.lavender, style: StrokeStyle(lineWidth: 3, lineCap: .round)).rotationEffect(.degrees(-90))
                        Image(systemName: goal.symbol).font(.system(size: 14, weight: .medium)).foregroundStyle(AppColors.blue)
                    }
                    .frame(width: 42, height: 42)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(goal.name).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                        Text("\(Money.string(goal.currentAmount)) / \(Money.string(goal.targetAmount))")
                            .font(.system(size: 11, weight: .medium)).foregroundStyle(AppColors.secondary)
                    }
                    Spacer(minLength: 2)
                    Text("%\(Int(goal.progress * 100))").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.lavender)
                    Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundStyle(.white.opacity(0.38))
                }
            }
            .buttonStyle(.plain)

            if let onSetPrimary {
                Button(action: onSetPrimary) {
                    Image(systemName: isPrimary ? "star.fill" : "star")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isPrimary ? AppColors.lavender : AppColors.secondary)
                        .frame(width: 34, height: 34)
                        .background(isPrimary ? AppColors.lavender.opacity(0.14) : .white.opacity(0.045), in: Circle())
            }
                .buttonStyle(.plain)
                .accessibilityLabel(isPrimary ? "Ana sayfadaki öncelikli hedef" : "Ana sayfada öncelikli hedef yap")
                .disabled(isPrimary)
            }
        }
        .padding(14)
        .liquidGlass(in: RoundedRectangle(cornerRadius: 21, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(.white.opacity(0.10), lineWidth: 1))
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color(red: 0.07, green: 0.06, blue: 0.12))
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .background(LinearGradient(colors: [Color.white, AppColors.lavender.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing), in: Capsule())
            .shadow(color: AppColors.lavender.opacity(0.2), radius: 14, y: 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
