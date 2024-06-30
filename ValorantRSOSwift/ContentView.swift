//
//  ContentView.swift
//  ValorantRSOSwift
//
//  Created by Kris on 6/30/24.
//

import SwiftUI

struct ContentView: View
{
    @State private var showWebView = false
    @State private var token: AccessToken?
    @State private var error: Error?
    
    var body: some View
    {
        VStack {
            if let token = token {
                VStack(spacing: 10)
                {
                    Text("Token type: \(token.type)")
                    Text("Token: \(token.token)")
                    Text("idToken: \(token.idToken)")
                    Text("expiration: \(token.expiration)")
                }
                .lineLimit(3)
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
            } else {
                Button("Sign In") {
                    showWebView.toggle()
                }
            }
        }
        .sheet(isPresented: $showWebView) {
            WebView(url: RiotURL.rsoURL) { result in
                showWebView = false
                switch result {
                    case .success(let token):
                        self.token = token
                    case .failure(let error):
                        self.error = error
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
