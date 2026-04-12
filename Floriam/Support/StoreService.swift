//
//  StoreService.swift
//  Floriam
//
//  Created by Ringo Wathelet on 2026/04/11.
//
import Foundation
import SwiftUI


class StoreService {
    
    static func getKey() -> String? {
        return KeychainInterface.getPassword()
    }
    
    static func setKey(key: String) {
        do {
            try KeychainInterface.savePassword(key)
        } catch {
            print("in StoreService setKey(), KeychainInterface.savePassword: \(error)")
        }
    }
    
    static func updateKey(key: String) {
        do {
            try KeychainInterface.updatePassword(with: key)
        } catch {
            print("in StoreService updateKey(), KeychainInterface.updatePassword: \(error)")
        }
    }

}
