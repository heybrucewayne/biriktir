import SwiftUI

struct SettingsView: View {
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.turkish.rawValue

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .center) {
                    Text("Ayarlar").font(.system(size: 30, weight: .bold, design: .rounded)).tracking(-0.7)
                        .appEntrance()
                    Spacer()
                    AnimatedGIFView(resourceName: "BiriktirCatAvatar")
                        .frame(width: 58, height: 58)
                        .accessibilityHidden(true)
                }

                GlassPanel(radius: 26) {
                    VStack(alignment: .leading, spacing: 17) {
                        Eyebrow(title: "Tercihler")
                        HStack(spacing: 13) {
                            SettingsIcon(symbol: "globe", tint: AppColors.blue)
                            Text("Dil").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                            Spacer(minLength: 4)
                            HStack(spacing: 3) {
                                languageButton("Türkçe", code: AppLanguage.turkish.rawValue)
                                languageButton("English", code: AppLanguage.english.rawValue)
                            }
                            .padding(3)
                            .background(.black.opacity(0.2), in: Capsule())
                        }
                        Rectangle().fill(.white.opacity(0.08)).frame(height: 1)
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
                .appEntrance(delay: 0.05)

                GlassPanel(radius: 26) {
                    VStack(alignment: .leading, spacing: 14) {
                        Eyebrow(title: "Hakkında")
                        HStack(spacing: 13) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(LinearGradient(colors: [AppColors.lavender.opacity(0.35), AppColors.blue.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                Image(systemName: "circle.hexagongrid.fill").font(.system(size: 20)).foregroundStyle(.white)
                            }.frame(width: 46, height: 46)
                            Text("Biriktir").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                            Spacer()
                            Text("1.0").font(.system(size: 11, weight: .medium, design: .rounded)).foregroundStyle(AppColors.secondary)
                        }
                        Rectangle().fill(.white.opacity(0.08)).frame(height: 1)
                        HStack(spacing: 9) {
                            Image(systemName: "lock.fill").font(.system(size: 11)).foregroundStyle(AppColors.mint)
                            Text("Bu cihazda saklanır.")
                                .font(.system(size: 11, weight: .medium)).foregroundStyle(AppColors.secondary)
                        }
                    }
                }
                .appEntrance(delay: 0.14)
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 28)
        }
    }

    private func languageButton(_ title: String, code: String) -> some View {
        let selected = languageCode == code
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { languageCode = code }
        } label: {
            Text(verbatim: title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(selected ? .white : AppColors.secondary)
                .frame(minWidth: 56)
                .padding(.horizontal, 7)
                .padding(.vertical, 8)
                .background {
                    if selected { Capsule().fill(.white.opacity(0.14)) }
                }
        }
        .buttonStyle(AppPressButtonStyle())
        .accessibilityAddTraits(selected ? .isSelected : [])
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
