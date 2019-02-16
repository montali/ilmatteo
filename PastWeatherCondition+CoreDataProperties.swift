//
//  PastWeatherCondition+CoreDataProperties.swift
//  
//
//  Created by Simone Montali on 12/02/19.
//
//

import Foundation
import CoreData


extension PastWeatherCondition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PastWeatherCondition> {
        return NSFetchRequest<PastWeatherCondition>(entityName: "PastWeatherCondition")
    }

    @NSManaged public var cityId: String?
    @NSManaged public var condition: Int16
    @NSManaged public var datetime: NSDate?
    @NSManaged public var pressure: Int16
    @NSManaged public var temperature: Int16
    @NSManaged public var tempMax: Int16
    @NSManaged public var tempMin: Int16

}
