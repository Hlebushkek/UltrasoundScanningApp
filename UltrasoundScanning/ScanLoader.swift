//
//  ScanLoader.swift
//  UltrasoundScanning
//
//  Created by Hlib Sobolevskyi on 3/30/25.
//

import SwiftUI

struct AssignRequest: Codable {
    let patient: UUID
}

@MainActor
@Observable
final class FileDownloader: NSObject {
    var progress: Float = 0.0
    var downloadedFileURL: URL?
    
    private let session: String
    private let client: UUID

    @ObservationIgnored private var downloadTask: URLSessionDownloadTask? = nil
    @ObservationIgnored private var urlSession: URLSession? = nil

    init(session: String, client: UUID) {
        self.session = session
        self.client = client
        
        super.init()
        
        let config = URLSessionConfiguration.default
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    func download() {
        downloadTask?.cancel()
        
        let url = Config.apiUrl.appending(components: "scan", self.session, self.client.uuidString.lowercased())
        let request = URLRequest(url: url)
        
        downloadTask = urlSession?.downloadTask(with: request)
        downloadTask?.resume()
    }
    
    func finilize(id: UUID) {
        let assign = AssignRequest(patient: id)
        let url = Config.apiUrl.appending(components: "scan", self.session)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = try? JSONEncoder().encode(assign)
        
        let task = urlSession?.dataTask(with: request)
        task?.resume()
    }
}

extension FileDownloader: URLSessionDownloadDelegate {
    nonisolated func urlSession(_ session: URLSession,
                                downloadTask: URLSessionDownloadTask,
                                didWriteData bytesWritten: Int64,
                                totalBytesWritten: Int64,
                                totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }

    nonisolated func urlSession(_ session: URLSession,
                                downloadTask: URLSessionDownloadTask,
                                didFinishDownloadingTo location: URL) {
        // Move the file from the temporary location to a permanent location.
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let response = downloadTask.response else { return }
        
        let destinationURL = documents.appendingPathComponent(response.suggestedFilename ?? location.lastPathComponent)
        
        // Remove any existing file at the destination.
        try? fileManager.removeItem(at: destinationURL)
        
        do {
            try fileManager.moveItem(at: location, to: destinationURL)
            DispatchQueue.main.async {
                self.downloadedFileURL = destinationURL
            }
            print("File downloaded to: \(destinationURL)")
        } catch {
            print("Error moving file: \(error)")
        }
    }
}
