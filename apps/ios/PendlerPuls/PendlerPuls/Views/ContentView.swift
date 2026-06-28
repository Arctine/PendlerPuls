import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        Group {
            if session.isRestoringSession {
                ProgressView("Checking session")
                    .controlSize(.large)
            } else if session.currentUser != nil {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .task {
            await session.restoreSessionIfNeeded()
        }
    }
}

private struct MainTabView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        TabView {
            NavigationStack {
                LocationSearchView(
                    transitService: session.transitService,
                    journeyService: session.journeyService
                )
            }
            .tabItem {
                Label("Plan", systemImage: "tram.fill")
            }

            NavigationStack {
                SavedJourneysView(journeyService: session.journeyService)
            }
            .tabItem {
                Label("Saved", systemImage: "clock.arrow.circlepath")
            }

            NavigationStack {
                AccountView()
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
    }
}
