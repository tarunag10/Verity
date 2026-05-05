import SwiftUI
import VerityCore

struct EvaluationView: View {
    @ObservedObject var store: LibraryStore

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if let report = store.evaluationReports.first {
                List(report.items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(item.status == .answered ? "Answered" : "Not Found", systemImage: item.status == .answered ? "checkmark.circle" : "questionmark.circle")
                                .foregroundStyle(item.status == .answered ? .green : .orange)
                            Text(item.question)
                                .font(.headline)
                        }
                        Text(item.answer)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                        if let citation = item.citations.first {
                            Text("\(citation.documentName): \(citation.snippet)")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 6)
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
}
