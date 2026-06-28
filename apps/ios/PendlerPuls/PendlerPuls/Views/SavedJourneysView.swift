import SwiftUI

struct SavedJourneysView: View {
    @StateObject private var viewModel: SavedJourneysViewModel

    init(journeyService: JourneyService) {
        _viewModel = StateObject(
            wrappedValue: SavedJourneysViewModel(journeyService: journeyService)
        )
    }

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.journeys.isEmpty {
                ProgressView("Loading journeys")
            } else if viewModel.journeys.isEmpty {
                ContentUnavailableView("No saved journeys", systemImage: "tray")
            } else {
                ForEach(viewModel.journeys) { journey in
                    SavedJourneyRow(
                        journey: journey,
                        isRefreshing: viewModel.refreshingJourneyIDs.contains(journey.id),
                        isDeleting: viewModel.deletingJourneyIDs.contains(journey.id)
                    ) {
                        Task { await viewModel.refresh(journey) }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await viewModel.delete(journey) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.load() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .refreshable {
            await viewModel.load()
        }
        .task {
            await viewModel.loadIfNeeded()
        }
        .alert(
            "PendlerPuls",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct SavedJourneyRow: View {
    let journey: SavedJourney
    let isRefreshing: Bool
    let isDeleting: Bool
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(journey.name)
                    .font(.headline)
                Text(journey.routeTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let latest = journey.observations.first {
                VStack(alignment: .leading, spacing: 4) {
                    Label(
                        "Latest \(DisplayFormatters.dateTime.string(from: latest.collectedAtUtc))",
                        systemImage: "clock"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                    Text("\(DisplayFormatters.delay(latest.delayMinutes)) delay, \(latest.durationMinutes) min, \(latest.lineSummary)")
                        .font(.subheadline)
                }
            } else {
                Label("No observations yet", systemImage: "clock.badge.questionmark")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                onRefresh()
            } label: {
                if isRefreshing {
                    HStack {
                        ProgressView()
                        Text("Refreshing")
                    }
                } else {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.bordered)
            .disabled(isRefreshing || isDeleting)
        }
        .padding(.vertical, 6)
    }
}
