//
//  Story+CoreDataClass.swift
//  
//
//  Created by Hackr on 9/15/19.
//
//

import Foundation
import CoreData

@objc(Story)
public class Story: NSManagedObject {
    
    static func findOrCreateStory(id: String, data: [String:Any], in context: NSManagedObjectContext) -> Story {
        let request: NSFetchRequest<Story> = Story.fetchRequest()
        if let id = data["_id"] as? String {
            request.predicate = NSPredicate(format: "id = %@", id)
        }
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                let item = matches[0]
                item.id = id
                item.userId = data["userId"] as? String ?? ""
                item.userId = data["url"] as? String ?? ""
                item.userId = data["userId"] as? String ?? ""
                item.userImage = data["userImage"] as? String ?? ""
                let rawDate = data["timestamp"] as? Int ?? 0
                if let double = Double(exactly: rawDate) {
                    let date = Date(timeIntervalSince1970: double)
                    item.timestamp = date
                }
                return item
            }
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        let story = Story(context: context)
        story.id = id
        story.userId = data["userId"] as? String ?? ""
        story.userImage = data["userImage"] as? String ?? ""
        story.url = data["url"] as? String ?? ""
       
        let rawDate = data["timestamp"] as? Int ?? 0
        if let double = Double(exactly: rawDate) {
            let date = Date(timeIntervalSince1970: double)
            story.timestamp = date
        }
        PersistenceService.saveContext()
        return story
    }
    
    


}
