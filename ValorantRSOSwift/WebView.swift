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
    let onAuthCompletion: (Result<String, Error>) -> Void
    
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
                if let token = extractToken(from: url) {
                    parent.onAuthCompletion(.success(token))
                } else {
                    parent.onAuthCompletion(.failure(NSError(domain: "",
                                                             code: 0,
                                                             userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
                }
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
        
        // Extract token from the URL fragment
        private func extractToken(from url: URL) -> String? {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let fragment = components.fragment else {
                return nil
            }
            
            let params = fragment.split(separator: "&").map { $0.split(separator: "=") }
            for param in params {
                if param[0] == "access_token" {
                    return String(param[1])
                }
            }
            return nil
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
