//
//  OAuthView.swift
//  BFWFetch
//
//  Created by Tom Brodhurst-Hill on 21/8/2025.
//  Copyright © 2025 BareFeetWare. All rights reserved.
//

import SwiftUI
import WebKit

public struct OAuthView {
    let request: URLRequest
    let receiveCode: (_ code: String) -> Void
    
    public init(
        request: URLRequest,
        receiveCode: @escaping (_ code: String) -> Void
    ) {
        self.request = request
        self.receiveCode = receiveCode
    }
}

// MARK: - Functions

extension OAuthView {
    
    var redirectURL: URL? {
        request.url?
            .queryItemValue(name: "redirect_uri")
            .flatMap { URL(string: $0) }
    }
    
    func code(
        navigationActionRequest request: URLRequest
    ) -> String? {
        guard let url = request.url,
              let redirectURL,
              url.absoluteString.starts(with: redirectURL.absoluteString)
        else { return nil }
        return request.url?
            .queryItemValue(name: "code")
    }
    
    func policy(
        navigationAction: WKNavigationAction,
        grant: OAuth.Grant
    ) -> WKNavigationActionPolicy {
        guard let code = code(navigationActionRequest: navigationAction.request)
        else { return .allow }
        receiveCode(code)
        return .cancel
    }
    
}

extension OAuthView: View {
    public var body: some View {
        WebView(
            title: .constant("OAuth"),
            urlRequest: request,
            policyForNavigationAction: {
                policy(
                    navigationAction: $0,
                    grant: .authorizationCode
                )
            }
        )
    }
}
