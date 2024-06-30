//
//  AccessToken.swift
//  ValorantRSOSwift
//
//  Created by Kris on 7/1/24.
//

import SwiftUI

struct AccessToken: Codable, Hashable {
    var type: String
    var token: String
    var idToken: String
    var expiration: Date
    
    var encoded: String {
        "\(type) \(token)"
    }
    
    var hasExpired: Bool {
        expiration < .now
    }
}
