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
            message: error.map { Text(String(describing: $0)) }
        )
    }
}

struct Alert_Error_Previews: PreviewProvider {
    
    private enum Error: Swift.Error {
        case test
    }
    
    static var previews: some View {
        Text("Text")
            .alert(isPresented: .constant(true)) {
                Alert(error: Error.test)
            }
    }
}
