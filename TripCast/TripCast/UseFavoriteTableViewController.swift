//
//  UseFavoriteTableViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/28/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit
import MapKit

class UseFavoriteTableViewController: UITableViewController {
    let model = CoreDataModel.sharedInstance
    let tripCastModel = TripCastModel.sharedInstance
    let dataManager = DataManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.favorites.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("useFavoriteCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = model.favoriteNameAtIndexPath(indexPath)
        cell.detailTextLabel!.text = model.favoriteSubtitleAtIndexPath(indexPath)
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        
        let myFavorite = model.favorites[indexPath.row]
        let myCoordinate = CLLocationCoordinate2D(latitude: Double(myFavorite.latitude!), longitude: Double(myFavorite.longitude!))
        let myLocation: Location = Location(coordinate: myCoordinate)
        
        if tripCastModel.currentTable == TableType.Origin {
            tripCastModel.setOriginTo(myLocation)
            tripCastModel.currentTable = TableType.Destination
        }
        else if tripCastModel.currentTable == TableType.Destination {
            tripCastModel.setDestinationTo(myLocation)
            tripCastModel.currentTable = TableType.Complete
        }
    }
}
