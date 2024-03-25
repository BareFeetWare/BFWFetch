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
                Text($0.localizedDescription)
            }
        )
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
