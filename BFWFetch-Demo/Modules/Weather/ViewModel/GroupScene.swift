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
    @State var sites: [Site]?
    @State var isActiveLinkedScene = false
    @State var isInProgressFetch = false
    @State var presentedError: Error?
}

extension GroupScene {
    
    var sitesScene: SitesScene? {
        sites.map { SitesScene(sites: $0, system: system) }
    }
    
    func onTapFetch() {
        Task {
            await fetch()
        }
    }
}

private extension GroupScene {
    
    func fetch() async {
        do {
            let wrapper = try await API.Request.Group.response(siteIDs: siteIDs, system: system)
            let sites = wrapper.array
            self.sites = sites
            self.isActiveLinkedScene = true
        } catch {
            self.presentedError = API.Response.specificError(error)
        }
        self.isInProgressFetch = false
    }
}
