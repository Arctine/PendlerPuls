import Foundation

struct JourneyService {
    let apiClient: ApiClient

    func savedJourneys() async throws -> [SavedJourney] {
        try await apiClient.get("/journeys/")
    }

    func saveJourney(
        name: String,
        from: LocationReference,
        to: LocationReference
    ) async throws -> SavedJourney {
        try await apiClient.post(
            "/journeys/",
            body: SaveJourneyRequest(name: name, from: from, to: to)
        )
    }

    func refreshJourney(id: UUID) async throws -> SavedJourney {
        try await apiClient.post("/journeys/\(id.uuidString)/refresh")
    }

    func deleteJourney(id: UUID) async throws {
        try await apiClient.delete("/journeys/\(id.uuidString)")
    }
}
