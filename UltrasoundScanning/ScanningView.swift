//
//  ScanningView.swift
//  UltrasoundScanning
//
//  Created by Hlib Sobolevskyi on 3/25/25.
//

import SwiftUI

struct ScanningView: View {
    var connection: ScanningConnection
    @State private var fileLoader: FileDownloader
    
    @State private var image: CGImage?
    @State private var error: String?
    
    @State private var isFinalizing = false
    @State private var patient: String = ""
    
    init(connection: ScanningConnection) {
        self.connection = connection
        self.fileLoader = FileDownloader(session: connection.session, client: connection.id)
    }
    
    var body: some View {
        VStack {
            if let error {
                Text(error).foregroundStyle(.red)
            }
            
            if let image {
                Image(decorative: image, scale: 1.0, orientation: .up)
            } else {
                Text("No image yet")
            }
            
            Text(fileLoader.downloadedFileURL?.path ?? "No file downloaded")
        }
        .onChange(of: connection.progress) { _, _ in
            fileLoader.download()
        }
        .onChange(of: fileLoader.downloadedFileURL) { _, newValue in
            guard let newValue else { return }
            
            process(hdf5: newValue)
        }
        .alert("Enter patient UUID", isPresented: $isFinalizing) {
            TextField("Patient UUID", text: $patient)
            Button("OK", action: finalize)
                .disabled(UUID(uuidString: patient) == nil)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Finalize") { isFinalizing.toggle() }
            }
        }
    }
    
    private func process(hdf5: URL) {
        let processor = ImageProcessor(path: hdf5.path())
        
        guard let iqData = try? processor.processRf(),
              let image = try? processor.processIq(data: iqData) else {
            error = "Failed to process file"
            return
        }
        
        print(image)
        
        guard let imageSource = CGImageSourceCreateWithData(image.data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            error = "Failed to create native image"
            return
        }
        
        self.image = cgImage
    }
    
    private func finalize() {
        fileLoader.finilize(id: UUID(uuidString: patient)!)
        connection.disconnect()
    }
}

#Preview {
    ScanningView(connection: ScanningConnection(session: "mock_session"))
}
