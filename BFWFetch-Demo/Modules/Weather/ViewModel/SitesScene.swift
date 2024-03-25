//
//  SitesScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 25/3/2024.
//  Copyright © 2024 BareFeetWare. All rights reserved.
//

import Foundation

struct SitesScene {
    let sites: [Site]
    let system: System
}

extension DetailRow {
    
    init(site: Site, system: System) {
        self.init(
            title: site.name,
            trailing: site.temperatureString(system: system)
        )
    }
    
}
