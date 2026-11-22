import SwiftUI

struct HomeView: View {
    @Environment(SavingsModel.self) private var model
    var onAddMenu: () -> Void
    var onAddGoal: () -> Void
    var onAddCountdown: () -> Void
    var onAdjust: (UUID, AdjustmentDirection) -> Void
    var onDetail: (UUID) -> Void
    var onCountdownDetail: (UUID) -> Void
    var onGoals: () -> Void
    var onReports: () -> Void
    @State private var appeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header
                if let goal = model.primaryGoal {
                    GoalHero(goal: goal, onDetail: { onDetail(goal.id) },
                             onAdjust: { direction in onAdjust(goal.id, direction) },
                             onReports: onReports)
                        .offset(y: appeared ? 0 : 12)
                        .opacity(appeared ? 1 : 0)
                    monthlyCard
                        .offset(y: appeared ? 0 : 16)
                        .opacity(appeared ? 1 : 0)
                } else {
                    emptyState
                }
                if !model.countdowns.isEmpty {
                    countdownSection
                        .offset(y: appeared ? 0 : 18)
                        .opacity(appeared ? 1 : 0)
                }
                if model.activeGoals.count > 1 {
                    goalSection
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
            Button(action: onAddMenu) {
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
            HStack {
                Text("Hedeflerin")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Button(action: onGoals) {
                    HStack(spacing: 4) {
                        Text("Tümünü gör")
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold))
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.secondary)
                }
                .buttonStyle(.plain)
            }
            ForEach(model.activeGoals.filter { $0.id != model.primaryGoal?.id }) { goal in
                GoalRow(goal: goal, onOpen: { onDetail(goal.id) })
            }
        }
    }

    private var countdownSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Geri sayımlar")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Spacer()
                Button(action: onAddCountdown) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .liquidGlass(in: Circle())
                        .overlay(Circle().strokeBorder(.white.opacity(0.15), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Geri sayım ekle")
            }
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
                AnimatedGIFView(resourceName: "BiriktirCatBreathing")
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

struct GoalHero: View {
    let goal: SavingsGoal
    var onDetail: () -> Void
    var onAdjust: (AdjustmentDirection) -> Void
    var onReports: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Spacer()
                Button(action: onDetail) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.secondary)
                        .frame(width: 34, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Hedef detayları")
            }
            ZStack {
                Circle()
                    .fill(AppColors.lavender.opacity(0.12))
                    .frame(width: 200, height: 200)
                    .blur(radius: 52)
                ProgressRing(progress: goal.progress, size: 200, lineWidth: 14)
                    .id(goal.id)
                VStack(spacing: 7) {
                    Image(systemName: goal.symbol)
                        .font(.system(size: 23, weight: .regular))
                        .foregroundStyle(AppColors.blue.opacity(0.9))
                        .padding(.bottom, 1)
                    Text(goal.name)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                    Text(Money.string(goal.currentAmount))
                        .font(.system(size: 31, weight: .semibold, design: .rounded))
                        .tracking(-1.0)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                        .contentTransition(.numericText())
                    Text("Hedef: \(Money.string(goal.targetAmount))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.secondary)
                    Text("%\(Money.percent(goal.progress * 100))")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
                        .contentTransition(.numericText())
                        .padding(.horizontal, 13)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.10), in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1))
                        .padding(.top, 2)
                }
                .frame(maxWidth: 190)
            }
            .frame(maxWidth: .infinity)
                .padding(.vertical, 0)
            HStack(spacing: 10) {
                ActionTile(title: "Ekle", symbol: "plus", tint: AppColors.mint) { onAdjust(.deposit) }
                ActionTile(title: "Çıkar", symbol: "minus", tint: .white.opacity(0.84)) { onAdjust(.withdraw) }
                ActionTile(title: "Rapor", symbol: "chart.bar.xaxis", tint: AppColors.lavender, action: onReports)
            }
        }
        .padding(17)
        .background {
            RoundedRectangle(cornerRadius: 31, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.12, green: 0.125, blue: 0.17).opacity(0.75), Color(red: 0.055, green: 0.06, blue: 0.08).opacity(0.74)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .liquidGlass(in: RoundedRectangle(cornerRadius: 31, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 31, style: .continuous).strokeBorder(LinearGradient(colors: [.white.opacity(0.21), .white.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .shadow(color: AppColors.lavender.opacity(0.08), radius: 26, y: 14)
    }
}

private struct CountdownCard: View {
    let countdown: CountdownItem
    var action: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let days = countdown.daysRemaining(asOf: context.date)
            let accessibilityDays = days.map { $0 == 0 ? "bugün" : "\($0) gün kaldı" } ?? "süre geçti"
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
                                    Text(days == 0 ? "BUGÜN" : "GÜN KALDI")
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

struct GoalCompletionToast: View {
    let goalName: String

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 22, style: .continuous)
        HStack(spacing: 10) {
            AnimatedGIFView(resourceName: "BiriktirCat")
                .frame(width: 42, height: 42)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Hedef tamamlandı")
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
            VStack(spacing: 7) {
                Image(systemName: symbol).font(.system(size: 18, weight: .medium)).foregroundStyle(tint)
                Text(title).font(.system(size: 12, weight: .medium)).foregroundStyle(.white.opacity(0.88))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 65)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(.white.opacity(0.12), lineWidth: 1))
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
