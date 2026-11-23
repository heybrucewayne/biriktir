import SwiftUI

struct ReportsView: View {
    @Environment(SavingsModel.self) private var model
    @State private var selectedRange = 0

    private var totals: [(date: Date, amount: Int)] { model.monthlyTotals(count: selectedRange == 0 ? 6 : 12) }
    private var totalThisMonth: Int { model.currentMonthDeposits }
    private var average: Int {
        let nonzero = totals.map(\.amount).filter { $0 > 0 }
        return nonzero.isEmpty ? 0 : nonzero.reduce(0, +) / nonzero.count
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                Text("Raporlar").font(.system(size: 30, weight: .bold, design: .rounded)).tracking(-0.7)
                    .appEntrance()

                GlassPanel(radius: 28) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Eyebrow(title: "Toplam birikim")
                                Text(Money.string(model.totalSaved))
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .tracking(-0.8).foregroundStyle(.white)
                                    .contentTransition(.numericText())
                            }
                            Spacer()
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 18, weight: .medium)).foregroundStyle(AppColors.mint)
                                .frame(width: 42, height: 42).background(AppColors.mint.opacity(0.10), in: Circle())
                        }
                        HStack(spacing: 5) {
                            rangeButton("6 Ay", index: 0)
                            rangeButton("12 Ay", index: 1)
                        }
                        .padding(4).background(.black.opacity(0.20), in: Capsule())
                        SavingsBarChart(values: totals)
                            .frame(height: 182)
                        HStack(spacing: 0) {
                            metric(title: "Bu ay", value: Money.string(totalThisMonth), tint: AppColors.mint)
                            Rectangle().fill(.white.opacity(0.10)).frame(width: 1, height: 34).padding(.horizontal, 14)
                            metric(title: "Aylık ortalama", value: Money.string(average), tint: AppColors.lavender)
                        }
                        .padding(.top, 2)
                    }
                }
                .appEntrance(delay: 0.04)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Hedef ilerlemesi").font(.system(size: 19, weight: .semibold, design: .rounded))
                        .appEntrance(delay: 0.1)
                    ForEach(Array(model.activeGoals.enumerated()), id: \.element.id) { index, goal in
                        GlassPanel(radius: 22) {
                            VStack(alignment: .leading, spacing: 13) {
                                HStack {
                                    Label(goal.name, systemImage: goal.symbol)
                                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                    Spacer()
                                    Text("%\(Int(goal.progress * 100))")
                                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(AppColors.lavender)
                                }
                                GeometryReader { proxy in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(.white.opacity(0.10))
                                        Capsule().fill(LinearGradient(colors: [AppColors.blue, AppColors.lavender], startPoint: .leading, endPoint: .trailing))
                                            .frame(width: proxy.size.width * goal.progress)
                                            .animation(.spring(response: 0.65, dampingFraction: 0.82), value: goal.progress)
                                    }
                                }
                                .frame(height: 6)
                                HStack {
                                    Text(Money.string(goal.currentAmount)).foregroundStyle(.white.opacity(0.86))
                                    Spacer()
                                    Text("\(Money.string(goal.targetAmount)) hedef").foregroundStyle(AppColors.secondary)
                                }
                                .font(.system(size: 11, weight: .medium))
                            }
                        }
                        .appEntrance(delay: 0.14 + Double(index) * 0.055)
                    }
                }
                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 28)
        }
    }

    private func rangeButton(_ title: String, index: Int) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.25)) { selectedRange = index } } label: {
            Text(LocalizedStringKey(title)).font(.system(size: 12, weight: .semibold))
                .foregroundStyle(selectedRange == index ? .white : AppColors.secondary)
                .frame(maxWidth: .infinity).padding(.vertical, 8)
                .background { if selectedRange == index { Capsule().fill(.white.opacity(0.13)) } }
        }
        .buttonStyle(AppPressButtonStyle())
    }

    private func metric(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(LocalizedStringKey(title)).font(.system(size: 11, weight: .medium)).foregroundStyle(AppColors.secondary)
            Text(value).font(.system(size: 15, weight: .semibold, design: .rounded)).foregroundStyle(tint).lineLimit(1).minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SavingsBarChart: View {
    let values: [(date: Date, amount: Int)]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var barsVisible = false

    var body: some View {
        GeometryReader { proxy in
            let count = max(values.count, 1)
            let spacing: CGFloat = count > 6 ? 4 : 10
            let itemWidth = max(0, (proxy.size.width - spacing * CGFloat(max(count - 1, 0))) / CGFloat(count))
            let maxValue = max(values.map(\.amount).max() ?? 0, 1)
            let barHeight = max(proxy.size.height - 28, 0)
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 7) {
                        ZStack(alignment: .bottom) {
                            Capsule().fill(.white.opacity(0.055))
                            if item.amount > 0 {
                                Capsule()
                                    .fill(LinearGradient(colors: [AppColors.lavender, AppColors.blue.opacity(0.72)], startPoint: .top, endPoint: .bottom))
                                    .frame(height: max(6, barHeight * CGFloat(item.amount) / CGFloat(maxValue)) * (reduceMotion || barsVisible ? 1 : 0))
                                    .overlay(alignment: .top) {
                                        if reduceMotion || barsVisible {
                                            Capsule().fill(.white.opacity(0.70)).frame(height: 2).padding(.horizontal, 3)
                                        }
                                    }
                                    .shadow(color: AppColors.lavender.opacity(item.amount == maxValue ? 0.42 : 0.20), radius: 8, y: 1)
                                    .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.78).delay(Double(index) * 0.025), value: barsVisible)
                            }
                        }
                        .frame(width: itemWidth, height: barHeight)
                        Text(month(item.date))
                            .font(.system(size: count > 6 ? 9 : 10, weight: .medium))
                            .foregroundStyle(AppColors.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .allowsTightening(true)
                            .frame(width: itemWidth)
                    }
                    .frame(width: itemWidth)
                }
            }
        }
        .accessibilityLabel("Aylık birikim grafiği")
        .task(id: values.map(\.amount)) {
            barsVisible = false
            guard !reduceMotion else {
                barsVisible = true
                return
            }
            do {
                try await Task.sleep(for: .milliseconds(60))
            } catch {
                return
            }
            withAnimation(.spring(response: 0.58, dampingFraction: 0.78)) {
                barsVisible = true
            }
        }
    }

    private func month(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = AppLanguage.current.locale
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter.string(from: date)
            .replacingOccurrences(of: ".", with: "")
            .capitalized(with: AppLanguage.current.locale)
    }
}
