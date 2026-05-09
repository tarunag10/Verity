import SwiftUI

extension View {
    func accessibleMinimumTarget() -> some View {
        self
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }

    func accessiblePanel() -> some View {
        self
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary, lineWidth: 1)
            }
    }

    func accessibleFocusRing() -> some View {
        self
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 2)
            }
    }
}

struct AccessibleStatusLabel: View {
    let title: String
    let detail: String?
    let systemImage: String

    init(_ title: String, detail: String? = nil, systemImage: String) {
        self.title = title
        self.detail = detail
        self.systemImage = systemImage
    }

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundStyle(.primary)
                if let detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
    }
}

struct AccessibleMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .monospacedDigit()
        }
        .frame(minWidth: 124, minHeight: 64, alignment: .leading)
        .accessiblePanel()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}
