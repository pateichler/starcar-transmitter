//
//  APIKeyManager.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/27/25.
//

import Foundation

enum KeychainError: Error {
    case unexpectedData
    case unhandledError(status: OSStatus)
}


class APIKeyManager : ObservableObject, @unchecked Sendable {
    static let instance = APIKeyManager()
    
    @Published private(set) var apiKey: String?
    
    private let accountAttr = "API-Key"
    
    init(){
        do{
            try self.loadKey()
        }catch KeychainError.unhandledError(let status){
            if let errMsg = SecCopyErrorMessageString(status, nil) as? String{
                print(errMsg)
            }
            print("Error: Could not retrieve API key: \(status)")
        }catch KeychainError.unexpectedData{
            print("Error: Keychain contains incorrect data!")
        }catch{
            print("Unexpected error: \(error)")
        }
    }
    
    private func loadKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: accountAttr,
            kSecAttrServer as String: config.serverDomain,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let apiData = item as? Data,
            let apiKey = String(data: apiData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedData
        }
        
//        guard let existingItem = item as? [String : Any],
//            let apiData = existingItem[kSecValueData as String] as? Data,
//            let apiKey = String(data: apiData, encoding: String.Encoding.utf8)
//        else {
//            throw KeychainError.unexpectedData
//        }
        
        self.apiKey = apiKey
    }
    
    func addKey(apiKey: String) throws {
        print("Adding key")
        let data = apiKey.data(using: String.Encoding.utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: accountAttr,
            kSecAttrServer as String: config.serverDomain,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        self.apiKey = apiKey
    }
    
//    func saveKey(apiKey: String) throws {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrServer as String: "www.example.com"
//        ]
//            
//        let data = apiKey.data(using: String.Encoding.utf8)!
//        let attributes: [String: Any] = [kSecValueData as String: data]
//        
//        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
//        
//        // Add new key if one doesn't exist
//        guard status != errSecItemNotFound else { return try addKey(apiKey: apiKey) }
//        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
//        
//        self.apiKey = apiKey
//    }
    
    func deleteKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: accountAttr,
            kSecAttrServer as String: config.serverDomain
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        
        apiKey = nil
    }
    
    func hasKey() -> Bool{
        return self.apiKey != nil
    }
}
