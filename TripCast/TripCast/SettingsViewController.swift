//
//  SettingsViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/12/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var mapType: UISegmentedControl!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var trafficSwitch: UISwitch!
    
    @IBAction func mapTypeChanged(sender: AnyObject) {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setInteger(mapType.selectedSegmentIndex, forKey: UserDefaults.mapType)
        prefs.synchronize()
    }
    
    @IBAction func locationSwitchToggled(sender: AnyObject) {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(locationSwitch.on, forKey: UserDefaults.showUserLocation)
        prefs.synchronize()
    }
    
    @IBAction func trafficSwitchToggled(sender: AnyObject) {
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setBool(trafficSwitch.on, forKey: UserDefaults.showTraffic)
        prefs.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs = NSUserDefaults.standardUserDefaults()

        mapType.selectedSegmentIndex = prefs.integerForKey(UserDefaults.mapType)
        locationSwitch.on = prefs.boolForKey(UserDefaults.showUserLocation)
        trafficSwitch.on = prefs.boolForKey(UserDefaults.showTraffic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
