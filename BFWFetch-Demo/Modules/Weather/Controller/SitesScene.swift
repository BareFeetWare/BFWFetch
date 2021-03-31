//
//  SitesScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import SwiftUI

struct SitesScene {
    @StateObject var viewModel = ViewModel()
}

extension SitesScene: View {
    var body: some View {
        Group {
            switch viewModel.sitesResult {
            case .none:
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading")
                }
            case .failure(let error):
                Text("Error: \(error.localizedDescription)")
            case .success(let sites):
                List(sites) { site in
                    NavigationLink(
                        destination: SiteScene(site: site)
                    ) {
                        HStack {
                            Text(site.name)
                            Spacer()
                            Text(site.temperatureString)
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.onAppear() }
        .navigationTitle("Open Weather")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SitesScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SitesScene()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
