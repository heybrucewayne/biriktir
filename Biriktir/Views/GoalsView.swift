import SwiftUI

struct GoalsView: View {
    @Environment(SavingsModel.self) private var model
    var onAdd: () -> Void
    var onDetail: (UUID) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hedeflerin")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tracking(-0.7)
                        Text("Hayallerini adım adım biriktir.")
                            .font(.system(size: 14)).foregroundStyle(AppColors.secondary)
                    }
                    Spacer()
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 46, height: 46)
                            .liquidGlass(in: Circle())
                            .overlay(Circle().strokeBorder(.white.opacity(0.16), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Yeni hedef ekle")
                }

                if model.activeGoals.isEmpty {
                    GlassPanel {
                        VStack(spacing: 12) {
                            AnimatedGIFView(resourceName: "BiriktirCatBreathing")
                                .frame(width: 132, height: 124)
                                .accessibilityHidden(true)
                            Text("Henüz bir hedefin yok").font(.system(size: 18, weight: .semibold, design: .rounded))
                            Text("Kendin için küçük bir hedef belirleyerek başlayabilirsin.")
                                .font(.system(size: 13)).foregroundStyle(AppColors.secondary).multilineTextAlignment(.center)
                            Button(action: onAdd) { Label("Hedef oluştur", systemImage: "plus") }.buttonStyle(PrimaryButtonStyle())
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 24)
                    }
                } else {
                    HStack(spacing: 10) {
                        SummaryPill(symbol: "scope", label: "Aktif hedef", value: "\(model.activeGoals.count)")
                        SummaryPill(symbol: "banknote", label: "Toplam birikim", value: Money.string(model.totalSaved))
                    }
                    VStack(spacing: 12) {
                        ForEach(model.activeGoals) { goal in
                            Button { onDetail(goal.id) } label: { GoalRow(goal: goal) }
                                .buttonStyle(.plain)
                            .contextMenu {
                                Button { onDetail(goal.id) } label: { Label("Hedef detayları", systemImage: "info.circle") }
                            }
                        }
                    }
                    GlassPanel(radius: 22) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.max.fill").foregroundStyle(AppColors.lavender).font(.system(size: 16))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("İstikrar kazandırır").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                Text("Düzenli ve küçük katkılar, hedefini daha ulaşılabilir kılar.")
                                    .font(.system(size: 12)).foregroundStyle(AppColors.secondary).fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
    }
}

private struct SummaryPill: View {
    let symbol: String
    let label: String
    let value: String

    var body: some View {
        GlassPanel(radius: 21) {
            VStack(alignment: .leading, spacing: 9) {
                Image(systemName: symbol).font(.system(size: 14, weight: .medium)).foregroundStyle(AppColors.lavender)
                Text(value).font(.system(size: 17, weight: .semibold, design: .rounded)).foregroundStyle(.white).lineLimit(1).minimumScaleFactor(0.7)
                Text(label).font(.system(size: 10, weight: .medium)).foregroundStyle(AppColors.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
