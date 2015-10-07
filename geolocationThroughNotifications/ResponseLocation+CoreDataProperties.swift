//
//  ResponseLocation+CoreDataProperties.swift
//  geolocationThroughNotifications
//
//  Created by Jack Borthwick on 10/7/15.
//  Copyright © 2015 Jack Borthwick. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ResponseLocation {

    @NSManaged var lat: String?
    @NSManaged var lon: String?
    @NSManaged var name: String?
    @NSManaged var address: String?

}
