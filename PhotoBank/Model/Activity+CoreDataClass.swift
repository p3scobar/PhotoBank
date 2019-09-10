//
//  Activity+CoreDataClass.swift
//  
//
//  Created by Hackr on 7/28/18.
//
//

import Foundation
import CoreData

@objc(Activity)
public class Activity: NSManagedObject {

    static func findOrCreateActivity(id: String, data: [String:Any], in context: NSManagedObjectContext) -> Activity {
        let request: NSFetchRequest<Activity> = Activity.fetchRequest()
        if let id = data["_id"] as? String {
            request.predicate = NSPredicate(format: "id = %@", id)
        }
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Activity.findOrCreateStatus -- Database inconsistency")
                let fetched = matches[0]
                fetched.statusId = data["postId"] as? String
                fetched.name = data["name"] as? String
                fetched.userId = data["userId"] as? String
                fetched.userImage = data["userImage"] as? String
                fetched.text = data["text"] as? String
                fetched.image = data["image"] as? String
                fetched.type = data["type"] as? String
                return fetched
            }
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        let activity = Activity(context: context)
        activity.id = id
        activity.type = data["type"] as? String
        activity.text = data["text"] as? String
        activity.statusId = data["postId"] as? String
        activity.name = data["name"] as? String
        activity.userId = data["userId"] as? String
        activity.userImage = data["userImage"] as? String
        activity.image = data["image"] as? String
        PersistenceService.saveContext()
        return activity
    }
    
    
    static func fetchAll() -> [Activity] {
        let context = PersistenceService.context
        let request: NSFetchRequest<Activity> = Activity.fetchRequest()
        let timestamp = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [timestamp]
        var activity: [Activity] = []
        do {
            activity = try context.fetch(request)
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        return activity
    }
    
}
