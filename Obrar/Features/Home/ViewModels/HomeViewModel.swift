import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    enum Period: String, CaseIterable, Identifiable {
        case day = "Dia"
        case week = "Semana"
        case month = "Mês"

        var id: String { rawValue }
    }

    @Published var selectedPeriod: Period = .day {
        didSet {
            syncWorkersForSelectedPeriod()
        }
    }
    @Published private(set) var referenceDate: Date = Date() {
        didSet {
            syncWorkersForSelectedPeriod()
        }
    }
    @Published private(set) var assignedWorkers: [String] = []

    private let calendar = Calendar.current
    private let prestadorStore: PrestadorStoreProtocol
    private let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    private let weekTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d MMM"
        return formatter
    }()
    private let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var title: String {
        switch selectedPeriod {
        case .day:
            return "\(relativeDayPrefix), \(formattedReferenceDate)"
        case .week:
            return "Semana: \(formattedWeekRange)"
        case .month:
            return monthTitleFormatter.string(from: referenceDate).capitalized
        }
    }

    var workersSectionTitle: String {
        switch selectedPeriod {
        case .day:
            return "Prestadores na Obra Hoje"
        case .week:
            return "Prestadores na Obra na Semana"
        case .month:
            return "Prestadores na Obra no Mês"
        }
    }

    var isWorkersListEmpty: Bool {
        assignedWorkers.isEmpty
    }

    init(prestadorStore: PrestadorStoreProtocol = UserDefaultsPrestadorStore()) {
        self.prestadorStore = prestadorStore
        syncWorkersForSelectedPeriod()
    }

    func refreshWorkers() {
        syncWorkersForSelectedPeriod()
    }

    func goToPrevious() {
        referenceDate = shiftedDate(step: -1)
    }

    func goToNext() {
        referenceDate = shiftedDate(step: 1)
    }

    func addRegisteredWorkers() {
        // Placeholder for future flow with coordinator/navigation.
    }

    private var formattedReferenceDate: String {
        headerFormatter.string(from: referenceDate).capitalized
    }

    private var relativeDayPrefix: String {
        if calendar.isDateInToday(referenceDate) {
            return "Hoje"
        }

        if calendar.isDateInYesterday(referenceDate) {
            return "Ontem"
        }

        if calendar.isDateInTomorrow(referenceDate) {
            return "Amanhã"
        }

        return selectedPeriod == .month ? "Mês" : "Dia"
    }

    private var formattedWeekRange: String {
        let interval = weekInterval(containing: referenceDate)
        let endDate = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.end
        let start = weekTitleFormatter.string(from: interval.start).capitalized
        let end = weekTitleFormatter.string(from: endDate).capitalized
        return "\(start) - \(end)"
    }

    private func syncWorkersForSelectedPeriod() {
        do {
            let prestadores = try prestadorStore.fetchAll()
            let intervalo = intervaloSelecionado()
            assignedWorkers = prestadores
                .filter { intervalo.contains($0.criadoEm) }
                .map(\.nome)
                .uniqued()
        } catch {
            assignedWorkers = []
        }
    }

    private func intervaloSelecionado() -> DateInterval {
        switch selectedPeriod {
        case .day:
            return dayInterval(containing: referenceDate)
        case .week:
            return weekInterval(containing: referenceDate)
        case .month:
            return monthInterval(containing: referenceDate)
        }
    }

    private func dayInterval(containing date: Date) -> DateInterval {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }

    private func weekInterval(containing date: Date) -> DateInterval {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        let start = calendar.date(from: components) ?? calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? date
        return DateInterval(start: start, end: end)
    }

    private func monthInterval(containing date: Date) -> DateInterval {
        let components = calendar.dateComponents([.year, .month], from: date)
        let start = calendar.date(from: components) ?? calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .month, value: 1, to: start) ?? date
        return DateInterval(start: start, end: end)
    }

    private func shiftedDate(step: Int) -> Date {
        switch selectedPeriod {
        case .day:
            return calendar.date(byAdding: .day, value: step, to: referenceDate) ?? referenceDate
        case .week:
            return calendar.date(byAdding: .day, value: step * 7, to: referenceDate) ?? referenceDate
        case .month:
            return calendar.date(byAdding: .month, value: step, to: referenceDate) ?? referenceDate
        }
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
