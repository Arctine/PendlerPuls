import Combine
import Foundation

@MainActor
final class ApiClient: ObservableObject {
    static let defaultBaseURLString = "https://pendlerpuls.onrender.com/api"

    private static let storedBaseURLKey = "PendlerPuls.ApiBaseURL"

    @Published var baseURLString: String {
        didSet {
            UserDefaults.standard.set(
                baseURLString.trimmingCharacters(in: .whitespacesAndNewlines),
                forKey: Self.storedBaseURLKey
            )
        }
    }

    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder.pendlerPulsDecoder

    init() {
        baseURLString = UserDefaults.standard.string(forKey: Self.storedBaseURLKey)
            ?? Self.defaultBaseURLString

        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        configuration.httpCookieStorage = .shared
        session = URLSession(configuration: configuration)
    }

    func get<Response: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> Response {
        try await request(path, method: "GET", queryItems: queryItems)
    }

    func post<Response: Decodable, Body: Encodable>(
        _ path: String,
        body: Body
    ) async throws -> Response {
        let data = try encoder.encode(body)
        return try await request(path, method: "POST", body: data)
    }

    func post<Response: Decodable>(_ path: String) async throws -> Response {
        try await request(path, method: "POST")
    }

    func delete(_ path: String) async throws {
        let _: EmptyResponse = try await request(path, method: "DELETE")
    }

    func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
    }

    private func request<Response: Decodable>(
        _ path: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil
    ) async throws -> Response {
        var urlRequest = URLRequest(url: try makeURL(path: path, queryItems: queryItems))
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError(message: "The server returned an invalid response.", statusCode: nil)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw decodeProblem(from: data, statusCode: httpResponse.statusCode)
        }

        if httpResponse.statusCode == 204 || data.isEmpty {
            if Response.self == EmptyResponse.self {
                return EmptyResponse() as! Response
            }

            throw ApiError(
                message: "The server returned an empty response.",
                statusCode: httpResponse.statusCode
            )
        }

        return try decoder.decode(Response.self, from: data)
    }

    private func makeURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        let trimmedBase = baseURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let baseURL = URL(string: trimmedBase),
            baseURL.scheme != nil,
            baseURL.host != nil,
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        else {
            throw ApiError(message: "Enter a valid API URL.", statusCode: nil)
        }

        let basePath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let requestPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let combinedPath = [basePath, requestPath]
            .filter { !$0.isEmpty }
            .joined(separator: "/")

        components.path = combinedPath.isEmpty ? "/" : "/\(combinedPath)"
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else {
            throw ApiError(message: "Enter a valid API URL.", statusCode: nil)
        }

        return url
    }

    private func decodeProblem(from data: Data, statusCode: Int) -> ApiError {
        let problem = try? decoder.decode(ProblemResponse.self, from: data)
        let message = problem?.detail
            ?? problem?.message
            ?? problem?.title
            ?? String(data: data, encoding: .utf8)
            ?? "The request could not be completed."

        return ApiError(message: message, statusCode: statusCode)
    }
}

func userFacingMessage(for error: Error) -> String {
    if let apiError = error as? ApiError {
        return apiError.message
    }

    if let urlError = error as? URLError {
        switch urlError.code {
        case .notConnectedToInternet:
            return "The iPhone is offline."
        case .cannotFindHost, .cannotConnectToHost:
            return "The API server could not be reached."
        case .secureConnectionFailed, .serverCertificateUntrusted:
            return "The API server needs a valid HTTPS connection."
        case .cancelled:
            return "The request was cancelled."
        default:
            return urlError.localizedDescription
        }
    }

    return error.localizedDescription
}

private extension JSONDecoder {
    static var pendlerPulsDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            if let date = ISO8601DateFormatter.pendlerPulsWithFractionalSeconds.date(from: value)
                ?? ISO8601DateFormatter.pendlerPuls.date(from: value) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO 8601 date: \(value)"
            )
        }

        return decoder
    }
}

private extension ISO8601DateFormatter {
    static let pendlerPulsWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let pendlerPuls: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
