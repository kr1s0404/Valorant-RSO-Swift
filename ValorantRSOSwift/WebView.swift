//
//  WebView.swift
//  ValorantRSOSwift
//
//  Created by Kris on 6/30/24.
//

import SwiftUI
import WebKit

enum AuthError: Error {
    case invalidRedirectURL
    case missingRequiredFields
    case invalidRefreshURL
}

struct WebViewContainer: UIViewRepresentable
{
    let url: URL
    let onFinish: (Result<AccessToken, Error>, [HTTPCookie]) -> Void
    let cookies: [HTTPCookie]?
    
    init(url: URL,
         cookies: [HTTPCookie]? = nil,
         onFinish: @escaping (Result<AccessToken, Error>, [HTTPCookie]) -> Void) {
        self.url = url
        self.onFinish = onFinish
        self.cookies = cookies
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let dataStore = WKWebsiteDataStore.nonPersistent()
        
        if let cookies = cookies {
            for cookie in cookies {
                dataStore.httpCookieStore.setCookie(cookie)
            }
        }
        
        config.websiteDataStore = dataStore
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               url.absoluteString.starts(with: "https://playvalorant.com/") && url.absoluteString.contains("access_token") {
                decisionHandler(.cancel)
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    do {
                        let accessToken = try self.parseAuthRedirect(url: url)
                        self.parent.onFinish(.success(accessToken), cookies)
                    } catch {
                        self.parent.onFinish(.failure(error), cookies)
                    }
                }
            } else {
                decisionHandler(.allow)
            }
        }
        
        func parseAuthRedirect(url: URL) throws -> AccessToken {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let fragment = components.fragment else {
                throw AuthError.invalidRedirectURL
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
                throw AuthError.missingRequiredFields
            }
            
            return AccessToken(
                type: type,
                token: token,
                idToken: idToken,
                expiration: .init(timeIntervalSinceNow: .init(duration) - 30)
            )
        }
    }
}
