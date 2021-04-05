//
//  WeatherScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct WeatherScene {
    @StateObject var viewModel = ViewModel()
}

extension WeatherScene : View {
    var body: some View {
        List {
            HStack {
                Text("City:")
                Spacer()
                TextField("City", text: $viewModel.city)
                    .frame(width: 200)
            }
            HStack {
                Text("Country Code:")
                Spacer()
                TextField("Country Code", text: $viewModel.countryCode)
                    .frame(width: 200)
            }
            AsyncNavigationLink(
                destination: viewModel.site.map { SiteScene(site: $0) },
                isActive: $viewModel.isActiveWeather,
                isInProgress: $viewModel.isInProgressWeather,
                action: viewModel.fetchWeather
            ) {
                Text("Fetch Weather")
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .alert(item: $viewModel.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message))
        }
        .navigationTitle("Weather")
    }
}

struct WeatherScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeatherScene()
        }
    }
}
