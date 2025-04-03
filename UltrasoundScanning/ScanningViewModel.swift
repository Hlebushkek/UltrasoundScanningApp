//
//  ScanningViewModel.swift
//  UltrasoundScanning
//
//  Created by Hlib Sobolevskyi on 3/25/25.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class ScanningViewModel {
    var images = [Image]()
    
    let connection: ScanningConnectionProtocol
    
    init(connection: ScanningConnectionProtocol) {
        self.connection = connection
    }
}
