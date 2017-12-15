//
//  OriginViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/17/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit
import MapKit

class OriginViewController: UIViewController {
    let tripCastModel = TripCastModel.sharedInstance
    
    @IBOutlet weak var instructionsLabel: UILabel!
    var resultSearchController: UISearchController? = nil
    var mapView: MKMapView!
    
    @IBOutlet weak var favoritesButton: UIBarButtonItem!
    @IBOutlet weak var locationButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBAction func locationButtonPressed(sender: AnyObject) {
        if tripCastModel.currentTable == TableType.Origin {
            let myLocation = Location(coordinate: mapView.userLocation.coordinate)
            tripCastModel.setOriginTo(myLocation)
            instructionsLabel.text = "Next, search for a destination address, select an address from favorites, or use your current location."
            tripCastModel.currentTable = TableType.Destination
        }
        else if tripCastModel.currentTable == TableType.Destination {
            let myLocation = Location(coordinate: mapView.userLocation.coordinate)
            tripCastModel.setDestinationTo(myLocation)
            instructionsLabel.text = "Tap 'Next' to continue."
            tripCastModel.currentTable = TableType.Complete
            nextButton.enabled = true
            locationButton.enabled = false
            favoritesButton.enabled = false
        }
    }
  
    @IBAction func favoritesButtonPressed(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.enabled = false
        
        tripCastModel.currentTable = TableType.Origin

        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for an address"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.tableType = TableType.Origin
        locationSearchTable.mapView = mapView
    }
    
    override func viewDidAppear(animated: Bool) {
        if tripCastModel.currentTable == TableType.Destination {
            instructionsLabel.text = "Next, search for a destination address, select an address from favorites, or use your current location."
        }
        else if tripCastModel.currentTable == TableType.Complete{
            instructionsLabel.text = "Tap 'Next' to continue."
            nextButton.enabled = true
            favoritesButton.enabled = false
            locationButton.enabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindSuggestions(segue:UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        switch segue.identifier! {
        case "UnwindSuggestions":
            break
        case "UnwindFavorites":
            break
        default:
            break
        }
    }
}
