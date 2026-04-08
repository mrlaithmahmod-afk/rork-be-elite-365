import Foundation

struct LLMClient {
    private static let timeoutInterval: TimeInterval = 30
    private static let apiURL = "https://api.openai.com/v1/chat/completions"
    private static let model = "gpt-4o-mini"

    private static var apiKey: String {
        Config.EXPO_PUBLIC_OPENAI_API_KEY
    }

    nonisolated struct ChatMessage: Codable, Sendable {
        let role: String
        let content: String
    }

    nonisolated struct OpenAIRequest: Codable, Sendable {
        let model: String
        let messages: [ChatMessage]
        let stream: Bool
        let max_tokens: Int
        let temperature: Double
    }

    nonisolated enum ClientError: Error, Sendable {
        case missingAPIKey
        case networkError(String)
        case invalidResponse
        case httpError(Int, String)
        case noConnection

        var isNoConnection: Bool {
            switch self {
            case .noConnection: return true
            default: return false
            }
        }

        var userMessage: String {
            switch self {
            case .missingAPIKey:
                return "OpenAI API key not configured."
            case .networkError(let msg):
                return "Network error: \(msg)"
            case .invalidResponse:
                return "Received an invalid response from OpenAI."
            case .httpError(let code, let body):
                if code == 401 { return "Invalid OpenAI API key. Check your configuration." }
                if code == 429 { return "Rate limited. Try again in a moment." }
                if code == 500 || code == 503 { return "OpenAI servers are temporarily unavailable. Try again shortly." }
                let preview = String(body.prefix(200))
                return "Server error (\(code)): \(preview)"
            case .noConnection:
                return "No internet connection. Check your network and try again."
            }
        }
    }

    static func stream(systemPrompt: String, history: [ChatMessage], userMessage: String, maxTokens: Int = 300) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let key = apiKey
                    guard !key.isEmpty else {
                        continuation.finish(throwing: ClientError.missingAPIKey)
                        return
                    }

                    guard let endpoint = URL(string: apiURL) else {
                        continuation.finish(throwing: ClientError.invalidResponse)
                        return
                    }

                    var allMessages: [ChatMessage] = [ChatMessage(role: "system", content: systemPrompt)]
                    allMessages.append(contentsOf: history)
                    allMessages.append(ChatMessage(role: "user", content: userMessage))

                    let requestBody = OpenAIRequest(
                        model: model,
                        messages: allMessages,
                        stream: true,
                        max_tokens: maxTokens,
                        temperature: 0.85
                    )

                    var request = URLRequest(url: endpoint)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
                    request.timeoutInterval = timeoutInterval
                    request.httpBody = try JSONEncoder().encode(requestBody)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: ClientError.invalidResponse)
                        return
                    }

                    guard httpResponse.statusCode == 200 else {
                        var body = ""
                        for try await line in bytes.lines {
                            body += line
                        }
                        continuation.finish(throwing: ClientError.httpError(httpResponse.statusCode, body))
                        return
                    }

                    for try await line in bytes.lines {
                        if Task.isCancelled { break }
                        guard line.hasPrefix("data: ") else { continue }
                        let payload = String(line.dropFirst(6))
                        if payload == "[DONE]" { break }
                        if let chunk = parseSSEChunk(payload) {
                            continuation.yield(chunk)
                        }
                    }

                    continuation.finish()
                } catch let error as URLError where error.code == .notConnectedToInternet || error.code == .timedOut || error.code == .cannotConnectToHost || error.code == .networkConnectionLost || error.code == .cannotFindHost {
                    continuation.finish(throwing: ClientError.noConnection)
                } catch let error as ClientError {
                    continuation.finish(throwing: error)
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    static func send(systemPrompt: String, history: [ChatMessage], userMessage: String, maxTokens: Int = 300) async throws -> String {
        let key = apiKey
        guard !key.isEmpty else {
            throw ClientError.missingAPIKey
        }

        guard let endpoint = URL(string: apiURL) else {
            throw ClientError.invalidResponse
        }

        var allMessages: [ChatMessage] = [ChatMessage(role: "system", content: systemPrompt)]
        allMessages.append(contentsOf: history)
        allMessages.append(ChatMessage(role: "user", content: userMessage))

        let requestBody = OpenAIRequest(
            model: model,
            messages: allMessages,
            stream: false,
            max_tokens: maxTokens,
            temperature: 0.85
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeoutInterval
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClientError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw ClientError.httpError(httpResponse.statusCode, body)
        }

        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = obj["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw ClientError.invalidResponse
        }

        return content
    }

    private static func parseSSEChunk(_ json: String) -> String? {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = obj["choices"] as? [[String: Any]],
              let delta = choices.first?["delta"] as? [String: Any],
              let content = delta["content"] as? String else {
            return nil
        }
        return content
    }
}
