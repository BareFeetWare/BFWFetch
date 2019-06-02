//
//  SitesViewController.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import UIKit
import BFWFetch

class SitesViewController: UITableViewController {

    // MARK: - Variables
    
    let root = Root.shared
    
    // MARK: - Observing

    func addObservers() {
        root.addObserver(of: \.sites) { [weak self] notification in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        root.fetchSites() {_ in }
    }

}

// MARK: UITabelViewDataSource

extension SitesViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return root.sites?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "site", for: indexPath)
        let site = root.sites![indexPath.row]
        cell.textLabel?.text = site.city
        cell.detailTextLabel?.text = "\(site.weather.temperature)°C"
        return cell
    }
}
