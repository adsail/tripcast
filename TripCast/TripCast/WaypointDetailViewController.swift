//
//  WaypointDetailViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 12/1/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit

class WaypointDetailViewController: UIViewController {
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var stateName: UILabel!
    @IBOutlet weak var precipitationProbability: UILabel!
    @IBOutlet weak var conditions: UILabel!
    @IBOutlet weak var temperature: UILabel!
    
    var waypoint: Location!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityName.text = waypoint.city!
        stateName.text = waypoint.state!
        
        let myProbability = "\(String(waypoint.preciptationProbability!))%"
        precipitationProbability.text = myProbability
        
        conditions.text = waypoint.iconPhrase!
        
        let myTemperature = "\(String(waypoint.temperature!)) F"
        temperature.text = myTemperature
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
