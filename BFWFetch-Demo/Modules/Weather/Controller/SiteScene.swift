//
//  SiteScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 2/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import SwiftUI

struct SiteScene {
    let site: Site
}
    
extension SiteScene: View {
    var body: some View {
        List {
            Section(header: Text("City")) {
                LeftDetailCell(
                    text: Text("Name:"),
                    detailText: Text(site.name)
                )
            }
            Section(header: Text("Overview")) {
                LeftDetailCell(
                    text: Text("Summary:"),
                    detailText: site.summary.map { Text($0) }
                )
                LeftDetailCell(
                    text: Text("Description:"),
                    detailText: site.description.map { Text($0) }
                )
            }
            Section(header: Text("Temperature")) {
                LeftDetailCell(
                    text: Text("Now:"),
                    detailText: Text(site.temperatureString)
                )
                LeftDetailCell(
                    text: Text("Minimum:"),
                    detailText: Text(site.minimumTemperatureString)
                )
                LeftDetailCell(
                    text: Text("Maximum:"),
                    detailText: Text(site.maximumTemperatureString)
                )
            }
            Section(header: Text("Pressure & Humidity")) {
                LeftDetailCell(
                    text: Text("Pressure:"),
                    detailText: Text(site.pressureString)
                )
                LeftDetailCell(
                    text: Text("Humidity:"),
                    detailText: Text(site.humidityString)
                )
            }
            Section(header: Text("Wind")) {
                LeftDetailCell(
                    text: Text("Speed:"),
                    detailText: Text(site.windSpeedString)
                )
                LeftDetailCell(
                    text: Text("Direction:"),
                    detailText: Text(site.windDirectionString)
                )
            }
        }
    }
}

struct SiteScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SiteScene(site: .cloudySydney)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
