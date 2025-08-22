//
//  WebView.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 24/9/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

// Extracted from BFWViews: https://bitbucket.org/barefeetware/bfwviews/

import SwiftUI
import WebKit

internal struct WebView {
    let title: Binding<String>
    let urlRequest: URLRequest
    var loadStatusChanged: ((Bool, Error?) -> Void)?
    let policyForNavigationAction: ((_ navigationAction: WKNavigationAction) -> WKNavigationActionPolicy)?
    
    init(
        title: Binding<String>,
        urlRequest: URLRequest,
        loadStatusChanged: ((Bool, Error?) -> Void)? = nil,
        policyForNavigationAction: ((_ navigationAction: WKNavigationAction) -> WKNavigationActionPolicy)? = nil
    ) {
        self.title = title
        self.urlRequest = urlRequest
        self.loadStatusChanged = loadStatusChanged
        self.policyForNavigationAction = policyForNavigationAction
    }
}

// MARK: - Functions

extension WebView {
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
}

// MARK: - Views

extension WebView: UIViewRepresentable {
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.load(urlRequest)
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // you can access environment via context.environment here
        // Note that this method will be called A LOT
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(
            _ webView: WKWebView,
            didCommit navigation: WKNavigation!
        ) {
            parent.loadStatusChanged?(true, nil)
        }

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            parent.title.wrappedValue = webView.title ?? ""
            parent.loadStatusChanged?(false, nil)
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.loadStatusChanged?(false, error)
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            let policy = parent.policyForNavigationAction?(navigationAction)
            ?? .allow
            decisionHandler(policy)
        }
        
    }
}

// MARK: - Previews

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(
            title: .constant("Title"),
            urlRequest: URLRequest(url: URL(string: "https://www.barefeetware.com")!),
            loadStatusChanged: nil
        )
    }
}
