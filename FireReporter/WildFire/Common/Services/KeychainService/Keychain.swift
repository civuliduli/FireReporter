//
//  Keychain.swift
//  FireReporter
//
//  Created by Abdulla Civuli on 5.11.23.
//

import Foundation
import Security
import UIKit

class KeychainService {
    
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
    }
    
    func generateUUID() -> String {
        return UUID().uuidString
    }

    
    func saveUUIDToKeychain(uuid: String) {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "YourAppServiceName", // Change this to a unique name for your app
            kSecAttrAccount as String: "UUID",
            kSecValueData as String: uuid.data(using: .utf8)!
        ]

        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        if status != errSecSuccess {
            // Handle the error, e.g., display an error message
            print("Error saving UUID to Keychain: \(status)")
        }
    }

    
    func retrieveUUIDFromKeychain() -> String? {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "YourAppServiceName", // Same unique name as used when saving
            kSecAttrAccount as String: "UUID",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQuery as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data, let uuid = String(data: data, encoding: .utf8) {
            return uuid
        } else {
            // Handle the error, e.g., UUID not found
            return nil
        }
    }

    
    func deleteFromKeychain() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "YourUniqueIdentifier", // Replace with the account identifier you want to delete
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }

        if status == errSecItemNotFound {
            print("Keychain item not found")
        } else {
            print("Keychain item deleted")
        }
    }

}

