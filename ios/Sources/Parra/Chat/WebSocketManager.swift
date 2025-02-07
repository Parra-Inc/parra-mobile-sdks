//
//  WebSocketManager.swift
//  WebSocketsIosApp
//
//  Created by Ian MacCallum on 1/28/25.
//

import Foundation

protocol WebSocketMessage: Encodable {
    var type: String { get }
}

struct SendChatMessageRequest: WebSocketMessage {
    enum CodingKeys: String, CodingKey {
        case type
        case channelId = "channel_id"
        case content
    }

    let type = "chat:send_message"
    let channelId: String
    let content: String

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(content, forKey: .content)
    }
}

class WebSocketManager: ObservableObject {
    // MARK: - Lifecycle

    init(authToken: String) {
        self.authToken = authToken
    }

    // MARK: - Internal

    enum ConnectionStatus: Equatable {
        case connected
        case disconnected
        case error(String)
    }

    @Published private(set) var channelMessages: [String: [Message]] = [:]
    @Published private(set) var directMessages: [String: [Message]] = [:]
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected

    func connect(channels: [String]) {
        guard var urlComponents = URLComponents(string: "wss://ws.parra.io") else {
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: authToken)
        ]

        guard let url = urlComponents.url else {
            return
        }

        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        // Send initial subscription message
        let subscription = CreateMessageRequestBody(content: "Joined")
        send(subscription)

        receiveMessage()
        connectionStatus = .connected
    }

    func sendChannelMessage(_ text: String, to channel: String) {
        let message = SendChatMessageRequest(channelId: channel, content: text)
        send(message)
    }

    func sendDirectMessage(_ text: String, to userId: String) {
        let message = SendChatMessageRequest(channelId: "user:\(userId)", content: text)
        send(message)
    }

    func disconnect() {
        webSocket?.cancel()
        connectionStatus = .disconnected
    }

    // MARK: - Private

    private var webSocket: URLSessionWebSocketTask?
    private let authToken: String

    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self else {
                return
            }

            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text):
                        self.handleMessage(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            self.handleMessage(text)
                        }
                    @unknown default:
                        break
                    }
                    self.receiveMessage()

                case .failure(let error):
                    print("WebSocket receive error: \(error)")
                    self.connectionStatus = .error(error.localizedDescription)
                    // Attempt reconnection after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.reconnect()
                    }
                }
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(Message.self, from: data) else
        {
            return
        }

        var messages = channelMessages[message.channelId] ?? []
        messages.append(message)
        channelMessages[message.channelId] = messages
    }

    private func send(_ message: some Encodable) {
        guard let data = try? JSONEncoder().encode(message),
              let jsonString = String(data: data, encoding: .utf8) else
        {
            return
        }

        webSocket?.send(.string(jsonString)) { [weak self] error in
            if let error {
                print("WebSocket send error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionStatus = .error(error.localizedDescription)
                }
            }
        }
    }

    private func reconnect() {
        disconnect()
        // Reconnect with same channels
        let channels = channelMessages.keys.map { String($0) }

        connect(channels: channels)
    }
}
