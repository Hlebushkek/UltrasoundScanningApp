//
//  ScanningConnection.swift
//  UltrasoundScanning
//
//  Created by Hlib Sobolevskyi on 3/25/25.
//

import Foundation

@MainActor
@Observable
final class ScanningConnection: NSObject {
    let id: UUID
    let session: String
    
    var progress: Int = 0
    var isConnected: Bool = false
    
    @ObservationIgnored private var webSocketTask: URLSessionWebSocketTask?
    
    init(id: UUID = UUID(), session: String) {
        self.id = id
        self.session = session
    }
    
    func connect() {
        guard let url = URL(string: "wss://e91b-206-72-66-94.ngrok-free.app/ws/\(session)/\(id.uuidString.lowercased())") else { return }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.delegate = self
        webSocketTask?.resume()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    deinit {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error receiving message: \(error.localizedDescription))")
            case .success(let message):
                switch message {
                case .string(let text):
                    print(text)
                case .data(let data):
                    print(data)
                    Task { @MainActor in self?.progress += 1 }
                @unknown default:
                    print("Received unknown message")
                }
            }
        }
    }
}

extension ScanningConnection: URLSessionWebSocketDelegate {
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol1: String?) {
        
        Task { @MainActor in
            self.isConnected = true
        }
        
        Task {
            await self.receiveMessage()
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { @MainActor in
            self.isConnected = false
        }
    }
}
