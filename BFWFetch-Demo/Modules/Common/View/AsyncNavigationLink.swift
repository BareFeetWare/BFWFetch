//
//  AsyncNavigationLink.swift
//
//  Created by Tom Brodhurst-Hill on 1/2/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import SwiftUI

/**
 Facilitates:
 1. The cell shows a `>` disclosure indicator.
 2. The user taps the cell. Tap anywhere on the cell.
 3. The cell indicator changes to a ProgressView.
 4. The app performs the action, such as a fetch.
 5. When the action completes, the indicator changes back to a disclosure indicator.
 6. If isActive changes to true (eg if the action was successful), the app moves forward to the destination scene.
 7. If isActive does not change to false (eg if the action failed), it does not move forward. No error shown yet.
*/
struct AsyncNavigationLink<Destination: View, Label: View> {
    let destination: Destination
    @Binding var isActive: Bool
    @Binding var isInProgress: Bool
    let action: () -> Void
    let label: () -> Label
}

extension AsyncNavigationLink: View {
    var body: some View {
        HStack {
            label()
            CompressibleSpacer()
            if isInProgress {
                ProgressView()
            } else {
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(.secondary)
            }
        }
        .background(
            Button("") {
                isInProgress = true
                action()
            }
        )
        .background(
            NavigationLink(
                destination: destination,
                isActive: $isActive,
                label: { Text("Hidden") }
            )
            .hidden()
            .disabled(true)
        )
    }
}

struct AsyncNavigationLink_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                AsyncNavigationLink(
                    destination: Text("Destination"),
                    isActive: .constant(false),
                    isInProgress: .constant(false),
                    action: {},
                    label: { Text("Tap me") }
                )
            }
        }
    }
}
