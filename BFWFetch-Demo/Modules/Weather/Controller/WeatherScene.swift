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
            HStack {
                Text("Unit System:")
                Spacer()
                Picker("Unit System", selection: $viewModel.system) {
                    ForEach(System.allCases) { system in
                        Text(system.title)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            AsyncNavigationLink(
                destination: viewModel.siteViewModel.map {
                    SiteScene(viewModel: $0)
                },
                isActive: $viewModel.isActiveLinkedScene,
                isInProgress: $viewModel.isInProgressFetch,
                action: viewModel.fetch
            ) {
                Text("Fetch Weather")
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .alert(isPresented: $viewModel.isPresentedAlert) {
            Alert(error: viewModel.error)
        }
        .navigationTitle("API Weather")
    }
}

struct WeatherScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WeatherScene()
        }
    }
}
