import SwiftUI

enum DisplayFormatters {
    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    static let dateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter
    }()

    static func delay(_ minutes: Int) -> String {
        if minutes == 0 {
            return "0 min"
        }

        let sign = minutes > 0 ? "+" : ""
        return "\(sign)\(minutes) min"
    }
}

struct AppPanel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct StatusBanner: View {
    let message: String
    let systemImage: String
    let color: Color

    var body: some View {
        AppPanel {
            Label(message, systemImage: systemImage)
                .foregroundStyle(color)
                .font(.callout)
        }
    }
}

struct FieldRow<Content: View>: View {
    let systemImage: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 22)

            content
        }
        .frame(minHeight: 38)
    }
}
