import SwiftUI

struct TripPreviewView: View {
    let options: [TripPreview]
    @Binding var selectedOptionID: TripPreview.ID?
    @Binding var journeyName: String
    let isSaving: Bool
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AppPanel {
                Text(options.count == 1 ? "Journey" : "Journeys")
                    .font(.headline)

                ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                    Button {
                        selectedOptionID = option.id
                    } label: {
                        routeOptionRow(option, index: index)
                    }

                    if index < options.count - 1 {
                        Divider()
                    }
                }
            }

            AppPanel {
                Text("Save")
                    .font(.headline)

                FieldRow(systemImage: "tag") {
                    TextField("Journey name", text: $journeyName)
                }

                Button {
                    onSave()
                } label: {
                    if isSaving {
                        HStack {
                            ProgressView()
                            Text("Saving")
                        }
                    } else {
                        Label("Save Journey", systemImage: "tray.and.arrow.down")
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .disabled(isSaving || journeyName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2)
            }
        }
    }

    private func routeOptionRow(_ option: TripPreview, index: Int) -> some View {
        let isSelected = selectedOptionID == option.id

        return HStack(alignment: .top, spacing: 12) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? .green : .secondary)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("Option \(index + 1)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(option.durationMinutes) min")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }

                Text("\(DisplayFormatters.time.string(from: option.expectedStartTime)) to \(DisplayFormatters.time.string(from: option.expectedEndTime))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Label(option.lineSummary, systemImage: "tram.fill")
                    Label(DisplayFormatters.delay(option.delayMinutes), systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8)
    }
}
