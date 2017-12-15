//
//  FavoriteMO+CoreDataProperties.swift
//  TripCast
//
//  Created by Andrew D. Sail on 11/15/16.
//  Copyright © 2016 Andrew Sail. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FavoriteMO {

    @NSManaged var title: String?
    @NSManaged var subtitle: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?

}
