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
    @State private var token: String?
    @State private var error: Error?
    
    var body: some View
    {
        VStack {
            if let token = token {
                Text("Token: \(token)")
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
