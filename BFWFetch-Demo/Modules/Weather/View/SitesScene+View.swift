//
//  SitesScene+View.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import SwiftUI

extension SitesScene: View {
    var body: some View {
        List(sites) { site in
            NavigationLink(
                destination: SiteScene(site: site, system: system)
            ) {
                DetailRow(site: site, system: system)
            }
        }
        .navigationTitle("Open Weather")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SitesScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SitesScene(sites: [.cloudySydney], system: .metric)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
