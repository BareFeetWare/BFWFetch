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
        cityNameCell.detailTextLabel?.text = site.city
        let weather = site.weather
        summaryCell.detailTextLabel?.text = weather.summary
        descriptionCell.detailTextLabel?.text = weather.description
        temperatureCell.detailTextLabel?.text = "\(weather.temperature) °C"
        minimumTemperatureCell.detailTextLabel?.text = "\(weather.minimumTemperature) °C"
        maximumTemperatureCell.detailTextLabel?.text = "\(weather.maximumTemperature) °C"
        pressureCell.detailTextLabel?.text = "\(weather.pressure) mBar"
        humidityCell.detailTextLabel?.text = "\(weather.humidity) %"
        windSpeedCell.detailTextLabel?.text = "\(weather.windSpeed) km/h"
        windDirectionCell.detailTextLabel?.text = "\(weather.windDirection) °"
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
}
