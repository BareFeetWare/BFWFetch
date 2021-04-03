//
//  CompressibleSpacer.swift
//
//  Created by Tom Brodhurst-Hill on 3/11/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import SwiftUI

struct CompressibleSpacer: View {
    var body: some View {
        Spacer()
            .frame(minWidth: 0, minHeight: 0)
            .layoutPriority(-1)
    }
}

struct CompressibleSpacer_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Text("Leading")
            CompressibleSpacer()
            Text("Trailing")
        }
        .previewLayout(.sizeThatFits)
    }
}
