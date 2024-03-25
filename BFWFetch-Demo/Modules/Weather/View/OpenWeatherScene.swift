//
//  OpenWeatherScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 3/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct OpenWeatherScene {}

extension OpenWeatherScene: View {
    var body: some View {
        List {
            NavigationLink("Weather", destination: WeatherScene())
            NavigationLink("Group", destination: GroupScene())
        }
        .navigationTitle("Open Weather")
    }
}

struct OpenWeatherScene_Previews: PreviewProvider {
    static var previews: some View {
        OpenWeatherScene()
    }
}
