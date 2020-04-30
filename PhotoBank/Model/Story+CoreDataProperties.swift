//
//  Story+CoreDataProperties.swift
//  
//
//  Created by Hackr on 9/15/19.
//
//

import Foundation
import CoreData


extension Story {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Story> {
        return NSFetchRequest<Story>(entityName: "Story")
    }

    @NSManaged public var id: String?
    @NSManaged public var userImage: String?
    @NSManaged public var userId: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var url: String?

}
