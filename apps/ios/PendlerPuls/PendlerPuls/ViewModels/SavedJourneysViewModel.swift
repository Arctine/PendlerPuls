import Combine
import Foundation

@MainActor
final class SavedJourneysViewModel: ObservableObject {
    @Published var journeys: [SavedJourney] = []
    @Published var isLoading = false
    @Published var refreshingJourneyIDs = Set<UUID>()
    @Published var deletingJourneyIDs = Set<UUID>()
    @Published var errorMessage: String?

    private let journeyService: JourneyService
    private var hasLoaded = false

    init(journeyService: JourneyService) {
        self.journeyService = journeyService
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await load()
    }

    func load() async {
        hasLoaded = true
        isLoading = true
        defer { isLoading = false }

        do {
            journeys = try await journeyService.savedJourneys()
            sortJourneys()
            errorMessage = nil
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    func refresh(_ journey: SavedJourney) async {
        refreshingJourneyIDs.insert(journey.id)
        defer { refreshingJourneyIDs.remove(journey.id) }

        do {
            let updated = try await journeyService.refreshJourney(id: journey.id)
            replace(updated)
            errorMessage = nil
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    func delete(_ journey: SavedJourney) async {
        deletingJourneyIDs.insert(journey.id)
        defer { deletingJourneyIDs.remove(journey.id) }

        do {
            try await journeyService.deleteJourney(id: journey.id)
            journeys.removeAll { $0.id == journey.id }
            errorMessage = nil
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    private func replace(_ journey: SavedJourney) {
        if let index = journeys.firstIndex(where: { $0.id == journey.id }) {
            journeys[index] = journey
        } else {
            journeys.insert(journey, at: 0)
        }

        sortJourneys()
    }

    private func sortJourneys() {
        journeys.sort { $0.createdAtUtc > $1.createdAtUtc }
    }
}
