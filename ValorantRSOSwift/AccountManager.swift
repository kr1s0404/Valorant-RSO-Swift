//
//  AccountManager.swift
//  ValorantRSOSwift
//
//  Created by Kris on 7/26/24.
//

import SwiftUI

final class AccountManager: ObservableObject
{
    @Published var accounts: [Account] = []
    @Published var currentAccount: Account?
    
    private let accountsKey = "savedAccounts"
    
    init() {
        loadAccounts()
    }
    
    func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: accountsKey),
           let decodedAccounts = try? JSONDecoder().decode([Account].self, from: data) {
            accounts = decodedAccounts
            currentAccount = accounts.first
        }
    }
    
    func saveAccounts() {
        if let encodedData = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encodedData, forKey: accountsKey)
        }
    }
    
    func addOrUpdateAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.username == account.username }) {
            accounts[index] = account
            if currentAccount?.username == account.username {
                currentAccount = account
            }
        } else {
            accounts.append(account)
            if currentAccount == nil {
                currentAccount = account
            }
        }
        saveAccounts()
    }
    
    func switchToAccount(_ account: Account) {
        currentAccount = account
    }
    
    func removeAccount(_ account: Account) {
        accounts.removeAll { $0.username == account.username }
        if currentAccount?.id == account.id {
            currentAccount = accounts.first
        }
        saveAccounts()
    }
}
