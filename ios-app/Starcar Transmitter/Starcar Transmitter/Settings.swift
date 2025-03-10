//
//  Settings.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/21/25.
//

import Foundation

class Settings: ObservableObject, @unchecked Sendable{
    static let instance = Settings()
    
    @Published var devServer = false
    @Published var mockDevice = false
    
    func onDevServerChange(){
        DataController.instance.reloadSocketManager()
        APIKeyManager.instance.reloadKey()
    }
    
    func getServerURL() -> URL{
        if devServer{
            return config.devServerURL
        }
        
        return config.prodServerURL
    }
    
    func getServerDomain() -> String{
        if devServer{
            return config.devServerDomain
        }
        
        return config.prodServerDomain
    }
}
