//
//  GroupScene.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 5/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

struct GroupScene {
    @StateObject var viewModel = ViewModel()
}

extension GroupScene : View {
    var body: some View {
        List {
            HStack {
                Text("Site IDs:")
                Spacer()
                TextField("Site IDs", text: $viewModel.siteIDs)
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
                destination: viewModel.sites.map { SitesScene(sites: $0, system: viewModel.system) },
                isActive: $viewModel.isActiveLinkedScene,
                isInProgress: $viewModel.isInProgressFetch,
                action: viewModel.fetch
            ) {
                Text("API Weather")
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .alert(isPresented: $viewModel.isPresentedAlert) {
            Alert(error: viewModel.error)
        }
        .navigationTitle("Fetch Group")
    }
}

struct GroupScene_Previews: PreviewProvider {
    static var previews: some View {
        GroupScene()
    }
}
