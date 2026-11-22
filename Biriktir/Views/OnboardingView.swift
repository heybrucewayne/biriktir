import SwiftUI
import ImageIO
import UIKit

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentStep = 0

    private let steps: [OnboardingStep] = [
        OnboardingStep(
            eyebrow: "İLK ADIM",
            title: "Hayalin için\nbir hedef belirle.",
            detail: "Ev, seyahat ya da aklındaki başka bir şey… Birikim hedefin sana özel.",
            symbol: "scope",
            feature: "Hedefini ve aylık planını oluştur"
        ),
        OnboardingStep(
            eyebrow: "HER ADIMI GÖR",
            title: "Ne kadar\nyaklaştığını izle.",
            detail: "Canlı ilerleme halkası ve aylık özet, birikiminin nasıl büyüdüğünü gösterir.",
            symbol: "chart.bar.xaxis",
            feature: "İlerlemeni ve raporlarını gör"
        ),
        OnboardingStep(
            eyebrow: "KONTROL SENDE",
            title: "Birikimini\nkolayca takip et.",
            detail: "Eklediğin veya ayırdığın tutarlar hareket geçmişinde düzenli şekilde saklanır.",
            symbol: "arrow.up.arrow.down",
            feature: "Tüm hareketlerin tek yerde"
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
                        mascot(height: compact ? 170 : 230)
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
        return VStack(spacing: 12) {
            Text(step.eyebrow)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(AppColors.lavender)
            Text(step.title)
                .font(.system(size: 29, weight: .semibold, design: .rounded))
                .tracking(-0.55)
                .lineSpacing(1)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text(step.detail)
                .font(.system(size: 14, weight: .regular))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 5)

            HStack(spacing: 11) {
                Image(systemName: step.symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.blue)
                    .frame(width: 38, height: 38)
                    .liquidGlass(in: Circle(), tint: AppColors.lavender.opacity(0.14))
                Text(step.feature)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(2)
                Spacer(minLength: 0)
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.mint)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .liquidGlass(in: RoundedRectangle(cornerRadius: 21, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(.white.opacity(0.12), lineWidth: 1))
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
    let eyebrow: String
    let title: String
    let detail: String
    let symbol: String
    let feature: String
}

private struct AnimatedGIFView: UIViewRepresentable {
    let resourceName: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        if let image = UIImage.animatedGIF(named: resourceName) {
            imageView.image = image
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
        }
        return imageView
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIImageView, context: Context) -> CGSize? {
        guard let width = proposal.width, let height = proposal.height else { return nil }
        return CGSize(width: width, height: height)
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        if imageView.image == nil, let image = UIImage.animatedGIF(named: resourceName) {
            imageView.image = image
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
        }
    }
}

private extension UIImage {
    static func animatedGIF(named name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }

        var frames: [UIImage] = []
        var totalDuration: TimeInterval = 0

        for index in 0..<CGImageSourceGetCount(source) {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) else { continue }
            frames.append(UIImage(cgImage: cgImage))

            let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any]
            let gifProperties = properties?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
            let unclamped = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber
            let clamped = gifProperties?[kCGImagePropertyGIFDelayTime] as? NSNumber
            totalDuration += max(unclamped?.doubleValue ?? clamped?.doubleValue ?? 0.1, 0.04)
        }

        guard !frames.isEmpty else { return nil }
        return UIImage.animatedImage(with: frames, duration: totalDuration)
    }
}
