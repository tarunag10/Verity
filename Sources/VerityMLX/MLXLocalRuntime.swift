import Foundation
import MLX
import MLXEmbedders
import MLXEmbeddersHFAPI
import MLXEmbeddersTokenizers
import MLXLLM
import MLXLMCommon
import MLXLMHFAPI
import MLXLMTokenizers
import VerityCore

public enum MLXModelSource: Sendable, Hashable {
    case huggingFace(id: String, revision: String = "main")
    case localDirectory(URL)
}

public struct MLXRuntimeConfiguration: Sendable, Hashable {
    public var languageModel: MLXModelSource
    public var embeddingModel: MLXModelSource
    public var maxOutputTokens: Int

    public init(
        languageModel: MLXModelSource = .huggingFace(id: "mlx-community/Qwen3-4B-4bit"),
        embeddingModel: MLXModelSource = .huggingFace(id: "sentence-transformers/all-MiniLM-L6-v2"),
        maxOutputTokens: Int = 512
    ) {
        self.languageModel = languageModel
        self.embeddingModel = embeddingModel
        self.maxOutputTokens = maxOutputTokens
    }
}

public actor MLXLocalAnswerGenerator: LocalAnswerGenerator {
    public nonisolated let identifier: String

    private let source: MLXModelSource
    private let maxOutputTokens: Int
    private var container: ModelContainer?

    public init(source: MLXModelSource, maxOutputTokens: Int = 512) {
        self.source = source
        self.maxOutputTokens = maxOutputTokens
        self.identifier = source.displayName
    }

    public func warmUp(progressHandler: @Sendable @escaping (Progress) -> Void = { _ in }) async throws {
        _ = try await loadContainer(progressHandler: progressHandler)
    }

    public func generate(prompt: String) async throws -> String {
        let container = try await loadContainer()
        let session = ChatSession(
            container,
            instructions: "You are Verity, a private local document assistant. Answer only from the supplied source excerpts.",
            generateParameters: GenerateParameters(maxTokens: maxOutputTokens, temperature: 0.2)
        )
        return try await session.respond(to: prompt)
    }

    private func loadContainer(progressHandler: @Sendable @escaping (Progress) -> Void = { _ in }) async throws -> ModelContainer {
        if let container { return container }

        let loaded: ModelContainer
        switch source {
        case .localDirectory(let directory):
            loaded = try await MLXLMCommon.loadModelContainer(
                from: directory,
                using: TokenizersLoader()
            )
        case .huggingFace(let id, let revision):
            loaded = try await MLXLMCommon.loadModelContainer(
                from: HubClient.default,
                using: TokenizersLoader(),
                id: id,
                revision: revision,
                progressHandler: progressHandler
            )
        }

        container = loaded
        return loaded
    }
}

public actor MLXEmbeddingProvider: LocalEmbeddingProvider {
    public nonisolated let identifier: String

    private let source: MLXModelSource
    private var container: EmbedderModelContainer?

    public init(source: MLXModelSource) {
        self.source = source
        self.identifier = source.displayName
    }

    public func warmUp(progressHandler: @Sendable @escaping (Progress) -> Void = { _ in }) async throws {
        _ = try await loadContainer(progressHandler: progressHandler)
    }

    public func embed(_ texts: [String]) async throws -> [[Float]] {
        guard texts.isEmpty == false else { return [] }

        let container = try await loadContainer()
        return await container.perform { context in
            let encodedInputs = texts.map {
                context.tokenizer.encode(text: $0, addSpecialTokens: true)
            }
            let padToken = context.tokenizer.eosTokenId ?? context.tokenizer.unknownTokenId ?? 0
            let maxLength = encodedInputs.reduce(1) { max($0, $1.count) }
            let padded = stacked(encodedInputs.map { input in
                MLXArray(input + Array(repeating: padToken, count: maxLength - input.count))
            })
            let mask = padded .!= padToken
            let tokenTypes = MLXArray.zeros(like: padded)
            let result = context.pooling(
                context.model(
                    padded,
                    positionIds: nil,
                    tokenTypeIds: tokenTypes,
                    attentionMask: mask
                ),
                normalize: true,
                applyLayerNorm: true
            )
            result.eval()
            return result.map { $0.asArray(Float.self) }
        }
    }

    private func loadContainer(progressHandler: @Sendable @escaping (Progress) -> Void = { _ in }) async throws -> EmbedderModelContainer {
        if let container { return container }

        let loaded: EmbedderModelContainer
        switch source {
        case .localDirectory(let directory):
            loaded = try await EmbedderModelFactory.shared.loadContainer(
                from: directory,
                using: TokenizersLoader()
            )
        case .huggingFace(let id, let revision):
            loaded = try await EmbedderModelFactory.shared.loadContainer(
                from: HubClient.default,
                using: TokenizersLoader(),
                configuration: ModelConfiguration(id: id, revision: revision),
                progressHandler: progressHandler
            )
        }

        container = loaded
        return loaded
    }
}

public enum MLXRuntimeFactory {
    public static func makeRuntime(configuration: MLXRuntimeConfiguration = .init()) -> LocalAIRuntime {
        let generator = MLXLocalAnswerGenerator(
            source: configuration.languageModel,
            maxOutputTokens: configuration.maxOutputTokens
        )
        let embeddings = MLXEmbeddingProvider(source: configuration.embeddingModel)
        return LocalAIRuntime(answerGenerator: generator, embeddingProvider: embeddings)
    }
}

private extension MLXModelSource {
    var displayName: String {
        switch self {
        case .huggingFace(let id, let revision):
            revision == "main" ? id : "\(id)@\(revision)"
        case .localDirectory(let url):
            url.path(percentEncoded: false)
        }
    }
}
