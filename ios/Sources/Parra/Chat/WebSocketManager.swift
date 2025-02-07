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
    let type = "chat:send_message"
    let channelId: String
    let content: String

    enum CodingKeys: String, CodingKey {
        case type
        case channelId = "channel_id"
        case content
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.channelId, forKey: .channelId)
        try container.encode(self.content, forKey: .content)
    }
}

class WebSocketManager: ObservableObject {
    @Published private(set) var channelMessages: [String: [Message]] = [:]
    @Published private(set) var directMessages: [String: [Message]] = [:]
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected

    enum ConnectionStatus: Equatable {
        case connected
        case disconnected
        case error(String)
    }

    private var webSocket: URLSessionWebSocketTask?
    private let authToken: String

    init(authToken: String) {
        self.authToken = authToken
    }

    func connect(channels: [String]) {
        guard var urlComponents = URLComponents(string: "wss://ws.parra.io") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "token", value: authToken),
        ]

        guard let url = urlComponents.url else { return }

        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()

        // Send initial subscription message
        let subscription = CreateMessageRequestBody(content: "Joined")
        send(subscription)

        receiveMessage()
        connectionStatus = .connected
    }


    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self = self else { return }

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
              let message = try? JSONDecoder().decode(Message.self, from: data) else {
            return
        }

        var messages = self.channelMessages[message.channelId] ?? []
        messages.append(message)
        self.channelMessages[message.channelId] = messages
    }

    func sendChannelMessage(_ text: String, to channel: String) {
        let message = SendChatMessageRequest(channelId: channel, content: text)
        send(message)
    }

    func sendDirectMessage(_ text: String, to userId: String) {
        let message = SendChatMessageRequest(channelId: "user:\(userId)", content: text)
        send(message)
    }

    private func send<T: Encodable>(_ message: T) {
        guard let data = try? JSONEncoder().encode(message),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }

        webSocket?.send(.string(jsonString)) { [weak self] error in
            if let error = error {
                print("WebSocket send error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionStatus = .error(error.localizedDescription)
                }

            }
        }
    }

    func disconnect() {
        webSocket?.cancel()
        connectionStatus = .disconnected
    }

    private func reconnect() {
        disconnect()
        // Reconnect with same channels
        if let channels = try? channelMessages.keys.map({ String($0) }) {
            connect(channels: channels)
        }
    }
}
