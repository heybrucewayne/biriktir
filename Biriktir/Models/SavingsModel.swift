import Foundation
import Observation

struct SavingsGoal: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var targetAmount: Int
    var currentAmount: Int
    var monthlyTarget: Int
    var targetDate: Date
    var symbol: String

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(currentAmount) / Double(targetAmount), 1)
    }

    static let starter = SavingsGoal(
        id: UUID(),
        name: "Ev Alımı",
        targetAmount: 2_000_000,
        currentAmount: 1_250_000,
        monthlyTarget: 50_000,
        targetDate: Calendar.current.date(from: DateComponents(year: 2027, month: 12, day: 1)) ?? .now,
        symbol: "house.fill"
    )
}

struct CountdownItem: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var targetDate: Date

    func daysRemaining(asOf date: Date = .now) -> Int? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        let deadline = calendar.startOfDay(for: targetDate)
        guard deadline >= today else { return nil }
        return calendar.dateComponents([.day], from: today, to: deadline).day ?? 0
    }
}

struct SavingsEntry: Codable, Identifiable {
    var id: UUID
    var goalID: UUID
    var amount: Int
    var date: Date

    var isDeposit: Bool { amount >= 0 }
}

struct GoalCompletionEvent: Identifiable, Equatable {
    let id = UUID()
    let goalName: String
}

@Observable
final class SavingsModel {
    private(set) var goals: [SavingsGoal]
    private(set) var entries: [SavingsEntry]
    private(set) var countdowns: [CountdownItem]
    private(set) var selectedPrimaryGoalID: UUID?
    private(set) var completionEvent: GoalCompletionEvent?

    private let goalsKey = "biriktir.goals.v1"
    private let entriesKey = "biriktir.entries.v1"
    private let countdownsKey = "biriktir.countdowns.v1"
    private let primaryGoalKey = "biriktir.primaryGoal.v1"

    init() {
        let loadedGoals: [SavingsGoal]
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let saved = try? JSONDecoder().decode([SavingsGoal].self, from: data) {
            loadedGoals = saved
        } else {
            loadedGoals = [.starter]
        }
        goals = loadedGoals
        if let storedID = UserDefaults.standard.string(forKey: primaryGoalKey),
           let id = UUID(uuidString: storedID), loadedGoals.contains(where: { $0.id == id }) {
            selectedPrimaryGoalID = id
        } else {
            selectedPrimaryGoalID = nil
        }

        let loadedEntries: [SavingsEntry]
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let saved = try? JSONDecoder().decode([SavingsEntry].self, from: data) {
            loadedEntries = saved
        } else {
            loadedEntries = Self.sampleEntries(for: loadedGoals.first?.id)
        }
        entries = loadedEntries

        if let data = UserDefaults.standard.data(forKey: countdownsKey),
           let saved = try? JSONDecoder().decode([CountdownItem].self, from: data) {
            countdowns = saved
        } else {
            countdowns = []
        }
        persist()
    }

    var activeGoals: [SavingsGoal] { goals }

    var primaryGoal: SavingsGoal? {
        if let selectedPrimaryGoalID,
           let selected = goals.first(where: { $0.id == selectedPrimaryGoalID }) {
            return selected
        }
        return goals.first
    }

    var totalSaved: Int { goals.reduce(0) { $0 + $1.currentAmount } }

    var currentMonthDeposits: Int {
        entries.filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) && $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }

    func goal(id: UUID) -> SavingsGoal? { goals.first { $0.id == id } }

    func setPrimaryGoal(_ id: UUID) {
        guard goals.contains(where: { $0.id == id }) else { return }
        selectedPrimaryGoalID = id
        UserDefaults.standard.set(id.uuidString, forKey: primaryGoalKey)
    }

    func dismissCompletionEvent(id: UUID) {
        guard completionEvent?.id == id else { return }
        completionEvent = nil
    }

    func entries(for goalID: UUID) -> [SavingsEntry] {
        entries.filter { $0.goalID == goalID }.sorted { $0.date > $1.date }
    }

    func addGoal(name: String, target: Int, monthly: Int, date: Date, symbol: String) {
        let goal = SavingsGoal(id: UUID(), name: name, targetAmount: target, currentAmount: 0,
                               monthlyTarget: monthly, targetDate: date, symbol: symbol)
        goals.insert(goal, at: 0)
        persist()
    }

    func addCountdown(name: String, date: Date) {
        let countdown = CountdownItem(id: UUID(), name: name, targetDate: date)
        countdowns.append(countdown)
        persist()
    }

    func countdown(id: UUID) -> CountdownItem? { countdowns.first { $0.id == id } }

    func deleteCountdown(id: UUID) {
        countdowns.removeAll { $0.id == id }
        persist()
    }

    var orderedCountdowns: [CountdownItem] {
        countdowns.sorted { first, second in
            let firstDays = first.daysRemaining()
            let secondDays = second.daysRemaining()
            if firstDays == nil, secondDays != nil { return false }
            if firstDays != nil, secondDays == nil { return true }
            if firstDays == nil, secondDays == nil { return first.targetDate > second.targetDate }
            return first.targetDate < second.targetDate
        }
    }

    func adjust(goalID: UUID, by amount: Int) {
        guard let index = goals.firstIndex(where: { $0.id == goalID }), amount != 0 else { return }
        let previousAmount = goals[index].currentAmount
        let nextAmount = max(0, goals[index].currentAmount + amount)
        let actualChange = nextAmount - goals[index].currentAmount
        guard actualChange != 0 else { return }
        goals[index].currentAmount = nextAmount
        if previousAmount < goals[index].targetAmount, nextAmount >= goals[index].targetAmount {
            completionEvent = GoalCompletionEvent(goalName: goals[index].name)
        }
        entries.append(SavingsEntry(id: UUID(), goalID: goalID, amount: actualChange, date: .now))
        persist()
    }

    func monthlyTotals(count: Int = 6) -> [(date: Date, amount: Int)] {
        let calendar = Calendar.current
        let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) ?? .now
        return (0..<count).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: -offset, to: startOfThisMonth) else { return nil }
            let amount = entries.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .month) }
                .reduce(0) { $0 + $1.amount }
            return (date, max(0, amount))
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(goals) { UserDefaults.standard.set(data, forKey: goalsKey) }
        if let data = try? JSONEncoder().encode(entries) { UserDefaults.standard.set(data, forKey: entriesKey) }
        if let data = try? JSONEncoder().encode(countdowns) { UserDefaults.standard.set(data, forKey: countdownsKey) }
    }

    private static func sampleEntries(for goalID: UUID?) -> [SavingsEntry] {
        guard let goalID else { return [] }
        let calendar = Calendar.current
        let amounts = [36_000, 42_000, 45_000, 47_000, 46_000, 50_000]
        return amounts.enumerated().compactMap { index, amount in
            guard let date = calendar.date(byAdding: .month, value: index - (amounts.count - 1), to: .now) else { return nil }
            return SavingsEntry(id: UUID(), goalID: goalID, amount: amount, date: date)
        }
    }
}

enum Money {
    static func string(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.numberStyle = .currency
        formatter.currencyCode = "TRY"
        formatter.currencySymbol = "₺"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₺\(amount)"
    }

    static func input(_ text: String) -> Int? {
        let digits = text.filter(\.isNumber)
        guard !digits.isEmpty else { return nil }
        return Int(digits)
    }

    static func percent(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

enum GoalSymbols {
    static let choices: [(String, String)] = [
        ("house.fill", "Ev"), ("car.fill", "Araba"), ("airplane", "Seyahat"),
        ("sparkles", "Kişisel"), ("graduationcap.fill", "Eğitim"), ("leaf.fill", "Diğer")
    ]
}
