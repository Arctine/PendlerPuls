import Foundation

struct AuthService {
    let apiClient: ApiClient

    func currentUser() async throws -> User {
        try await apiClient.get("/auth/me")
    }

    func register(email: String, password: String) async throws -> User {
        try await apiClient.post(
            "/auth/register",
            body: RegisterRequest(email: email, password: password)
        )
    }

    func login(email: String, password: String) async throws -> User {
        try await apiClient.post(
            "/auth/login",
            body: LoginRequest(email: email, password: password)
        )
    }

    func logout() async throws {
        let _: EmptyResponse = try await apiClient.post("/auth/logout")
    }
}
