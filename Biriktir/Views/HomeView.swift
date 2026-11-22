import SwiftUI

struct HomeView: View {
    @Environment(SavingsModel.self) private var model
    var onAddGoal: () -> Void
    var onAdjust: (UUID, AdjustmentDirection) -> Void
    var onDetail: (UUID) -> Void
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
                goalSection
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
            VStack(alignment: .leading, spacing: 4) {
                Text("Biriktir")
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .tracking(-0.8)
                    .foregroundStyle(.white)
                Text("Hedefine doğru ilerliyorsun.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppColors.secondary)
            }
            Spacer()
            Button(action: onAddGoal) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .liquidGlass(in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.17), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Yeni hedef ekle")
        }
    }

    private var monthlyCard: some View {
        let months = model.monthlyTotals()
        return GlassPanel(radius: 26) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.mint)
                        Eyebrow(title: "Bu ay biriktirdin")
                    }
                    Text(Money.string(model.currentMonthDeposits))
                        .font(.system(size: 25, weight: .semibold, design: .rounded))
                        .tracking(-0.6)
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text("Güzel gidiyorsun")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.mint)
                }
                Spacer(minLength: 0)
                MiniSparkline(values: months.map(\.amount), color: AppColors.lavender)
                    .frame(width: 122, height: 54)
                    .accessibilityHidden(true)
            }
        }
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
            if model.activeGoals.count > 1 {
                ForEach(model.activeGoals.dropFirst()) { goal in
                    Button { onDetail(goal.id) } label: { GoalRow(goal: goal) }
                        .buttonStyle(.plain)
                }
            } else {
                HStack(spacing: 12) {
                    AnimatedGIFView(resourceName: "BiriktirCatBreathing")
                        .frame(width: 42, height: 46)
                        .accessibilityHidden(true)
                    Text("Bir sonraki hayalin için yeni bir hedef ekle.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.secondary)
                    Spacer(minLength: 0)
                    Button(action: onAddGoal) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColors.lavender)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Yeni hedef ekle")
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 14)
                .liquidGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(.white.opacity(0.09), lineWidth: 1))
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
                Text("Aklındaki hayal için bir hedef oluştur, ilerlemeni burada takip et.")
                    .font(.system(size: 14)).foregroundStyle(AppColors.secondary).multilineTextAlignment(.center)
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
                Eyebrow(title: "Öncelikli hedef")
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
                ProgressRing(progress: goal.progress, size: 200, lineWidth: 10)
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
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.92))
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
    var body: some View {
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
            Spacer()
            Text("%\(Int(goal.progress * 100))").font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.lavender)
            Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundStyle(.white.opacity(0.38))
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
