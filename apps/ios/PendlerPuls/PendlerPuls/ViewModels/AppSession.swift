import Combine
import Foundation

@MainActor
final class AppSession: ObservableObject {
    let apiClient: ApiClient
    let authService: AuthService
    let transitService: TransitService
    let journeyService: JourneyService

    @Published var currentUser: User?
    @Published var isRestoringSession = false
    @Published var message: String?

    private var didRestoreSession = false

    init() {
        let apiClient = ApiClient()
        self.apiClient = apiClient
        authService = AuthService(apiClient: apiClient)
        transitService = TransitService(apiClient: apiClient)
        journeyService = JourneyService(apiClient: apiClient)
    }

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
        authService = AuthService(apiClient: apiClient)
        transitService = TransitService(apiClient: apiClient)
        journeyService = JourneyService(apiClient: apiClient)
    }

    func restoreSessionIfNeeded() async {
        guard !didRestoreSession else { return }
        didRestoreSession = true

        isRestoringSession = true
        defer { isRestoringSession = false }

        do {
            currentUser = try await authService.currentUser()
        } catch let error as ApiError where error.statusCode == 401 {
            currentUser = nil
        } catch {
            currentUser = nil
            message = userFacingMessage(for: error)
        }
    }

    func login(email: String, password: String) async {
        do {
            message = nil
            _ = try await authService.login(email: email, password: password)
            currentUser = try await authService.currentUser()
        } catch {
            message = userFacingMessage(for: error)
        }
    }

    func register(email: String, password: String) async {
        do {
            message = nil
            _ = try await authService.register(email: email, password: password)
            currentUser = try await authService.currentUser()
        } catch {
            message = userFacingMessage(for: error)
        }
    }

    func logout() async {
        do {
            message = nil
            try await authService.logout()
            apiClient.clearCookies()
            currentUser = nil
        } catch {
            message = userFacingMessage(for: error)
        }
    }
}
