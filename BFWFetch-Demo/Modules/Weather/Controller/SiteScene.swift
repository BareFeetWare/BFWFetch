//
//  SiteScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 2/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import SwiftUI

struct SiteScene {
    var viewModel: ViewModel
}
    
extension SiteScene: View {
    var body: some View {
        List {
            Section(header: Text("City")) {
                LeftDetailCell(
                    text: Text("Name:"),
                    detailText: Text(viewModel.name)
                )
            }
            Section(header: Text("Overview")) {
                LeftDetailCell(
                    text: Text("Summary:"),
                    detailText: viewModel.summary.map { Text($0) }
                )
                LeftDetailCell(
                    text: Text("Description:"),
                    detailText: viewModel.description.map { Text($0) }
                )
            }
            Section(header: Text("Temperature")) {
                LeftDetailCell(
                    text: Text("Now:"),
                    detailText: Text(viewModel.temperatureString)
                )
                LeftDetailCell(
                    text: Text("Minimum:"),
                    detailText: Text(viewModel.minimumTemperatureString)
                )
                LeftDetailCell(
                    text: Text("Maximum:"),
                    detailText: Text(viewModel.maximumTemperatureString)
                )
            }
            Section(header: Text("Pressure & Humidity")) {
                LeftDetailCell(
                    text: Text("Pressure:"),
                    detailText: Text(viewModel.pressureString)
                )
                LeftDetailCell(
                    text: Text("Humidity:"),
                    detailText: Text(viewModel.humidityString)
                )
            }
            Section(header: Text("Wind")) {
                LeftDetailCell(
                    text: Text("Speed:"),
                    detailText: Text(viewModel.windSpeedString)
                )
                LeftDetailCell(
                    text: Text("Direction:"),
                    detailText: Text(viewModel.windDirectionString)
                )
            }
        }
    }
}

struct SiteScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SiteScene(
                viewModel: .init(site: .cloudySydney, system: .metric)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
