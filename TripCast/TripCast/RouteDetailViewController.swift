//
//  RouteDetailViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/12/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit

class RouteDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var waypointTable: UITableView!
    let tripCastModel = TripCastModel.sharedInstance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waypointTable.dataSource = self
        waypointTable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("waypointCell", forIndexPath: indexPath) as! WaypointTableViewCell
        
        tripCastModel.locations.sortInPlace() { $0.epochETA < $1.epochETA}
        let myLocation = tripCastModel.locations[indexPath.row]
        cell.titleLabel.text = myLocation.title
        cell.conditionsLabel.text = myLocation.iconPhrase
        cell.conditionsImageView.contentMode = .ScaleAspectFill
        
        if myLocation.weatherIcon != nil {
            cell.conditionsImageView.image = UIImage(named: String(myLocation.weatherIcon!))
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripCastModel.locations.count
    }
}
