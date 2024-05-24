//
//  GroupScene+View.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 5/4/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

extension GroupScene: View {
    var body: some View {
        List {
            HStack {
                Text("Site IDs:")
                Spacer()
                TextField("Site IDs", text: $siteIDs)
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
            AsyncNavigationLink("API Weather") {
                try await sitesScene()
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .navigationTitle("Fetch Group")
    }
}

struct GroupScene_Previews: PreviewProvider {
    static var previews: some View {
        GroupScene()
    }
}
