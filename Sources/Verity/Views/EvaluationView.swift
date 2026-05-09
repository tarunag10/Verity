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
                    .foregroundStyle(.secondary)
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
            EvaluationMetric(title: "Checks", value: "\(report.totalCount)", systemImage: "checklist.checked")
            EvaluationMetric(title: "Answered", value: "\(report.answeredCount)", systemImage: "checkmark.circle.fill")
            EvaluationMetric(title: "Not Found", value: "\(report.notFoundCount)", systemImage: "questionmark.circle.fill")
            EvaluationMetric(title: "Answer Rate", value: report.answerRate.formatted(.percent.precision(.fractionLength(0))), systemImage: "chart.line.uptrend.xyaxis")
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
    }
}

private struct EvaluationMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .frame(minWidth: 118, alignment: .leading)
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct EvaluationItemRow: View {
    let item: EvaluationItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Label(item.status == .answered ? "Answered" : "Not Found", systemImage: item.status == .answered ? "checkmark.circle" : "questionmark.circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(item.status == .answered ? .green : .orange)
                Text(item.question)
                    .font(.headline)
                Spacer()
                Text("\(item.citations.count) citations")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(item.answer)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

            if let citation = item.citations.first {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.bubble")
                        .foregroundStyle(.tertiary)
                    Text("\(citation.documentName): \(citation.snippet)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
            }
        }
    }
}
