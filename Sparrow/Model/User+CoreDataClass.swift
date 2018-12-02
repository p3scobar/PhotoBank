//
//  User+CoreDataClass.swift
//  
//
//  Created by Hackr on 7/28/18.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {

    static func findOrCreateUser(id: String, data: [String:Any], in context: NSManagedObjectContext) -> User {
        let request: NSFetchRequest<User> = User.fetchRequest()
        if let id = data["_id"] as? String {
            request.predicate = NSPredicate(format: "id = %@", id)
        }
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "User.findOrCreateStatus -- Database inconsistency")
                let fetched = matches[0]
                fetched.bio = data["bio"] as? String
                fetched.image = data["image"] as? String
                fetched.name = data["name"] as? String
                fetched.username = data["username"] as? String
                fetched.publicKey = data["publicKey"] as? String
                fetched.url = data["url"] as? String
                let count = data["followersCount"] as? Double ?? 0
                let followers = Int16(exactly: count) ?? 0
                fetched.followersCount = followers
                return fetched
            }
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        let user = User(context: context)
        user.id = id
        user.bio = data["bio"] as? String
        user.image = data["image"] as? String
        user.name = data["name"] as? String
        user.username = data["username"] as? String
        user.publicKey = data["publicKey"] as? String
        user.url = data["url"] as? String
        let count = data["followersCount"] as? Double ?? 0
        let followers = Int16(exactly: count) ?? 0
        user.followersCount = followers
        PersistenceService.saveContext()
        return user
    }
    
}
