//
//  SiteScene+View.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 2/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import SwiftUI

extension SiteScene: View {
    var body: some View {
        list
    }
}

struct SiteScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SiteScene(site: .cloudySydney, system: .metric)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
