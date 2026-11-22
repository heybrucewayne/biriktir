import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Ayarlar").font(.system(size: 30, weight: .bold, design: .rounded)).tracking(-0.7)
                    Text("Biriktir deneyimini kişiselleştir.").font(.system(size: 14)).foregroundStyle(AppColors.secondary)
                }

                GlassPanel(radius: 26) {
                    VStack(alignment: .leading, spacing: 17) {
                        Eyebrow(title: "Tercihler")
                        HStack(spacing: 13) {
                            SettingsIcon(symbol: "moon.stars.fill", tint: AppColors.lavender)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Görünüm").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                Text("Siyah tema").font(.system(size: 11)).foregroundStyle(AppColors.secondary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(AppColors.lavender).font(.system(size: 17))
                        }
                        Rectangle().fill(.white.opacity(0.08)).frame(height: 1)
                        HStack(spacing: 13) {
                            SettingsIcon(symbol: "coloncurrencysign.circle.fill", tint: AppColors.mint)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Para birimi").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                                Text("Türk Lirası · TRY").font(.system(size: 11)).foregroundStyle(AppColors.secondary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(AppColors.mint).font(.system(size: 17))
                        }
                    }
                }

                GlassPanel(radius: 26) {
                    VStack(alignment: .leading, spacing: 14) {
                        Eyebrow(title: "Hakkında")
                        HStack(spacing: 13) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(LinearGradient(colors: [AppColors.lavender.opacity(0.35), AppColors.blue.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                Image(systemName: "circle.hexagongrid.fill").font(.system(size: 20)).foregroundStyle(.white)
                            }.frame(width: 46, height: 46)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Biriktir").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                                Text("Sade hedefler, güzel yarınlar.").font(.system(size: 11)).foregroundStyle(AppColors.secondary)
                            }
                            Spacer()
                            Text("1.0").font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(AppColors.secondary)
                        }
                        Rectangle().fill(.white.opacity(0.08)).frame(height: 1)
                        HStack(spacing: 9) {
                            Image(systemName: "lock.fill").font(.system(size: 11)).foregroundStyle(AppColors.mint)
                            Text("Birikim bilgilerin bu cihazda saklanır.")
                                .font(.system(size: 11, weight: .medium)).foregroundStyle(AppColors.secondary)
                        }
                    }
                }
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 28)
        }
    }
}

private struct SettingsIcon: View {
    let symbol: String
    let tint: Color
    var body: some View {
        Image(systemName: symbol).font(.system(size: 16, weight: .medium)).foregroundStyle(tint)
            .frame(width: 42, height: 42).background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
