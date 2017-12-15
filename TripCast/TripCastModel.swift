//
//  LocationModel.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/14/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import Foundation
import MapKit

enum TableType {
    case Favorite
    case Origin
    case Destination
    case Complete
}

enum LocationType {
    case Origin
    case Destination
    case Waypoint
}

class TripCastModel {
    static let sharedInstance = TripCastModel()
    let hour: Double = 3600
    
    var origin : Location!
    var destination: Location!
    var currentTable: TableType!
    var departureTime: Double!
    var locations = [Location]()
    var hourDelay: Int!
    
    
    func setOriginTo(origin: Location){
        self.origin = origin
        self.origin.type = LocationType.Origin
    }
    
    func setDestinationTo(destination: Location){
        self.destination = destination
        self.destination.type = LocationType.Destination
    }
    
    func setDepartureTime(hourDelay: Double) {
        departureTime = NSDate().timeIntervalSince1970 + (hour * hourDelay)
        self.hourDelay = Int(hourDelay)
    }
}

class Location: NSObject, MKAnnotation {
    var title: String?
    var city: String?
    var state: String?
    var stateID: String?
    var iconPhrase: String?
    var preciptationProbability: Int?
    var coordinate: CLLocationCoordinate2D
    var epochTimestamp: Int?
    var epochETA: Int?
    var type: LocationType?
    var weatherIcon: Int?
    var temperature: Int?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func mapItem() -> MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}