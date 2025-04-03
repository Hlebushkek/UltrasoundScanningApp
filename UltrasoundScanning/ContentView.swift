//
//  ContentView.swift
//  UltrasoundScanning
//
//  Created by Hlib Sobolevskyi on 3/25/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var session: String = ""
    @State private var connection = ScanningConnection(session: "")
    
    var body: some View {
        VStack {
            TextField("Session ID", text: $session)
            
            Button("Connect", action: connect)
        }
        .navigationDestination(isPresented: $connection.isConnected) {
            ScanningView(connection: connection)
        }
    }
    
    private func connect() {
        connection = ScanningConnection(session: session)
        connection.connect()
    }
}

#Preview {
    ContentView()
}
