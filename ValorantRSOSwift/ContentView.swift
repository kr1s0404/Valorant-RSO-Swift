//
//  ContentView.swift
//  ValorantRSOSwift
//
//  Created by Kris on 6/30/24.
//

import SwiftUI

struct ContentView: View
{
    @StateObject private var accountManager = AccountManager()
    @StateObject private var authViewModel: AuthViewModel
    
    init() {
        let accountManager = AccountManager()
        _accountManager = StateObject(wrappedValue: accountManager)
        _authViewModel = StateObject(wrappedValue: AuthViewModel(accountManager: accountManager))
    }
    
    var body: some View
    {
        NavigationView 
        {
            VStack
            {
                List {
                    Section {
                        ForEach(accountManager.accounts) { account in
                            Button(action: {
                                accountManager.switchToAccount(account)
                                Task {
                                    authViewModel.username = account.username
                                    await authViewModel.checkAndRefreshTokenIfNeeded(for: account)
                                }
                            }) {
                                HStack {
                                    Text(account.username)
                                    Spacer()
                                    if account.id == accountManager.currentAccount?.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Logout") {
                                    authViewModel.logout(account: account)
                                }
                                .tint(.red)
                            }
                        }
                    }
                    
                    Section {
                        if let currentAccount = accountManager.currentAccount {
                            Text(currentAccount.accessToken.token)
                                .lineLimit(1)
                            Text(currentAccount.accessToken.idToken)
                                .lineLimit(1)
                            Text(currentAccount.accessToken.expiration.description)
                        }
                    }
                    
                }
                
                TextField("username", text: $authViewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button("Add Account") {
                    authViewModel.startNewAccountAuth()
                }
                .disabled(authViewModel.username.isEmpty)
            }
            .navigationTitle("Valorant Accounts")
            .sheet(isPresented: $authViewModel.isShowingWebView) {
                WebViewContainer(
                    url: RiotURL.rsoURL,
                    cookies: authViewModel.isAddingNewAccount ? nil : accountManager.currentAccount?.cookies,
                    onFinish: authViewModel.handleAuthResult
                )
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

#Preview {
    ContentView()
}
