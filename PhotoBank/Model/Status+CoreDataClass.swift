//
//  Status+CoreDataClass.swift
//  
//
//  Created by Hackr on 7/28/18.
//
//

import Foundation
import CoreData

@objc(Status)
public class Status: NSManagedObject {
    
    static func findOrCreateStatus(id: String, data: [String:Any], in context: NSManagedObjectContext) -> Status {
        let request: NSFetchRequest<Status> = Status.fetchRequest()
        if let id = data["_id"] as? String {
            request.predicate = NSPredicate(format: "id = %@", id)
        }
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                //assert(matches.count == 1, "Status.findOrCreateStatus -- Database inconsistency")
                let photo = matches[0]
                photo.id = id
                photo.text = data["text"] as? String
                photo.image = data["image"] as? String
                photo.thumbnail = data["thumbnail"] as? String
                photo.uid = data["uid"] as? String
                photo.name = data["name"] as? String
                photo.username = data["username"] as? String
                photo.userImage = data["userImage"] as? String
                photo.likes = data["likes"] as? Int16 ?? 0
                photo.commentCount = data["commentCount"] as? Int16 ?? 0
                return photo
            }
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        let status = Status(context: context)
        status.id = id
        status.text = data["text"] as? String
        status.image = data["image"] as? String
        status.thumbnail = data["thumbnail"] as? String
        status.height = data["height"] as? Double ?? 800
        status.width = data["width"] as? Double ?? 600
        status.uid = data["uid"] as? String
        status.name = data["name"] as? String
        status.username = data["username"] as? String
        status.userImage = data["userImage"] as? String
        status.publicKey = data["publicKey"] as? String
        let rawDate = data["timestamp"] as? Int ?? 0
        if let double = Double(exactly: rawDate) {
            let date = Date(timeIntervalSince1970: double)
            status.timestamp = date
        }
        status.likes = data["likes"] as? Int16 ?? 0
        status.commentCount = data["commentCount"] as? Int16 ?? 0
        PersistenceService.saveContext()
        return status
    }
    
    
}






