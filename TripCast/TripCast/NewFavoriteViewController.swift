//
//  NewFavoriteViewController.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/14/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit
import MapKit

class NewFavoriteViewController: UIViewController {

    var resultSearchController: UISearchController? = nil
    var mapView: MKMapView!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        locationSearchTable.mapView = mapView
        locationSearchTable.tableType = TableType.Favorite
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
