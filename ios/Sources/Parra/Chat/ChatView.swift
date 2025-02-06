//
//  ChatView.swift
//  WebSocketsIosApp
//
//  Created by Ian MacCallum on 1/28/25.
//

import SwiftUI
import Parra

//public struct ChatTab: View {
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
//}
// AuthenticatedChatView.swift
public struct ChatView: View {
    let authToken: String
    @StateObject private var webSocketManager: WebSocketManager
    @State private var messageText = ""

    public init(authToken: String) {

        self.authToken = authToken
        _webSocketManager = StateObject(wrappedValue: WebSocketManager(authToken: authToken))
    }

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

    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        webSocketManager.sendDirectMessage(messageText, to: "channel")
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let user = message.user {
                Text(user.id)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Text(message.content)
                .padding(10)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)

            Text(message.createdAt)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

struct ConnectionStatusView: View {
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
