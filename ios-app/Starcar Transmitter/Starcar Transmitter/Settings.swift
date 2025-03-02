//
//  Settings.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/21/25.
//

import Foundation

class Settings: ObservableObject, @unchecked Sendable{
    static let instance = Settings()
    
    @Published var mockDevice = false    
}
