import Foundation

public struct TemplateEngine: Sendable {
    public static let builtInTemplates: [TemplateDefinition] = [
        TemplateDefinition(
            id: .invoiceExtraction,
            name: "Invoice Extraction",
            summary: "Extract vendor, invoice number, dates, total, and payment terms.",
            fields: [
                TemplateField(key: "vendor", label: "Vendor", prompt: "Vendor name"),
                TemplateField(key: "invoiceNumber", label: "Invoice Number", prompt: "Invoice identifier"),
                TemplateField(key: "invoiceDate", label: "Invoice Date", prompt: "Invoice date"),
                TemplateField(key: "dueDate", label: "Due Date", prompt: "Payment due date"),
                TemplateField(key: "total", label: "Total", prompt: "Total amount"),
                TemplateField(key: "paymentTerms", label: "Payment Terms", prompt: "Payment terms")
            ]
        ),
        TemplateDefinition(
            id: .contractReview,
            name: "Contract Review",
            summary: "Extract parties, dates, renewal, termination, governing law, and payment terms.",
            fields: [
                TemplateField(key: "parties", label: "Parties", prompt: "Contract parties"),
                TemplateField(key: "effectiveDate", label: "Effective Date", prompt: "Effective date"),
                TemplateField(key: "renewalDate", label: "Renewal Date", prompt: "Renewal date"),
                TemplateField(key: "terminationTerms", label: "Termination Terms", prompt: "Termination terms"),
                TemplateField(key: "governingLaw", label: "Governing Law", prompt: "Governing law"),
                TemplateField(key: "paymentTerms", label: "Payment Terms", prompt: "Payment terms")
            ]
        ),
        TemplateDefinition(id: .manualTroubleshooting, name: "Manual Troubleshooting", summary: "Find product, model, warnings, warranty, and troubleshooting steps.", fields: [
            TemplateField(key: "productName", label: "Product Name", prompt: "Product name"),
            TemplateField(key: "model", label: "Model", prompt: "Model number"),
            TemplateField(key: "troubleshooting", label: "Troubleshooting", prompt: "Troubleshooting steps"),
            TemplateField(key: "warnings", label: "Warnings", prompt: "Warnings"),
            TemplateField(key: "warranty", label: "Warranty", prompt: "Warranty terms")
        ]),
        TemplateDefinition(id: .researchPaperSummary, name: "Research Paper Summary", summary: "Extract title, authors, abstract, methods, findings, and limitations.", fields: [
            TemplateField(key: "title", label: "Title", prompt: "Paper title"),
            TemplateField(key: "authors", label: "Authors", prompt: "Authors"),
            TemplateField(key: "abstract", label: "Abstract", prompt: "Abstract"),
            TemplateField(key: "findings", label: "Findings", prompt: "Findings"),
            TemplateField(key: "limitations", label: "Limitations", prompt: "Limitations")
        ]),
        TemplateDefinition(id: .policyReview, name: "Policy Review", summary: "Extract policy owner, obligations, risks, and exceptions.", fields: [
            TemplateField(key: "owner", label: "Owner", prompt: "Policy owner"),
            TemplateField(key: "obligations", label: "Obligations", prompt: "Obligations"),
            TemplateField(key: "exceptions", label: "Exceptions", prompt: "Exceptions"),
            TemplateField(key: "risks", label: "Risks", prompt: "Risks")
        ]),
        TemplateDefinition(id: .keyDates, name: "Key Dates and Deadlines", summary: "Find renewal, due, effective, expiration, and deadline dates.", fields: [
            TemplateField(key: "effectiveDate", label: "Effective Date", prompt: "Effective date"),
            TemplateField(key: "renewalDate", label: "Renewal Date", prompt: "Renewal date"),
            TemplateField(key: "dueDate", label: "Due Date", prompt: "Due date"),
            TemplateField(key: "expirationDate", label: "Expiration Date", prompt: "Expiration date")
        ]),
        TemplateDefinition(id: .compareDocuments, name: "Compare Documents", summary: "Compare selected documents by obligations, terms, risks, and differences.", fields: [
            TemplateField(key: "sharedThemes", label: "Shared Themes", prompt: "Shared themes"),
            TemplateField(key: "differences", label: "Differences", prompt: "Differences"),
            TemplateField(key: "risks", label: "Risks", prompt: "Risks")
        ])
    ]

    public init() {}

    public func run(templateID: TemplateID, documents: [DocumentMetadata], chunks: [DocumentChunk]) -> TemplateRunResult {
        let template = Self.builtInTemplates.first { $0.id == templateID } ?? Self.builtInTemplates[0]
        let documentIDs = Set(documents.map(\.id))
        let scopedChunks = chunks.filter { documentIDs.isEmpty || documentIDs.contains($0.documentID) }
        let fields = template.fields.map { field in
            extract(field: field, chunks: scopedChunks)
        }

        return TemplateRunResult(
            templateID: template.id,
            templateName: template.name,
            documentNames: documents.map(\.fileName),
            fields: fields
        )
    }

    public func run(customTemplate: CustomTemplateDefinition, documents: [DocumentMetadata], chunks: [DocumentChunk]) -> TemplateRunResult {
        let documentIDs = Set(documents.map(\.id))
        let scopedChunks = chunks.filter { documentIDs.isEmpty || documentIDs.contains($0.documentID) }
        let fields = customTemplate.fields.map { field in
            extract(field: field, chunks: scopedChunks)
        }

        return TemplateRunResult(
            templateID: .invoiceExtraction,
            customTemplateID: customTemplate.id,
            templateName: customTemplate.name,
            documentNames: documents.map(\.fileName),
            fields: fields
        )
    }

    public func exportCSV(results: [TemplateRunResult]) -> String {
        var rows = [["Template", "Documents", "Field", "Value", "Citation"]]
        for result in results {
            let documentNames = result.documentNames.joined(separator: "; ")
            for field in result.fields {
                let citation = field.citation.map { citation in
                    "\(citation.documentName)\(citation.pageNumber.map { " p.\($0)" } ?? ""): \(citation.snippet)"
                } ?? ""
                rows.append([result.templateName, documentNames, field.label, field.value, citation])
            }
        }
        return rows.map { $0.map(csvEscape).joined(separator: ",") }.joined(separator: "\n")
    }

    private func extract(field: TemplateField, chunks: [DocumentChunk]) -> ExtractedField {
        let keys = searchKeys(for: field.key, label: field.label)
        for chunk in chunks {
            if let value = lineValue(keys: keys, in: chunk.text) {
                return ExtractedField(key: field.key, label: field.label, value: value, citation: citation(for: chunk, snippet: value))
            }
        }

        if let fallback = chunks.first(where: { chunk in
            keys.contains { key in chunk.text.localizedCaseInsensitiveContains(key) }
        }) {
            return ExtractedField(key: field.key, label: field.label, value: sentence(containing: keys, in: fallback.text), citation: citation(for: fallback, snippet: sentence(containing: keys, in: fallback.text)))
        }

        return ExtractedField(key: field.key, label: field.label, value: "Not found", citation: nil)
    }

    private func searchKeys(for key: String, label: String) -> [String] {
        let spaced = label.lowercased()
        switch key {
        case "invoiceNumber": return ["invoice number", "invoice no", "invoice #"]
        case "invoiceDate": return ["invoice date", "date"]
        case "dueDate": return ["due date", "payment due", "due"]
        case "paymentTerms": return ["payment terms", "terms"]
        case "terminationTerms": return ["termination", "terminate"]
        case "renewalDate": return ["renewal date", "renewal"]
        case "effectiveDate": return ["effective date", "effective"]
        case "governingLaw": return ["governing law", "law"]
        case "expirationDate": return ["expiration date", "expires", "expiry"]
        default: return [spaced, key.lowercased()]
        }
    }

    private func lineValue(keys: [String], in text: String) -> String? {
        for line in text.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            let lower = trimmed.lowercased()
            guard let key = keys.first(where: { lower.hasPrefix($0) }) else { continue }
            let separators = [":", "-", "–"]
            for separator in separators {
                if let range = trimmed.range(of: separator) {
                    let value = trimmed[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !value.isEmpty { return value }
                }
            }
            return trimmed.dropFirst(key.count).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    private func sentence(containing keys: [String], in text: String) -> String {
        let sentences = text
            .replacingOccurrences(of: "\n", with: " ")
            .components(separatedBy: CharacterSet(charactersIn: ".?!"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return sentences.first { sentence in
            keys.contains { sentence.localizedCaseInsensitiveContains($0) }
        } ?? String(text.prefix(180))
    }

    private func citation(for chunk: DocumentChunk, snippet: String) -> Citation {
        Citation(documentID: chunk.documentID, documentName: chunk.documentName, pageNumber: chunk.pageNumber, snippet: String(snippet.prefix(240)))
    }

    private func csvEscape(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
