//
//  Account.swift
//  ValorantRSOSwift
//
//  Created by Kris on 7/26/24.
//

import SwiftUI

struct Account: Identifiable, Codable {
    let id: UUID
    let username: String
    var accessToken: AccessToken
    var codableCookies: [CodableCookie]
    
    var cookies: [HTTPCookie] {
        codableCookies.compactMap { $0.toHTTPCookie() }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, accessToken, codableCookies
    }
    
    init(id: UUID, username: String, accessToken: AccessToken, cookies: [HTTPCookie]) {
        self.id = id
        self.username = username
        self.accessToken = accessToken
        self.codableCookies = cookies.map(CodableCookie.init)
    }
}

struct CodableCookie: Codable {
    let name: String
    let value: String
    let domain: String
    let path: String
    
    init(from cookie: HTTPCookie) {
        self.name = cookie.name
        self.value = cookie.value
        self.domain = cookie.domain
        self.path = cookie.path
    }
    
    func toHTTPCookie() -> HTTPCookie? {
        return HTTPCookie(properties: [
            .name: name,
            .value: value,
            .domain: domain,
            .path: path
        ])
    }
}
