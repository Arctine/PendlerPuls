import SwiftUI

@main
struct PendlerPulsApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environmentObject(session.apiClient)
        }
    }
}
