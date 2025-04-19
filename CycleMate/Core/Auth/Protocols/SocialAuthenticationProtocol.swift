//
//  SocialAuthenticationProtocol.swift
//  CycleMate
//
//  Created by Poranek on 14/04/2025.
//

import UIKit

protocol SocialAuthenticationProtocol {
    func signIn(presenting viewController: UIViewController) async throws -> User
}
