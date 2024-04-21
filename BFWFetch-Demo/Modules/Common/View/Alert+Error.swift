//
//  Alert+Error.swift
//  BFWViews
//
//  Created by Tom Brodhurst-Hill on 6/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

// Extracted from BFWViews: https://bitbucket.org/barefeetware/bfwviews/

import SwiftUI

public extension View {
    func alert(error: Binding<Error?>) -> some View {
        alert(isPresented: error.isPresented) {
            Alert(error: error.wrappedValue)
        }
    }
}

public extension Alert {
    init(error: Error?) {
        self.init(
            title: Text("Error"),
            message: error.map {
                Text($0.message)
            }
        )
    }
}

private extension Error {
    
    var message: String {
        (self as? DecodingError)?.debugDescription
        ?? localizedDescription
    }
    
}

private extension DecodingError {
    
    var context: Context? {
        switch self {
        case let .typeMismatch(_, context):
            context
        case let .valueNotFound(_, context):
            context
        case let .keyNotFound(_, context):
            context
        case let .dataCorrupted(context):
            context
        @unknown default:
            nil
        }
    }
    
    var debugDescription: String? {
        guard let context else { return nil }
        let codingPath = context.codingPath.map { $0.stringValue }
        let labeledCodingPath = "codingPath: " + codingPath.joined(separator: ".")
        return [labeledCodingPath, context.debugDescription]
            .joined(separator: "\n")
    }
    
}

private extension Binding where Value == Optional<Error> {
    var isPresented: Binding<Bool> {
        .init {
            wrappedValue != nil
        } set: {
            if !$0 {
                wrappedValue = nil
            }
        }
    }
}

struct Alert_Error_Previews: PreviewProvider {
    
    struct Preview: View {
        @State private var error: Error?
        
        var body: some View {
            List {
                Button("Show alert with error") {
                    error = NSError(domain: "com.test", code: 0, userInfo: nil)
                }
                .alert(error: $error)
            }
            .navigationTitle("Alert error")
        }
    }
    
    static var previews: some View {
        NavigationView {
            Preview()
        }
    }
}
