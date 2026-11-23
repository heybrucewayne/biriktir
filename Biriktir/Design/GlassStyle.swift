import SwiftUI

enum AppLanguage: String {
    case turkish = "tr"
    case english = "en"

    static let storageKey = "biriktir.language.v1"

    var locale: Locale {
        switch self {
        case .turkish: Locale(identifier: "tr_TR")
        case .english: Locale(identifier: "en_US")
        }
    }

    static var current: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "tr") ?? .turkish
    }

    static func dateString(_ date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.locale = current.locale
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: date)
    }
}

enum AppColors {
    static let background = Color(red: 0.025, green: 0.03, blue: 0.045)
    static let lavender = Color(red: 0.67, green: 0.57, blue: 1.0)
    static let blue = Color(red: 0.53, green: 0.70, blue: 1.0)
    static let mint = Color(red: 0.43, green: 0.88, blue: 0.70)
    static let glassTint = Color(red: 0.075, green: 0.08, blue: 0.115)
    static let secondary = Color.white.opacity(0.58)
}

extension View {
    @ViewBuilder
    func liquidGlass<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(AppColors.glassTint), in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }

    @ViewBuilder
    func liquidGlass<S: Shape>(in shape: S, tint: Color, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.tint(tint).interactive(), in: shape)
            } else {
                self.glassEffect(.regular.tint(tint), in: shape)
            }
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()
            RadialGradient(colors: [AppColors.lavender.opacity(0.13), .clear], center: .topTrailing,
                           startRadius: 0, endRadius: 360)
                .frame(height: 470)
                .ignoresSafeArea()
            LinearGradient(colors: [.clear, AppColors.background.opacity(0.35), AppColors.background],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }
}

struct GlassPanel<Content: View>: View {
    var radius: CGFloat = 28
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(20)
            .liquidGlass(in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(LinearGradient(colors: [.white.opacity(0.20), .white.opacity(0.045)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                .allowsHitTesting(false)
            }
            .shadow(color: .black.opacity(0.25), radius: 22, y: 12)
    }
}

struct Eyebrow: View {
    let title: String
    var body: some View {
        Text(LocalizedStringKey(title))
            .textCase(.uppercase)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .tracking(1.15)
            .foregroundStyle(AppColors.secondary)
    }
}

struct ProgressRing: View {
    let progress: Double
    var size: CGFloat = 246
    var lineWidth: CGFloat = 12
    @State private var shownProgress = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.07), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: shownProgress)
                .stroke(AngularGradient(colors: [AppColors.blue.opacity(0.85), AppColors.lavender, .white, AppColors.lavender],
                                        center: .center, startAngle: .degrees(0), endAngle: .degrees(300)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: AppColors.lavender.opacity(0.72), radius: 11)
            Circle()
                .trim(from: 0, to: shownProgress)
                .stroke(AppColors.lavender.opacity(0.24), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .padding(-8)
                .rotationEffect(.degrees(-90))
                .blur(radius: 5)
        }
        .frame(width: size, height: size)
        .onAppear { withAnimation(.spring(response: 1.25, dampingFraction: 0.8).delay(0.18)) { shownProgress = progress } }
        .onChange(of: progress) { _, newValue in withAnimation(.spring(response: 0.9, dampingFraction: 0.8)) { shownProgress = newValue } }
        .accessibilityLabel("Hedefin yüzde \(Int(progress * 100)) tamamlandı")
    }
}

struct MiniSparkline: View {
    var values: [Int]
    var color: Color = AppColors.lavender

    var body: some View {
        GeometryReader { proxy in
            let points = normalizedPoints(in: proxy.size)
            ZStack {
                if points.count > 1 {
                    Path { path in
                        path.move(to: points[0])
                        for point in points.dropFirst() { path.addLine(to: point) }
                    }
                    .stroke(color.opacity(0.16), style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .blur(radius: 8)
                    Path { path in
                        path.move(to: points[0])
                        for point in points.dropFirst() { path.addLine(to: point) }
                    }
                    .stroke(LinearGradient(colors: [AppColors.blue, color, .white.opacity(0.88)], startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                    if let last = points.last {
                        Circle().fill(.white).frame(width: 6, height: 6).shadow(color: color, radius: 7).position(last)
                    }
                }
            }
        }
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard values.count > 1 else { return [] }
        let minValue = Double(values.min() ?? 0)
        let maxValue = Double(values.max() ?? 1)
        let spread = max(maxValue - minValue, 1)
        return values.enumerated().map { index, value in
            let x = CGFloat(index) / CGFloat(values.count - 1) * size.width
            let y = size.height - (CGFloat(Double(value) - minValue) / CGFloat(spread) * (size.height * 0.72) + size.height * 0.14)
            return CGPoint(x: x, y: y)
        }
    }
}
