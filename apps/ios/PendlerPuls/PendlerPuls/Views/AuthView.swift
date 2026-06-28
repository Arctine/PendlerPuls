import SwiftUI

struct AuthView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case login = "Login"
        case register = "Register"

        var id: String { rawValue }

        var symbolName: String {
            switch self {
            case .login:
                return "person.crop.circle.badge.checkmark"
            case .register:
                return "person.badge.plus"
            }
        }
    }

    @EnvironmentObject private var session: AppSession
    @EnvironmentObject private var apiClient: ApiClient

    @State private var mode: Mode = .login
    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AppPanel {
                        FieldRow(systemImage: "server.rack") {
                            TextField("API URL", text: $apiClient.baseURLString)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                        }
                    }

                    AppPanel {
                        Picker("Mode", selection: $mode) {
                            ForEach(Mode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        Divider()

                        FieldRow(systemImage: "envelope") {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }

                        Divider()

                        FieldRow(systemImage: "lock") {
                            SecureField(
                                mode == .register ? "Password, 10+ characters" : "Password",
                                text: $password
                            )
                            .textContentType(mode == .register ? .newPassword : .password)
                        }
                    }

                    if let message = session.message {
                        StatusBanner(
                            message: message,
                            systemImage: "exclamationmark.triangle",
                            color: .red
                        )
                    }

                    Button {
                        Task { await submit() }
                    } label: {
                        if isSubmitting {
                            HStack {
                                ProgressView()
                                Text(mode == .login ? "Signing in" : "Creating account")
                            }
                        } else {
                            Label(mode.rawValue, systemImage: mode.symbolName)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!canSubmit)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("PendlerPuls")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var canSubmit: Bool {
        let hasEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).contains("@")
        let hasPassword = mode == .register ? password.count >= 10 : !password.isEmpty
        return hasEmail && hasPassword && !isSubmitting
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        switch mode {
        case .login:
            await session.login(email: trimmedEmail, password: password)
        case .register:
            await session.register(email: trimmedEmail, password: password)
        }
    }
}
