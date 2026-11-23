import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentStep = 0

    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Hedefini\nbelirle.",
            symbol: "scope",
            mascotMessage: "Önce hedefini seç; tutarını ve tarihini belirle."
        ),
        OnboardingStep(
            title: "Birikimini\nkaydet.",
            symbol: "arrow.up.arrow.down",
            mascotMessage: "Ekle ve Çıkar’a dokun; her hareketin kayda geçsin."
        ),
        OnboardingStep(
            title: "İlerlemeni\ntakip et.",
            symbol: "chart.bar.xaxis",
            mascotMessage: "Raporlardan birikimini, geri sayımla önemli günlerini gör."
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.height < 720
            VStack(spacing: 0) {
                header
                    .padding(.bottom, 8)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: compact ? 12 : 18) {
                        mascot(height: compact ? 140 : 184)
                        stepContent
                            .id(currentStep)
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                    removal: .move(edge: .leading).combined(with: .opacity)))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, compact ? 6 : 12)
                    .padding(.bottom, 18)
                }
                .scrollBounceBehavior(.basedOnSize)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                footer
                    .padding(.top, 8)
            }
            .padding(.horizontal, 25)
            .padding(.top, 12)
            .padding(.bottom, max(geometry.safeAreaInsets.bottom == 0 ? 12 : 8, 8))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background { AppBackground() }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.lavender)
                Text("BİRİKTİR")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Button("Atla", action: onComplete)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.secondary)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(.white.opacity(0.055), in: Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.09), lineWidth: 1))
                .accessibilityHint("Tanıtımı geçip ana ekrana git")
        }
    }

    private func mascot(height: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(AppColors.lavender.opacity(0.15))
                .frame(width: height * 0.78, height: height * 0.78)
                .blur(radius: 48)
                .offset(y: 12)
            Circle()
                .strokeBorder(LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.03)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                .background(.white.opacity(0.025), in: Circle())
                .frame(width: height * 0.92, height: height * 0.92)
                .overlay {
                    AnimatedGIFView(resourceName: "BiriktirCat")
                        .frame(width: height * 1.08, height: height * 1.0)
                        .clipped()
                        .offset(y: height * 0.025)
                        .accessibilityLabel("Gözlüklü kedi maskotumuz")
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .accessibilityElement(children: .combine)
    }

    private var stepContent: some View {
        let step = steps[currentStep]
        return VStack(spacing: 16) {
            Text(LocalizedStringKey(step.title))
                .font(.system(size: 29, weight: .semibold, design: .rounded))
                .tracking(-0.55)
                .lineSpacing(1)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .top, spacing: 11) {
                Image(systemName: step.symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.blue)
                    .frame(width: 38, height: 38, alignment: .center)
                    .liquidGlass(in: Circle(), tint: AppColors.lavender.opacity(0.14))
                Text(LocalizedStringKey(step.mascotMessage))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(.white.opacity(0.12), lineWidth: 1))
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        VStack(spacing: 18) {
            HStack(spacing: 7) {
                ForEach(steps.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == currentStep ? AppColors.lavender : .white.opacity(0.20))
                        .frame(width: index == currentStep ? 22 : 6, height: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentStep)
                        .accessibilityHidden(true)
                }
            }
            Button(action: advance) {
                HStack(spacing: 9) {
                    Text(currentStep == steps.count - 1 ? "Biriktirmeye başla" : "Devam et")
                    Image(systemName: currentStep == steps.count - 1 ? "sparkle" : "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityHint(currentStep == steps.count - 1 ? "Ana ekrana geç" : "Sonraki tanıtım adımı")
        }
        .padding(.bottom, 8)
    }

    private func advance() {
        if currentStep == steps.count - 1 {
            onComplete()
        } else {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.88)) {
                currentStep += 1
            }
        }
    }
}

private struct OnboardingStep {
    let title: String
    let symbol: String
    let mascotMessage: String
}

