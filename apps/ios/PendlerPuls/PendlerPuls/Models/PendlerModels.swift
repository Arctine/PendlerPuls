import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: UUID
    let email: String
}

struct LocationReference: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let label: String
    let latitude: Double
    let longitude: Double
    let kind: String?

    var iconName: String {
        switch kind {
        case "address":
            return "mappin.and.ellipse"
        case "stop":
            return "tram.fill"
        default:
            return "building.2"
        }
    }

    var kindLabel: String {
        switch kind {
        case "address":
            return "Address"
        case "stop":
            return "Stop"
        default:
            return "Place"
        }
    }
}

struct TripPreview: Codable, Equatable, Identifiable {
    let fromName: String
    let toName: String
    let expectedStartTime: Date
    let expectedEndTime: Date
    let durationMinutes: Int
    let delayMinutes: Int
    let modes: [String]
    let lineSummary: String
    let attribution: String

    var routeTitle: String {
        "\(fromName) to \(toName)"
    }

    var id: String {
        "\(expectedStartTime.timeIntervalSince1970)-\(expectedEndTime.timeIntervalSince1970)-\(lineSummary)"
    }
}

struct Observation: Codable, Identifiable, Equatable {
    let id: UUID
    let collectedAtUtc: Date
    let expectedStartTime: Date
    let expectedEndTime: Date
    let durationMinutes: Int
    let delayMinutes: Int
    let lineSummary: String
}

struct SavedJourney: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let from: LocationReference
    let to: LocationReference
    let createdAtUtc: Date
    let observations: [Observation]

    var routeTitle: String {
        "\(from.name) to \(to.name)"
    }
}

struct RegisterRequest: Encodable {
    let email: String
    let password: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct TripPreviewRequest: Encodable {
    let from: LocationReference
    let to: LocationReference
}

struct SaveJourneyRequest: Encodable {
    let name: String
    let from: LocationReference
    let to: LocationReference
}

struct EmptyResponse: Decodable {}

struct ProblemResponse: Decodable {
    let detail: String?
    let message: String?
    let title: String?
}

struct ApiError: LocalizedError, Equatable {
    let message: String
    let statusCode: Int?

    var errorDescription: String? {
        message
    }
}
