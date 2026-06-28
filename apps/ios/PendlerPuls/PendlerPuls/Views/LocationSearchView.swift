import SwiftUI

struct LocationSearchView: View {
    @StateObject private var viewModel: LocationSearchViewModel
    @State private var fromSearchTask: Task<Void, Never>?
    @State private var toSearchTask: Task<Void, Never>?

    init(transitService: TransitService, journeyService: JourneyService) {
        _viewModel = StateObject(
            wrappedValue: LocationSearchViewModel(
                transitService: transitService,
                journeyService: journeyService
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Route")
                    .font(.title2.bold())

                locationPanel(
                    title: "From",
                    systemImage: "location.circle",
                    query: $viewModel.fromQuery,
                    selectedLocation: viewModel.selectedFrom,
                    results: viewModel.fromResults,
                    isSearching: viewModel.isSearchingFrom,
                    field: .from
                )

                locationPanel(
                    title: "To",
                    systemImage: "mappin.circle",
                    query: $viewModel.toQuery,
                    selectedLocation: viewModel.selectedTo,
                    results: viewModel.toResults,
                    isSearching: viewModel.isSearchingTo,
                    field: .to
                )

                if let errorMessage = viewModel.errorMessage {
                    StatusBanner(
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle",
                        color: .red
                    )
                }

                if let successMessage = viewModel.successMessage {
                    StatusBanner(
                        message: successMessage,
                        systemImage: "checkmark.circle",
                        color: .green
                    )
                }

                Button {
                    Task { await viewModel.previewJourney() }
                } label: {
                    if viewModel.isPreviewing {
                        HStack {
                            ProgressView()
                            Text("Previewing")
                        }
                    } else {
                        Label("Preview Journey", systemImage: "eye")
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.canPreview)

                if !viewModel.routeOptions.isEmpty {
                    TripPreviewView(
                        options: viewModel.routeOptions,
                        selectedOptionID: $viewModel.selectedRouteOptionID,
                        journeyName: $viewModel.journeyName,
                        isSaving: viewModel.isSaving
                    ) {
                        Task { await viewModel.saveJourney() }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Plan")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.fromQuery) { _, value in
            if viewModel.selectedFrom?.label == value {
                fromSearchTask?.cancel()
                return
            }

            viewModel.clearSelectionIfNeeded(for: .from, query: value)
            scheduleSearch(for: .from)
        }
        .onChange(of: viewModel.toQuery) { _, value in
            if viewModel.selectedTo?.label == value {
                toSearchTask?.cancel()
                return
            }

            viewModel.clearSelectionIfNeeded(for: .to, query: value)
            scheduleSearch(for: .to)
        }
    }

    @ViewBuilder
    private func locationPanel(
        title: String,
        systemImage: String,
        query: Binding<String>,
        selectedLocation: LocationReference?,
        results: [LocationReference],
        isSearching: Bool,
        field: LocationSearchViewModel.Field
    ) -> some View {
        AppPanel {
            Label(title, systemImage: systemImage)
                .font(.headline)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(title, text: query)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                if isSearching {
                    ProgressView()
                }
            }
            .padding(.vertical, 4)

            if let selectedLocation {
                selectedLocationRow(selectedLocation)
            }

            if !results.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(results.prefix(8).enumerated()), id: \.element.id) { index, location in
                        Button {
                            viewModel.select(location, for: field)
                        } label: {
                            locationResultRow(location)
                        }

                        if index < min(results.count, 8) - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private func selectedLocationRow(_ location: LocationReference) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(location.label)
                    .font(.subheadline.weight(.semibold))
                Text(location.kindLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func locationResultRow(_ location: LocationReference) -> some View {
        HStack(spacing: 12) {
            Image(systemName: location.iconName)
                .foregroundStyle(.tint)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(location.name)
                    .foregroundStyle(.primary)
                    .font(.subheadline.weight(.semibold))
                Text(location.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.vertical, 10)
    }

    private func scheduleSearch(for field: LocationSearchViewModel.Field) {
        switch field {
        case .from:
            fromSearchTask?.cancel()
            fromSearchTask = Task {
                try? await Task.sleep(nanoseconds: 350_000_000)
                guard !Task.isCancelled else { return }
                await viewModel.search(.from)
            }
        case .to:
            toSearchTask?.cancel()
            toSearchTask = Task {
                try? await Task.sleep(nanoseconds: 350_000_000)
                guard !Task.isCancelled else { return }
                await viewModel.search(.to)
            }
        }
    }
}
