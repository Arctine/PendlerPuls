import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: AppSession
    @EnvironmentObject private var apiClient: ApiClient
    @State private var isLoggingOut = false

    var body: some View {
        Form {
            Section("Account") {
                LabeledContent("Signed in", value: session.currentUser?.email ?? "")
            }

            Section("Server") {
                TextField("API URL", text: $apiClient.baseURLString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
            }

            if let message = session.message {
                Section {
                    Label(message, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button(role: .destructive) {
                    Task { await logout() }
                } label: {
                    if isLoggingOut {
                        HStack {
                            ProgressView()
                            Text("Logging out")
                        }
                    } else {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                .disabled(isLoggingOut)
            }
        }
        .navigationTitle("Account")
    }

    private func logout() async {
        isLoggingOut = true
        defer { isLoggingOut = false }
        await session.logout()
    }
}
