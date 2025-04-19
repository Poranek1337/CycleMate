//
//  UserStorageProtocol.swift
//  CycleMate
//
//  Created by Poranek on 14/04/2025.
//

import Foundation

protocol UserStorageProtocol {
    func saveToken(_ token: String)
    func getToken() -> String?
    func removeToken()
    func saveUserData(_ user: User)
    func loadUserData() -> User?
    func removeUserData()
}
