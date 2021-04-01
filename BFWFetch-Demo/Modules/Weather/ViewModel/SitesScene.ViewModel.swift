//
//  SitesScene.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

extension SitesScene {
    class ViewModel: ObservableObject {
        @Published var sitesResult: Result<[Site], Error>?
        private var subscribers = Set<AnyCancellable>()
    }
}

extension SitesScene.ViewModel {
    func onAppear() {
        subscribeIfNeeded()
    }
}

private extension SitesScene.ViewModel {
    
    func subscribeIfNeeded() {
        if subscribers.isEmpty {
            subscribe()
        }
    }
    
    func subscribe() {
        API.Sites.resultPublisher()
            .receive(on: DispatchQueue.main)
            .sink { wrapperResult in
                let sitesResult = wrapperResult.map { $0.array }
                self.sitesResult = sitesResult }
            .store(in: &subscribers)
    }
    
}
