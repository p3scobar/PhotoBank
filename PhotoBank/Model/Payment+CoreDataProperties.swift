//
//  Payment+CoreDataProperties.swift
//  
//
//  Created by Hackr on 8/5/18.
//
//

import Foundation
import CoreData


extension Payment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: "Payment")
    }

    @NSManaged public var id: String?
    @NSManaged public var assetCode: String?
    @NSManaged public var amount: String?
    @NSManaged public var issuer: String?
    @NSManaged public var from: String?
    @NSManaged public var to: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var isReceived: Bool
}
