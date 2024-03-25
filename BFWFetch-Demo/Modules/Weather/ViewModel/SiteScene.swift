//
//  SiteScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 6/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct SiteScene {
    let list: Plan.List
    
    init(site: Site, system: System) {
        self.list = .init(site: site, system: system)
    }
}

private extension Plan.List {
    
    init(
        site: Site,
        system: System
    ) {
        self.init(
            sections: [
                .init(
                    title: "City",
                    cells: [
                        .detail(
                            title: "Name",
                            trailing: site.name
                        ),
                    ]
                ),
                .init(
                    title: "Overview",
                    cells: [
                        .detail(
                            title: "Summary",
                            trailing: site.summary
                        ),
                        .detail(
                            title: "Description",
                            trailing: site.description
                        ),
                    ]
                ),
                .init(
                    title: "Temperature",
                    cells: [
                        .detail(
                            title: "Now",
                            trailing: site.temperatureString(system: system)
                        ),
                        .detail(
                            title: "Minimum",
                            trailing: site.minimumTemperatureString(system: system)
                        ),
                        .detail(
                            title: "Maximum",
                            trailing: site.maximumTemperatureString(system: system)
                        ),
                    ]
                ),
                .init(
                    title: "Pressure & Humidity",
                    cells: [
                        .detail(
                            title: "Pressure",
                            trailing: site.pressureString
                        ),
                        .detail(
                            title: "Humidity",
                            trailing: site.humidityString
                        ),
                    ]
                ),
                .init(
                    title: "Wind",
                    cells: [
                        .detail(
                            title: "Speed",
                            trailing: site.windSpeedString(system: system)
                        ),
                        .detail(
                            title: "Direction",
                            trailing: site.windDirectionString
                        ),
                    ]
                )
            ]
        )
    }
}
