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

    func fetch() {
        do {
            try root.fetch(keyPath: \Root.json) { [weak self] (notification) in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        } catch {
            showAlert(error: error)
        }
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SiteViewController {
            guard let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell),
                let site = root.sites?[indexPath.row]
                else { return }
            destination.site = site
        }
    }
    
}

// MARK: View Model

extension SitesViewController {
    
    enum CellIdentifier: String {
        case site
        case loading
    }
    
}

// MARK: UITableViewDataSource

extension SitesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return root.sites?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: CellIdentifier = root.sites == nil ? .loading : .site
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue, for: indexPath)
        if let site = root.sites?[indexPath.row] {
            cell.textLabel?.text = site.city
            cell.detailTextLabel?.text = "\(site.weather.temperature) °C"
        }
        return cell
    }
    
}
