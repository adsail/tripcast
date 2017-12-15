//
//  CoreDataModel.swift
//  Footballers
//
//  Created by John Hannan on 11/1/16.
//  Copyright © 2016 John Hannan. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class CoreDataModel: DataManagerDelegate {
    var favorites : [FavoriteMO]!
    
    let filename = "TripCast"
    static let sharedInstance = CoreDataModel()
    let dataManager = DataManager.sharedInstance
    
    private init() {
        dataManager.delegate = self
        favorites = dataManager.fetchManagedObjectsForEntity("Favorite", sortKeys: ["title"], predicate: nil) as! [FavoriteMO]
    }
    
    //MARK: - Data Manager Delegate Protocol
    //
    //
    var xcDataModelName: String = "TripCast"
    
    func createDatabase() {
        dataManager.saveContext()
    }
    
    func addFavorite(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        let favoriteMO =  NSEntityDescription.insertNewObjectForEntityForName("Favorite", inManagedObjectContext: dataManager.managedObjectContext) as! FavoriteMO
        
        favoriteMO.title = title
        favoriteMO.subtitle = subtitle
        favoriteMO.latitude = coordinate.latitude
        favoriteMO.longitude = coordinate.longitude
        
        favorites.append(favoriteMO)
        
        dataManager.saveContext()
    }
    
    func favoriteNameAtIndexPath(indexPath: NSIndexPath) -> String {
       return favorites[indexPath.row].title!
    }
    
    func favoriteSubtitleAtIndexPath(indexPath: NSIndexPath) -> String {
        return favorites[indexPath.row].subtitle!
    }
    
    func deleteFavoriteAtIndexPath(indexPath: NSIndexPath) {
        dataManager.managedObjectContext.deleteObject(favorites[indexPath.row])
        favorites.removeAtIndex(indexPath.row)
        dataManager.saveContext()
    }
}