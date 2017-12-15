//
//  FavoritesTableViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/15/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit
import MapKit

class FavoritesTableViewController: UITableViewController {
    let model = CoreDataModel.sharedInstance
    
    let tripCastModel = TripCastModel.sharedInstance

    let dataManager = DataManager.sharedInstance

    var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tripCastModel.currentTable = TableType.Favorite
    }
    
    override func viewWillAppear(animated: Bool) {
        model.favorites.sortInPlace() { $0.title < $1.title}
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    //
    //
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.favorites.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = model.favoriteNameAtIndexPath(indexPath)
        cell.detailTextLabel!.text = model.favoriteSubtitleAtIndexPath(indexPath)
        
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            model.deleteFavoriteAtIndexPath(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    //MARK: - Segue
    //
    //
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "ShowNewFavorite":
            let destination = segue.destinationViewController as! NewFavoriteViewController
            destination.mapView = mapView
        default:
            break
        }
    }
}
