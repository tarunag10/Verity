import SwiftUI
import VerityCore

struct EvaluationView: View {
    @ObservedObject var store: LibraryStore

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if let report = store.evaluationReports.first {
                VStack(spacing: 0) {
                    summary(report)
                    Divider()
                    List(report.items) { item in
                        EvaluationItemRow(item: item)
                            .padding(.vertical, 6)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Evaluation Yet",
                    systemImage: "checklist.checked",
                    description: Text("Run local sample questions to check whether retrieval returns cited answers and honest not-found responses.")
                )
            }
        }
        .navigationTitle("Evaluation")
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("RAG Quality Checks")
                    .font(.headline)
                Text("Runs local PRD-style questions against the current library.")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            Spacer()
            Button {
                store.runEvaluation()
            } label: {
                Label("Run Evaluation", systemImage: "play.fill")
            }
            .disabled(store.chunks.isEmpty)
        }
        .padding()
    }

    private func summary(_ report: EvaluationReport) -> some View {
        HStack(spacing: 12) {
            AccessibleMetric(title: "Checks", value: "\(report.totalCount)", systemImage: "checklist.checked")
            AccessibleMetric(title: "Answered", value: "\(report.answeredCount)", systemImage: "checkmark.circle.fill")
            AccessibleMetric(title: "Not Found", value: "\(report.notFoundCount)", systemImage: "questionmark.circle.fill")
            AccessibleMetric(title: "Answer Rate", value: report.answerRate.formatted(.percent.precision(.fractionLength(0))), systemImage: "chart.line.uptrend.xyaxis")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EvaluationItemRow: View {
    let item: EvaluationItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Label(item.status == .answered ? "Answered" : "Not Found", systemImage: item.status == .answered ? "checkmark.circle" : "questionmark.circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(item.question)
                    .font(.headline)
                Spacer()
                Text("\(item.citations.count) citations")
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            Text(item.answer)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

            if let citation = item.citations.first {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.bubble")
                        .foregroundStyle(.primary)
                    Text("\(citation.documentName): \(citation.snippet)")
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }
                .accessiblePanel()
            }
        }
        .accessibilityElement(children: .combine)
    }
}
