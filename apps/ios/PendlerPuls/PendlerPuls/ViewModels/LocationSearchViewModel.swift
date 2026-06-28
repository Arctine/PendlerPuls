import Combine
import Foundation

@MainActor
final class LocationSearchViewModel: ObservableObject {
    enum Field {
        case from
        case to
    }

    @Published var fromQuery = ""
    @Published var toQuery = ""
    @Published var fromResults: [LocationReference] = []
    @Published var toResults: [LocationReference] = []
    @Published var selectedFrom: LocationReference?
    @Published var selectedTo: LocationReference?
    @Published var routeOptions: [TripPreview] = []
    @Published var selectedRouteOptionID: TripPreview.ID?
    @Published var journeyName = ""
    @Published var isSearchingFrom = false
    @Published var isSearchingTo = false
    @Published var isPreviewing = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let transitService: TransitService
    private let journeyService: JourneyService

    init(transitService: TransitService, journeyService: JourneyService) {
        self.transitService = transitService
        self.journeyService = journeyService
    }

    var canPreview: Bool {
        selectedFrom != nil && selectedTo != nil && !isPreviewing
    }

    var selectedPreview: TripPreview? {
        if let selectedRouteOptionID,
           let option = routeOptions.first(where: { $0.id == selectedRouteOptionID }) {
            return option
        }

        return routeOptions.first
    }

    func clearSelectionIfNeeded(for field: Field, query: String) {
        switch field {
        case .from:
            if selectedFrom?.label != query {
                selectedFrom = nil
                clearRouteOptions()
            }
        case .to:
            if selectedTo?.label != query {
                selectedTo = nil
                clearRouteOptions()
            }
        }
    }

    func search(_ field: Field) async {
        let query = (field == .from ? fromQuery : toQuery)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard query.count >= 2 else {
            setResults([], for: field)
            return
        }

        setSearching(true, for: field)
        defer { setSearching(false, for: field) }

        do {
            let results = try await transitService.searchLocations(query: query)
            setResults(results, for: field)
            errorMessage = nil
        } catch {
            if (error as? URLError)?.code == .cancelled {
                return
            }

            setResults([], for: field)
            errorMessage = userFacingMessage(for: error)
        }
    }

    func select(_ location: LocationReference, for field: Field) {
        switch field {
        case .from:
            selectedFrom = location
            fromQuery = location.label
            fromResults = []
        case .to:
            selectedTo = location
            toQuery = location.label
            toResults = []
        }

        clearRouteOptions()
        successMessage = nil
        updateDefaultJourneyName()
    }

    func previewJourney() async {
        guard let selectedFrom, let selectedTo else {
            errorMessage = "Choose both locations from search."
            return
        }

        isPreviewing = true
        defer { isPreviewing = false }

        do {
            routeOptions = try await transitService.routeOptions(from: selectedFrom, to: selectedTo)
            selectedRouteOptionID = routeOptions.first?.id
            errorMessage = nil
            successMessage = nil
            updateDefaultJourneyName()
        } catch {
            clearRouteOptions()
            errorMessage = userFacingMessage(for: error)
        }
    }

    func saveJourney() async {
        guard selectedPreview != nil, let selectedFrom, let selectedTo else {
            errorMessage = "Preview the journey before saving it."
            return
        }

        let trimmedName = journeyName.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmedName.isEmpty ? defaultJourneyName : trimmedName

        isSaving = true
        defer { isSaving = false }

        do {
            _ = try await journeyService.saveJourney(
                name: name,
                from: selectedFrom,
                to: selectedTo
            )
            successMessage = "Journey saved."
            errorMessage = nil
        } catch {
            successMessage = nil
            errorMessage = userFacingMessage(for: error)
        }
    }

    private var defaultJourneyName: String {
        guard let selectedFrom, let selectedTo else { return "" }
        return "\(selectedFrom.name) to \(selectedTo.name)"
    }

    private func updateDefaultJourneyName() {
        let generated = defaultJourneyName
        if !generated.isEmpty {
            journeyName = generated
        }
    }

    private func clearRouteOptions() {
        routeOptions = []
        selectedRouteOptionID = nil
    }

    private func setResults(_ results: [LocationReference], for field: Field) {
        switch field {
        case .from:
            fromResults = results
        case .to:
            toResults = results
        }
    }

    private func setSearching(_ value: Bool, for field: Field) {
        switch field {
        case .from:
            isSearchingFrom = value
        case .to:
            isSearchingTo = value
        }
    }
}
