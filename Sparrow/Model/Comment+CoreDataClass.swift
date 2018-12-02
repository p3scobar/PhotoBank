//
//  Comment+CoreDataClass.swift
//  
//
//  Created by Hackr on 8/4/18.
//
//

import Foundation
import CoreData

@objc(Comment)
public class Comment: NSManagedObject {

    static func findOrCreateComment(id: String, data: [String:Any], in context: NSManagedObjectContext) -> Comment {
        let request: NSFetchRequest<Comment> = Comment.fetchRequest()
        if let id = data["_id"] as? String {
            request.predicate = NSPredicate(format: "id = %@", id)
        }
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Comment.findOrCreateStatus -- Database inconsistency")
                let fetched = matches[0]
                fetched.text = data["text"] as? String
                fetched.userId = data["userId"] as? String
                fetched.name = data["name"] as? String
                fetched.username = data["username"] as? String
                fetched.userImage = data["userImage"] as? String
                return fetched
            }
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        let comment = Comment(context: context)
        comment.id = id
        comment.text = data["text"] as? String
        comment.userId = data["userId"] as? String
        comment.name = data["name"] as? String
        comment.username = data["username"] as? String
        comment.userImage = data["userImage"] as? String
        
        return comment
    }
    
}
