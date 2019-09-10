//
//  Like+CoreDataClass.swift
//  
//
//  Created by Hackr on 11/17/18.
//
//

import Foundation
import CoreData

@objc(Like)
public class Like: NSManagedObject {

    static func likePost(statusID: String, in context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<Like> = Like.fetchRequest()
        request.predicate = NSPredicate(format: "statusId = %@", statusID)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Like.findOrCreateLike -- Database inconsistency")
                print("Deleted like for statusID: \(statusID)")
                context.delete(matches[0])
                PersistenceService.saveContext()
                return false
            }
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        print("Created like for status with id: \(statusID)")
        let like = Like(context: context)
        like.statusId = statusID
        PersistenceService.saveContext()
        return true
    }
    
    
    static func checkIfLiked(statusID: String) -> Bool {
        let context = PersistenceService.context
        let request: NSFetchRequest<Like> = Like.fetchRequest()
        request.predicate = NSPredicate(format: "statusId = %@", statusID)
        var exists: Bool = false
        do {
            exists = try context.fetch(request).count > 0
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        return exists
    }
    
    
}
