//
//  GroupScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct GroupScene {
    @State var siteIDs: String = "4163971,2147714,2174003"
    @State var system: System = .metric
}

extension GroupScene {
    
    func sitesScene() async throws -> SitesScene {
        let request = try API.Request.Group
            .request(siteIDs: siteIDs, system: system)
        let wrapper = try await API.Request.Group
            .Response(request: request)
        let sites = wrapper.array
        return SitesScene(sites: sites, system: system)
    }
    
}
