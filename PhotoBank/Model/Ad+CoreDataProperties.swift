//
//  Ad+CoreDataProperties.swift
//  
//
//  Created by Hackr on 8/25/19.
//
//

import Foundation
import CoreData


extension Ad {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ad> {
        return NSFetchRequest<Ad>(entityName: "Ad")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var image: String?
    @NSManaged public var url: String?
    @NSManaged public var userId: String?
    @NSManaged public var userImage: String?
    @NSManaged public var username: String?
    @NSManaged public var viewed: Bool

}
