//
//  City+CoreDataProperties.swift
//  
//
//  Created by Simone Montali on 11/02/19.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var cityName: String?

}
