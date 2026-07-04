import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    struct WorkersDayGroup: Identifiable {
        let date: Date
        let label: String
        let workers: [String]

        var id: TimeInterval { date.timeIntervalSince1970 }
    }

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
    @Published private(set) var groupedWorkersByDay: [WorkersDayGroup] = []
    @Published private(set) var availableWorkers: [Prestador] = []
    @Published var selectedWorkerIDs: Set<UUID> = []
    @Published var showWorkersSelectionSheet: Bool = false
    @Published private(set) var workersSheetDate: Date = Date()
    var onRequestOpenCadastro: (() -> Void)?

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
    private let dayGroupFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEE, d MMM"
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
        switch selectedPeriod {
        case .day:
            return assignedWorkers.isEmpty
        case .week, .month:
            return groupedWorkersByDay.isEmpty
        }
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
        "Selecionar Prestadores - \(headerFormatter.string(from: workersSheetDate).capitalized)"
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
        openWorkersEditor(for: referenceDate)
    }

    func openWorkersEditor(for date: Date) {
        workersSheetDate = calendar.startOfDay(for: date)

        do {
            availableWorkers = try prestadorStore.fetchAll()
                .sorted { $0.nome < $1.nome }
                .uniqued(by: { $0.nome.lowercased() })
            let currentRegistro = try registroDiarioStore.fetch(for: workersSheetDate)
            selectedWorkerIDs = resolveSelectedWorkerIDs(from: currentRegistro)
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
            try registroDiarioStore.upsert(for: workersSheetDate, itens: items)
            showWorkersSelectionSheet = false
            syncWorkersForSelectedPeriod()
        } catch {
            showWorkersSelectionSheet = false
        }
    }

    func openCadastroFromWorkersSheet() {
        showWorkersSelectionSheet = false
        onRequestOpenCadastro?()
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
            let intervaloVisivel = visibleInterval(from: intervalo)
            let registrosNoIntervalo = registros
                .filter { intervaloVisivel.contains($0.data) }
                .sorted { $0.data > $1.data }

            let registrosPorDia = Dictionary(
                uniqueKeysWithValues: registrosNoIntervalo.map { registro in
                    (calendar.startOfDay(for: registro.data), registro)
                }
            )

            let diasDoPeriodo = daysIn(intervalo: intervaloVisivel).sorted(by: >)

            groupedWorkersByDay = diasDoPeriodo.map { dia in
                let registro = registrosPorDia[dia]
                let workers = registro?.itens.map(\.prestadorNome).uniqued() ?? []
                return WorkersDayGroup(
                    date: dia,
                    label: dayGroupFormatter.string(from: dia).capitalized,
                    workers: workers
                )
            }

            assignedWorkers = registrosNoIntervalo
                .flatMap(\.itens)
                .map(\.prestadorNome)
                .uniqued()
        } catch {
            assignedWorkers = []
            groupedWorkersByDay = []
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

    private func visibleInterval(from intervalo: DateInterval) -> DateInterval {
        guard selectedPeriod != .day else {
            return intervalo
        }

        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) ?? intervalo.end
        let visibleEnd = min(intervalo.end, startOfTomorrow)
        return DateInterval(start: intervalo.start, end: max(intervalo.start, visibleEnd))
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

    private func daysIn(intervalo: DateInterval) -> [Date] {
        var days: [Date] = []
        var current = calendar.startOfDay(for: intervalo.start)
        let end = intervalo.end

        while current < end {
            days.append(current)
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = next
        }

        return days
    }

    private func resolveSelectedWorkerIDs(from registro: RegistroDiario?) -> Set<UUID> {
        guard let registro else {
            return []
        }

        let availableIDs = Set(availableWorkers.map(\.id))
        var selected: Set<UUID> = []
        var unresolvedNames: [String] = []

        for item in registro.itens {
            if availableIDs.contains(item.prestadorId) {
                selected.insert(item.prestadorId)
            } else {
                unresolvedNames.append(item.prestadorNome)
            }
        }

        if !unresolvedNames.isEmpty {
            let idsByName = Dictionary(
                availableWorkers.map { ($0.nome.lowercased(), $0.id) },
                uniquingKeysWith: { first, _ in first }
            )

            for name in unresolvedNames {
                if let id = idsByName[name.lowercased()] {
                    selected.insert(id)
                }
            }
        }

        return selected
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

private extension Array {
    func uniqued<Key: Hashable>(by keySelector: (Element) -> Key) -> [Element] {
        var seen = Set<Key>()
        return filter { seen.insert(keySelector($0)).inserted }
    }
}
