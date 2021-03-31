//
//  RootScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 31/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct RootScene: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Open Weather", destination: SitesScene())
            }
            .navigationTitle("BFWFetch Demo")
        }
    }
}

struct RootScene_Previews: PreviewProvider {
    static var previews: some View {
        RootScene()
    }
}
