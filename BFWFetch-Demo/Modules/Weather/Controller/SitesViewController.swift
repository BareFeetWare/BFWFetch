//
//  SitesViewController.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 1/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import UIKit
import Combine
import BFWFetch

class SitesViewController: UITableViewController {
    private let viewModel = ViewModel()
    private var subscribers = Set<AnyCancellable>()
}

// MARK: - UIViewController

extension SitesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        subscribe()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SitesViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SiteViewController {
            guard let cell = sender as? UITableViewCell,
                  let indexPath = tableView.indexPath(for: cell),
                  let site = viewModel.site(indexPath: indexPath)
            else { return }
            destination.site = site
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableViewNumberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellIdentifier, for: indexPath)
        if let site = viewModel.site(indexPath: indexPath) {
            cell.textLabel?.text = site.city
            cell.detailTextLabel?.text = site.temperatureString
        }
        return cell
    }
    
}

// MARK: - Private

private extension SitesViewController {
    func subscribe() {
        viewModel.$sitesResult
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .none, .success(_): break
                case .failure(let error): self.showAlert(error: error)
                }
                self.tableView.reloadData()
            }
            .store(in: &subscribers)
    }
}
