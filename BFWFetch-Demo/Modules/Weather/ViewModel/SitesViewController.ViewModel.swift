//
//  SitesViewController.ViewModel.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 30/3/21.
//  Copyright © 2021 BareFeetWare. All rights reserved.
//

import Foundation
import Combine

extension SitesViewController {
    class ViewModel: ObservableObject {
        @Published var sitesResult: Result<[Site], Error>?
        private var subscribers = Set<AnyCancellable>()
    }
}

extension SitesViewController.ViewModel {
    
    func viewDidLoad() {
        subscribe()
    }
    
    var sites: [Site]? {
        try? sitesResult?.get()
    }
    
    var tableViewNumberOfRows: Int {
        sites?.count ?? 1
    }
    
    var cellIdentifier: String {
        let cellType: CellType = sites == nil ? .loading : .site
        return cellType.rawValue
    }
    
    func site(indexPath: IndexPath) -> Site? {
        sites?[indexPath.row]
    }
    
}

private extension SitesViewController.ViewModel {
    
    enum CellType: String {
        case site
        case loading
    }
    
    func subscribe() {
        API.Sites.resultPublisher()
            .sink { response in
                let sitesResult = response.map { $0.array }
                self.sitesResult = sitesResult }
            .store(in: &subscribers)
    }
}
