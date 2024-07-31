//
//  AuthViewModel.swift
//  ValorantRSOSwift
//
//  Created by Kris on 7/26/24.
//

import SwiftUI
import WebKit

final class AuthViewModel: ObservableObject
{
    @Published var isShowingWebView = false
    @Published var isAuthenticated = false
    @Published var isAddingNewAccount = false
    @Published var isRefreshing = false
    
    @Published var username: String = ""
    
    var accountManager: AccountManager
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        self.isAuthenticated = !accountManager.accounts.isEmpty
    }
    
    func startAuth() {
        isShowingWebView = true
        isAddingNewAccount = false
    }
    
    func startNewAccountAuth() {
        isShowingWebView = true
        isAddingNewAccount = true
    }
    
    func handleAuthResult(_ result: Result<AccessToken, Error>, cookies: [HTTPCookie]) {
        switch result {
            case .success(let accessToken):
                print("Auth successful: \(accessToken)")
                
                let account = Account(
                    id: UUID(),
                    username: username,
                    accessToken: accessToken,
                    cookies: cookies
                )
                accountManager.addOrUpdateAccount(account)
                isAuthenticated = true
                username = ""
            case .failure(let error):
                print("Auth failed: \(error.localizedDescription)")
                isAuthenticated = false
                username = ""
        }
        isShowingWebView = false
        isAddingNewAccount = false
    }
    
    func logout(account: Account) {
        accountManager.removeAccount(account)
        isAuthenticated = !accountManager.accounts.isEmpty
    }
    
    func checkAndRefreshTokenIfNeeded(for account: Account) async {
        if account.accessToken.hasExpired {
            await refreshToken(for: account)
        }
    }
    
    private func refreshToken(for account: Account) async {
        isShowingWebView = true
    }
}
