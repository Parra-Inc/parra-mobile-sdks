//
//  ChatView.swift
//  WebSocketsIosApp
//
//  Created by Ian MacCallum on 1/28/25.
//

import SwiftUI

// 0. Update entitlements to support quantities
// 1. Shared chat data storage
//     * supports fetching and retreiving conversations by type
// 2. Widget for a specific conversation
//     * All specifying a required entitlement
// 3. Widget for list of conversations

// public struct ChatTab: View {
//    let authToken: String
//    @Binding var navigationPath: NavigationPath
//
//    public var body: some View {
//        ChatView(authToken: authToken)
//    }
//
//    func loadChannels() async throws {
//
//    }
// }

public struct ChatView: View {
    // MARK: - Lifecycle

    public init(authToken: String) {
        self.authToken = authToken
        _webSocketManager = State(wrappedValue: WebSocketManager(authToken: authToken))
    }

    // MARK: - Public

    public var body: some View {
        VStack {
            ConnectionStatusView(status: webSocketManager.connectionStatus)

            ScrollView {
//                LazyVStack(alignment: .leading, spacing: 12) {
//                    ForEach(webSocketManager.channelMessages) { message in
//                        MessageBubble(message: message)
//                    }
//                }
//                .padding()
            }

            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(webSocketManager.connectionStatus != .connected)

                Button(action: sendMessage) {
                    Text("Send")
                }
                .disabled(webSocketManager.connectionStatus != .connected)
            }
            .padding()
        }
        .onAppear {
            webSocketManager.connect(channels: ["test"])
        }
        .onDisappear {
            webSocketManager.disconnect()
        }
    }

    // MARK: - Internal

    let authToken: String

    // MARK: - Private

    @State private var webSocketManager: WebSocketManager
    @State private var messageText = ""

    private func sendMessage() {
        guard !messageText.isEmpty else {
            return
        }
        webSocketManager.sendDirectMessage(messageText, to: "channel")
        messageText = ""
    }
}

struct ConnectionStatusView: View {
    // MARK: - Internal

    let status: WebSocketManager.ConnectionStatus

    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(statusText)
                .font(.caption)
        }
        .padding(.top, 8)
    }

    // MARK: - Private

    private var statusColor: Color {
        switch status {
        case .connected:
            return .green
        case .disconnected:
            return .red
        case .error:
            return .orange
        }
    }

    private var statusText: String {
        switch status {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .error(let error):
            return "Error: \(error)"
        }
    }
}

#Preview {
    ChatView(authToken: "abcd")
}
