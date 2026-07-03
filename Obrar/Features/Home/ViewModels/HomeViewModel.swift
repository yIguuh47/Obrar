import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    enum Period: String, CaseIterable, Identifiable {
        case day = "Dia"
        case week = "Semana"
        case month = "Mês"

        var id: String { rawValue }
    }

    @Published var selectedPeriod: Period = .day
    @Published private(set) var referenceDate: Date = Date()
    @Published private(set) var assignedWorkers: [String] = []

    private let calendar = Calendar.current
    private let headerFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    var title: String {
        "\(relativeDayPrefix), \(formattedReferenceDate)"
    }

    var workersSectionTitle: String {
        "Prestadores na Obra Hoje"
    }

    var isWorkersListEmpty: Bool {
        assignedWorkers.isEmpty
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
