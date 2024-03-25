//
//  WeatherScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

extension WeatherScene : View {
    var body: some View {
        List {
            HStack {
                Text("City:")
                Spacer()
                TextField("City", text: $city)
                    .frame(width: 200)
            }
            HStack {
                Text("Country Code:")
                Spacer()
                TextField("Country Code", text: $countryCode)
                    .frame(width: 200)
            }
            HStack {
                Text("Unit System:")
                Spacer()
                Picker("Unit System", selection: $system) {
                    ForEach(System.allCases) { system in
                        Text(system.title)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            AsyncNavigationLink(
                destination: siteScene,
                isActive: $isActiveLinkedScene,
                isInProgress: $isInProgressFetch,
                action: onTapFetch
            ) {
                Text("Fetch Weather")
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .alert(error: $presentedError)
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
