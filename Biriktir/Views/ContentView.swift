import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home, goals, reports, settings
    var id: String { rawValue }
    var title: String {
        switch self {
        case .home: "Ana Sayfa"
        case .goals: "Hedefler"
        case .reports: "Raporlar"
        case .settings: "Ayarlar"
        }
    }
    var symbol: String {
        switch self {
        case .home: "house"
        case .goals: "scope"
        case .reports: "chart.bar"
        case .settings: "slider.horizontal.3"
        }
    }
}

enum AdjustmentDirection { case deposit, withdraw }

enum SheetRoute: Identifiable {
    case addGoal
    case adjust(goalID: UUID, direction: AdjustmentDirection)
    case detail(goalID: UUID)

    var id: String {
        switch self {
        case .addGoal: "add-goal"
        case .adjust(let id, let direction): "adjust-\(id)-\(direction)"
        case .detail(let id): "detail-\(id)"
        }
    }
}

struct ContentView: View {
    @AppStorage("biriktir.onboarding.completed.v1") private var hasCompletedOnboarding = false
    @State private var selectedTab: AppTab = .home
    @State private var sheetRoute: SheetRoute?

    var body: some View {
        ZStack {
            AppBackground()
            if hasCompletedOnboarding {
                selectedScreen
                    .transition(.opacity)
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasCompletedOnboarding = true
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasCompletedOnboarding)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if hasCompletedOnboarding {
                BottomBar(selection: $selectedTab)
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
            }
        }
        .sheet(item: $sheetRoute) { route in
            switch route {
            case .addGoal:
                AddGoalSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            case .adjust(let id, let direction):
                AdjustmentSheet(goalID: id, direction: direction)
                    .presentationDetents([.height(470)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            case .detail(let id):
                GoalDetailSheet(goalID: id, onAdjust: { direction in
                    sheetRoute = .adjust(goalID: id, direction: direction)
                })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
            }
        }
    }

    private func select(_ tab: AppTab) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) { selectedTab = tab }
    }

    @ViewBuilder
    private var selectedScreen: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeView(onAddGoal: { sheetRoute = .addGoal }, onAdjust: { id, direction in sheetRoute = .adjust(goalID: id, direction: direction) }, onDetail: { id in sheetRoute = .detail(goalID: id) }, onGoals: { select(.goals) }, onReports: { select(.reports) })
            case .goals:
                GoalsView(onAdd: { sheetRoute = .addGoal }, onDetail: { id in sheetRoute = .detail(goalID: id) })
            case .reports:
                ReportsView()
            case .settings:
                SettingsView()
            }
        }
        .id(selectedTab)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

struct BottomBar: View {
    @Binding var selection: AppTab

    @ViewBuilder
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 10) {
                glassBar
            }
        } else {
            glassBar
        }
    }

    private var glassBar: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.74)) { selection = tab }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 17, weight: .regular))
                            .symbolRenderingMode(.hierarchical)
                            .frame(height: 21)
                        Text(tab.title)
                            .font(.system(size: 9, weight: selection == tab ? .medium : .regular))
                            .lineLimit(1)
                    }
                    .foregroundStyle(selection == tab ? .white : AppColors.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background {
                        if selection == tab {
                            Capsule()
                                .liquidGlass(in: Capsule(), tint: .white.opacity(0.16), interactive: true)
                                .overlay(Capsule().strokeBorder(.white.opacity(0.27), lineWidth: 0.8))
                                .shadow(color: AppColors.lavender.opacity(0.12), radius: 14)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(7)
        .clearLiquidGlass(in: Capsule())
        .overlay {
            Capsule().strokeBorder(
                LinearGradient(colors: [.white.opacity(0.48), .white.opacity(0.18), .white.opacity(0.08)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: 1
            )
        }
        .overlay(alignment: .top) {
            Capsule()
                .stroke(.white.opacity(0.48), lineWidth: 0.7)
                .padding(.horizontal, 3)
                .padding(.top, 1)
                .mask(LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom))
                .allowsHitTesting(false)
        }
        .shadow(color: .black.opacity(0.4), radius: 24, y: 10)
    }
}
