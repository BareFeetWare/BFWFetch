//
//  GroupScene.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation

extension GroupScene {
    class ViewModel: ObservableObject {
        @Published var siteIDs: String = "4163971,2147714,2174003"
        @Published var system: System = .metric
        @Published var sites: [Site]?
        @Published var isActiveLinkedScene = false
        @Published var isInProgressFetch = false
        @Published var isPresentedAlert = false
        var error: Error?
    }
}

extension GroupScene.ViewModel {
    
    @MainActor
    func fetch() {
        Task {
            do {
                let wrapper = try await API.Request.Group.fetched(siteIDs: siteIDs, system: system)
                let sites = wrapper.array
                self.sites = sites
                self.isActiveLinkedScene = true
            } catch {
                self.error = API.Response.specificError(error)
                self.isPresentedAlert = true
            }
            self.isInProgressFetch = false
        }
    }
}
