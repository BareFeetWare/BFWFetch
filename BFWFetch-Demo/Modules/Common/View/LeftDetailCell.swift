//
//  LeftDetailCell.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 31/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct LeftDetailCell {
    let text: Text
    let detailText: Text?
}

extension LeftDetailCell: View {
    var body: some View {
            HStack {
                HStack(spacing: 0) {
                    Spacer()
                        .frame(minWidth: 0)
                        .layoutPriority(-1)
                    text
                        .foregroundColor(.secondary)
                }
                .frame(width: 100.0)
                detailText
            }
            .font(.callout)
    }
}

struct LeftDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        LeftDetailCell(
            text: Text("Text:"),
            detailText: Text("Detail Text")
        )
        .previewLayout(.sizeThatFits)
    }
}
