//
//  LocationSearchTable.swift
//  TripCast
//
//  Credit: sweettutos.com tutorial
//  Created by Andrew D. Sail on 11/14/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    
    let model = CoreDataModel.sharedInstance
    let tripCastModel = TripCastModel.sharedInstance
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView!
    
    var tableType: TableType!
    
    var currentSearchController: UISearchController!
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // Format address for display
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            selectedItem.thoroughfare ?? "",
            comma,
            selectedItem.locality ?? "",
            secondSpace,
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    override func viewDidLoad() {
    }

}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.startWithCompletionHandler { (response, _) in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            
            for item in self.matchingItems {
                for favorite in self.model.favorites {
                    let latitude: Double = favorite.latitude as! Double
                    let longitude: Double = favorite.longitude as! Double
                    
                    if item.placemark.coordinate.latitude == latitude && item.placemark.coordinate.longitude == longitude {
                        self.matchingItems.removeAtIndex(self.matchingItems.indexOf(item)!)
                    }
                }
            }
            
            self.currentSearchController = searchController
 
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchTable {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        let selectedItem = matchingItems[indexPath.row].placemark
        cell!.textLabel!.text = selectedItem.name
        cell!.detailTextLabel!.text = parseAddress(selectedItem)
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedMapItem = matchingItems[indexPath.row].placemark
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        if tableType == TableType.Favorite {
            model.addFavorite(selectedCell!.textLabel!.text!, subtitle: parseAddress(selectedMapItem), coordinate: selectedMapItem.coordinate)
            currentSearchController.searchBar.text = ""
        }
        if tripCastModel.currentTable == TableType.Origin {
            let myLocation: Location = Location(coordinate: selectedMapItem.coordinate)
            tripCastModel.setOriginTo(myLocation)
            tripCastModel.currentTable = TableType.Destination
            currentSearchController.searchBar.text = ""
        }
        else if tripCastModel.currentTable == TableType.Destination {
            let myLocation: Location = Location(coordinate: selectedMapItem.coordinate)
            tripCastModel.setDestinationTo(myLocation)
            currentSearchController.searchBar.text = ""
            tripCastModel.currentTable = TableType.Complete
        }
        
        if tableType == TableType.Favorite {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else{
            performSegueWithIdentifier("UnwindSuggestions", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "UnwindSuggestions":
            let destination = segue.destinationViewController as! OriginViewController

            if tripCastModel.currentTable == TableType.Destination {
                destination.instructionsLabel.text = "Next, search for a destination address, select an address from favorites, or use your current location."
            }
            if tripCastModel.currentTable == TableType.Complete {
                destination.instructionsLabel.text = "Tap 'Next' to continue."
                destination.nextButton.enabled = true
            }
   
        default:
            break
        }
    }
}
