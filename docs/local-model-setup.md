# Local Model Setup

Verity now includes a native `VerityMLX` module that integrates MLX Swift directly.

## What Is Wired

- `LocalEmbeddingProvider` and `LocalAnswerGenerator` protocols in `VerityCore`.
- `InMemoryVectorIndex` for cosine-ranked semantic retrieval.
- `LocalAIRuntime` for cited prompt composition and local generation.
- `MLXEmbeddingProvider` using `MLXEmbedders`, `MLXEmbeddersHFAPI`, and `MLXEmbeddersTokenizers`.
- `MLXLocalAnswerGenerator` using `MLXLLM`, `MLXLMHFAPI`, `MLXLMTokenizers`, and `ChatSession`.

The default runtime configuration is:

```swift
MLXRuntimeConfiguration(
    languageModel: .huggingFace(id: "mlx-community/Qwen3-4B-4bit"),
    embeddingModel: .huggingFace(id: "sentence-transformers/all-MiniLM-L6-v2"),
    maxOutputTokens: 512
)
```

These models download to the local Hugging Face cache on first use. You can also point either model at a local directory:

```swift
let runtime = MLXRuntimeFactory.makeRuntime(
    configuration: MLXRuntimeConfiguration(
        languageModel: .localDirectory(URL(filePath: "/path/to/mlx-language-model")),
        embeddingModel: .localDirectory(URL(filePath: "/path/to/mlx-embedding-model"))
    )
)
```

## How To Use From Code

```swift
import VerityCore
import VerityMLX

let configuration = MLXRuntimeConfiguration()
let generator = MLXLocalAnswerGenerator(source: configuration.languageModel)
let embeddings = MLXEmbeddingProvider(source: configuration.embeddingModel)
let runtime = LocalAIRuntime(answerGenerator: generator, embeddingProvider: embeddings)

let index = InMemoryVectorIndex(embeddingProvider: embeddings)
try await index.replaceAll(chunks)
let matches = try await index.search("payment deadline", limit: 5)
let answer = try await runtime.answer(question: "When is payment due?", chunks: matches.map(\\.chunk))
```

## Fallback

`LocalRAGEngine` remains the no-download fallback. It keeps search, citations, templates, and evaluation usable even before MLX models have finished downloading.
