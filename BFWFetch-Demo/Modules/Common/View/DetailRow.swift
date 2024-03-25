//
//  DetailRow.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 31/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct DetailRow {
    let title: String
    let trailing: String?
}

extension DetailRow: View {
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Spacer()
                    .frame(minWidth: 0)
                    .layoutPriority(-1)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100.0)
            trailing.map { Text($0) }
        }
        .font(.callout)
    }
}

struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(
            title: "Text",
            trailing: "Detail Text"
        )
        .previewLayout(.sizeThatFits)
    }
}
