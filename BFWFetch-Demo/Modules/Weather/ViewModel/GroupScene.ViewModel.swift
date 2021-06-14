//
//  GroupScene.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

extension GroupScene {
    class ViewModel: ObservableObject {
        @Published var siteIDs: String = "4163971,2147714,2174003"
        @Published var system: System = .metric
        @Published var sites: [Site]?
        @Published var isActiveLinkedScene = false
        @Published var isInProgressFetch = false
        @Published var isPresentedAlert = false
        var error: Error?
        private var subscribers = Set<AnyCancellable>()
    }
}

extension GroupScene.ViewModel {
    func fetch() {
        API.Request.Group.publisher(siteIDs: siteIDs, system: system)
            .mapError(API.Response.specificError)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        self.error = error
                        self.isPresentedAlert = true
                    case .finished:
                        break
                    }
                    self.isInProgressFetch = false
                }
                , receiveValue: { wrapper in
                    let sites = wrapper.array
                    self.sites = sites
                    self.isActiveLinkedScene = true
                }
            )
            .store(in: &subscribers)
    }
}
