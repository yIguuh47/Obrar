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
    @Published private(set) var availableWorkers: [Prestador] = []
    @Published var selectedWorkerIDs: Set<UUID> = []
    @Published var showWorkersSelectionSheet: Bool = false

    private let calendar = Calendar.current
    private let prestadorStore: PrestadorStoreProtocol
    private let registroDiarioStore: RegistroDiarioStoreProtocol
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

    var emptyStateTitle: String {
        switch selectedPeriod {
        case .day:
            return "Nenhum prestador alocado para hoje."
        case .week:
            return "Nenhum prestador alocado nesta semana."
        case .month:
            return "Nenhum prestador alocado neste mês."
        }
    }

    var emptyStateDescription: String {
        "Toque no botão abaixo para selecionar os prestadores cadastrados que trabalharam."
    }

    var workersSelectionTitle: String {
        "Selecionar Prestadores - \(headerFormatter.string(from: referenceDate).capitalized)"
    }

    init(
        prestadorStore: PrestadorStoreProtocol = UserDefaultsPrestadorStore(),
        registroDiarioStore: RegistroDiarioStoreProtocol = UserDefaultsRegistroDiarioStore()
    ) {
        self.prestadorStore = prestadorStore
        self.registroDiarioStore = registroDiarioStore
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
        do {
            availableWorkers = try prestadorStore.fetchAll().sorted { $0.nome < $1.nome }
            let currentRegistro = try registroDiarioStore.fetch(for: referenceDate)
            selectedWorkerIDs = Set(currentRegistro?.itens.map(\.prestadorId) ?? [])
            showWorkersSelectionSheet = true
        } catch {
            availableWorkers = []
            selectedWorkerIDs = []
            showWorkersSelectionSheet = true
        }
    }

    func toggleWorkerSelection(_ workerId: UUID) {
        if selectedWorkerIDs.contains(workerId) {
            selectedWorkerIDs.remove(workerId)
        } else {
            selectedWorkerIDs.insert(workerId)
        }
    }

    func isWorkerSelected(_ workerId: UUID) -> Bool {
        selectedWorkerIDs.contains(workerId)
    }

    func saveSelectedWorkersForReferenceDate() {
        let selectedWorkers = availableWorkers.filter { selectedWorkerIDs.contains($0.id) }
        let items = selectedWorkers.map { worker in
            RegistroDiario.Item(
                prestadorId: worker.id,
                prestadorNome: worker.nome,
                obraNome: workName(from: worker.localServico)
            )
        }

        do {
            try registroDiarioStore.upsert(for: referenceDate, itens: items)
            showWorkersSelectionSheet = false
            syncWorkersForSelectedPeriod()
        } catch {
            showWorkersSelectionSheet = false
        }
    }

    func workName(from localServico: Prestador.LocalServico) -> String {
        switch localServico {
        case .obra(let obra):
            return obra
        case .localizacao(let local):
            return local
        }
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
            let registros = try registroDiarioStore.fetchAll()
            let intervalo = intervaloSelecionado()
            assignedWorkers = registros
                .filter { intervalo.contains($0.data) }
                .flatMap(\.itens)
                .map(\.prestadorNome)
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
