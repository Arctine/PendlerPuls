import Foundation

struct TransitService {
    let apiClient: ApiClient

    func searchLocations(query: String) async throws -> [LocationReference] {
        try await apiClient.get(
            "/transit/locations",
            queryItems: [URLQueryItem(name: "query", value: query)]
        )
    }

    func preview(from: LocationReference, to: LocationReference) async throws -> TripPreview {
        try await apiClient.post(
            "/transit/preview",
            body: TripPreviewRequest(from: from, to: to)
        )
    }

    func routeOptions(from: LocationReference, to: LocationReference) async throws -> [TripPreview] {
        do {
            return try await apiClient.post(
                "/transit/options",
                body: TripPreviewRequest(from: from, to: to)
            )
        } catch let error as ApiError where error.statusCode == 404 {
            return [try await preview(from: from, to: to)]
        }
    }
}
