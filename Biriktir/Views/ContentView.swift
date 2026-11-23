import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home, goals, reports, settings
    var id: String { rawValue }
    var title: LocalizedStringKey {
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
        case .goals: "checklist"
        case .reports: "chart.bar"
        case .settings: "slider.horizontal.3"
        }
    }
}

enum AdjustmentDirection { case deposit, withdraw }

enum SheetRoute: Identifiable {
    case addGoal
    case addCountdown
    case adjust(goalID: UUID, direction: AdjustmentDirection)
    case detail(goalID: UUID)
    case countdownDetail(id: UUID)

    var id: String {
        switch self {
        case .addGoal: "add-goal"
        case .addCountdown: "add-countdown"
        case .adjust(let id, let direction): "adjust-\(id)-\(direction)"
        case .detail(let id): "detail-\(id)"
        case .countdownDetail(let id): "countdown-detail-\(id)"
        }
    }
}

struct ContentView: View {
    @Environment(SavingsModel.self) private var model
    @AppStorage("biriktir.onboarding.completed.v1") private var hasCompletedOnboarding = false
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.turkish.rawValue
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
        .overlay(alignment: .top) {
            if let event = model.celebrationEvent {
                GoalCelebrationToast(milestone: event.milestone, goalName: event.goalName)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .task(id: event.id) {
                        do {
                            try await Task.sleep(for: .seconds(3))
                        } catch {
                            return
                        }
                        withAnimation(.easeOut(duration: 0.3)) {
                            model.dismissCelebrationEvent(id: event.id)
                        }
                    }
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: model.celebrationEvent?.id)
        .sheet(item: $sheetRoute) { route in
            switch route {
            case .addGoal:
                AddGoalSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            case .addCountdown:
                AddCountdownSheet()
                    .presentationDetents([.height(440)])
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
            case .countdownDetail(let id):
                CountdownDetailSheet(countdownID: id)
                    .presentationDetents([.height(460)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
        }
        .environment(\.locale, AppLanguage(rawValue: languageCode)?.locale ?? AppLanguage.turkish.locale)
    }

    private func select(_ tab: AppTab) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) { selectedTab = tab }
    }

    @ViewBuilder
    private var selectedScreen: some View {
        TabView(selection: $selectedTab) {
            HomeView(onAddGoal: { sheetRoute = .addGoal }, onAddCountdown: { sheetRoute = .addCountdown }, onAdjust: { id, direction in sheetRoute = .adjust(goalID: id, direction: direction) }, onDetail: { id in sheetRoute = .detail(goalID: id) }, onCountdownDetail: { id in sheetRoute = .countdownDetail(id: id) })
                .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.symbol) }
                .tag(AppTab.home)
            GoalsView(onAdd: { sheetRoute = .addGoal }, onDetail: { id in sheetRoute = .detail(goalID: id) })
                .tabItem { Label(AppTab.goals.title, systemImage: AppTab.goals.symbol) }
                .tag(AppTab.goals)
            ReportsView()
                .tabItem { Label(AppTab.reports.title, systemImage: AppTab.reports.symbol) }
                .tag(AppTab.reports)
            SettingsView()
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.symbol) }
                .tag(AppTab.settings)
        }
        .tint(.white)
    }
}
