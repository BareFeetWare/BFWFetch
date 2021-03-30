//
//  SiteViewController.swift
//  BFWFetch-Demo
//
//  Created by Tom Brodhurst-Hill on 2/6/19.
//  Copyright © 2019 BareFeetWare. All rights reserved.
//

import UIKit

class SiteViewController: UITableViewController {
    
    // MARK: - Variables
    
    var site: Site!
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var cityNameCell: UITableViewCell!
    @IBOutlet private weak var summaryCell: UITableViewCell!
    @IBOutlet private weak var descriptionCell: UITableViewCell!
    @IBOutlet private weak var temperatureCell: UITableViewCell!
    @IBOutlet private weak var minimumTemperatureCell: UITableViewCell!
    @IBOutlet private weak var maximumTemperatureCell: UITableViewCell!
    @IBOutlet private weak var pressureCell: UITableViewCell!
    @IBOutlet private weak var humidityCell: UITableViewCell!
    @IBOutlet private weak var windSpeedCell: UITableViewCell!
    @IBOutlet private weak var windDirectionCell: UITableViewCell!
    
    // MARK: - Functions
    
    private func updateViews() {
        cityNameCell.detailTextLabel?.text = site.name
        summaryCell.detailTextLabel?.text = site.summary
        descriptionCell.detailTextLabel?.text = site.description
        temperatureCell.detailTextLabel?.text = site.temperatureString
        minimumTemperatureCell.detailTextLabel?.text = site.minimumTemperatureString
        maximumTemperatureCell.detailTextLabel?.text = site.maximumTemperatureString
        pressureCell.detailTextLabel?.text = site.pressureString
        humidityCell.detailTextLabel?.text = site.humidityString
        windSpeedCell.detailTextLabel?.text = site.windSpeedString
        windDirectionCell.detailTextLabel?.text = site.windDirectionString
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
}
