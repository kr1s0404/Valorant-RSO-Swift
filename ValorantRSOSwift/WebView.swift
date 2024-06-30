//
//  WebView.swift
//  ValorantRSOSwift
//
//  Created by Kris on 6/30/24.
//

import SwiftUI
import WebKit

// WebView to handle the authentication flow
struct WebView: UIViewRepresentable
{
    let url: URL
    let onAuthCompletion: (Result<AccessToken, Error>) -> Void
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        // Navigation policy decision handler
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            // Check if the URL is the redirect URL containing the access token
            if url.absoluteString.starts(with: "https://playvalorant.com/") {
                do {
                    let token = try extractToken(from: url)
                    parent.onAuthCompletion(.success(token))
                } catch {
                    parent.onAuthCompletion(.failure(error))
                }
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
        
        // Extract token from the URL fragment
        private func extractToken(from url: URL) throws -> AccessToken {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let fragment = components.fragment else {
                fatalError()
            }
            
            let params = fragment.split(separator: "&").map { $0.split(separator: "=") }
            var values: [String: String] = [:]
            
            for param in params {
                if param.count == 2 {
                    values[String(param[0])] = String(param[1])
                }
            }
            
            guard
                let type = values["token_type"],
                let token = values["access_token"],
                let idToken = values["id_token"],
                let duration = values["expires_in"].flatMap(Int.init)
            else {
                fatalError()
            }
            
            return .init(
                type: type,
                token: token,
                idToken: idToken,
                expiration: .init(timeIntervalSinceNow: .init(duration) - 30)
            )
        }
    }
    
    // Create Coordinator instance
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // Create WKWebView instance
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    // Update WKWebView instance
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
