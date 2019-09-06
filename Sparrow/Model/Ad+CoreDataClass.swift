//
//  Ad+CoreDataClass.swift
//  
//
//  Created by Hackr on 8/25/19.
//
//

import Foundation
import CoreData

@objc(Ad)
public class Ad: NSManagedObject {
    
    static func findOrCreateAd(id: String, data: [String:Any], in context: NSManagedObjectContext) -> Ad {
        let request: NSFetchRequest<Ad> = Ad.fetchRequest()
        if let id = data["_id"] as? String {
            request.predicate = NSPredicate(format: "id = %@", id)
        }
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                //assert(matches.count == 1, "Status.findOrCreateStatus -- Database inconsistency")
                let ad = matches[0]
                ad.id = id
                ad.text = data["text"] as? String
                ad.url = data["url"] as? String
                ad.image = data["image"] as? String
                ad.userId = data["userId"] as? String
                ad.username = data["username"] as? String
                ad.userImage = data["userImage"] as? String
                return ad
            }
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        let ad = Ad(context: context)
        ad.id = id
        ad.text = data["text"] as? String
        ad.url = data["url"] as? String
        ad.image = data["image"] as? String
        ad.userId = data["userId"] as? String
        ad.username = data["username"] as? String
        ad.userImage = data["userImage"] as? String
        
        PersistenceService.saveContext()
        return ad
    }
    
    
}
