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

struct SavingsEntry: Codable, Identifiable {
    var id: UUID
    var goalID: UUID
    var amount: Int
    var date: Date

    var isDeposit: Bool { amount >= 0 }
}

@Observable
final class SavingsModel {
    private(set) var goals: [SavingsGoal]
    private(set) var entries: [SavingsEntry]

    private let goalsKey = "biriktir.goals.v1"
    private let entriesKey = "biriktir.entries.v1"

    init() {
        let loadedGoals: [SavingsGoal]
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let saved = try? JSONDecoder().decode([SavingsGoal].self, from: data) {
            loadedGoals = saved
        } else {
            loadedGoals = [.starter]
        }
        goals = loadedGoals

        let loadedEntries: [SavingsEntry]
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let saved = try? JSONDecoder().decode([SavingsEntry].self, from: data) {
            loadedEntries = saved
        } else {
            loadedEntries = Self.sampleEntries(for: loadedGoals.first?.id)
        }
        entries = loadedEntries
        persist()
    }

    var activeGoals: [SavingsGoal] { goals }

    var primaryGoal: SavingsGoal? { goals.first }

    var totalSaved: Int { goals.reduce(0) { $0 + $1.currentAmount } }

    var currentMonthDeposits: Int {
        entries.filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) && $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }

    func goal(id: UUID) -> SavingsGoal? { goals.first { $0.id == id } }

    func entries(for goalID: UUID) -> [SavingsEntry] {
        entries.filter { $0.goalID == goalID }.sorted { $0.date > $1.date }
    }

    func addGoal(name: String, target: Int, monthly: Int, date: Date, symbol: String) {
        let goal = SavingsGoal(id: UUID(), name: name, targetAmount: target, currentAmount: 0,
                               monthlyTarget: monthly, targetDate: date, symbol: symbol)
        goals.insert(goal, at: 0)
        persist()
    }

    func adjust(goalID: UUID, by amount: Int) {
        guard let index = goals.firstIndex(where: { $0.id == goalID }), amount != 0 else { return }
        let nextAmount = max(0, goals[index].currentAmount + amount)
        let actualChange = nextAmount - goals[index].currentAmount
        guard actualChange != 0 else { return }
        goals[index].currentAmount = nextAmount
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
