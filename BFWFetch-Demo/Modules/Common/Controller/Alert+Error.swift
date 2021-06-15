//
//  Alert+Error.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 6/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

extension Alert {
    init(error: Error?) {
        self.init(
            title: Text("Error"),
            message: error.map { Text($0.localizedDescription) }
        )
    }
}

struct Alert_Error_Previews: PreviewProvider {
    
    private enum Error: LocalizedError {
        case test
        
        var errorDescription: String? {
            "This is just a test error."
        }
    }
    
    static var previews: some View {
        Text("Text")
            .alert(isPresented: .constant(true)) {
                Alert(error: Error.test)
            }
    }
}
