//
//  Comment+CoreDataClass.swift
//  
//
//  Created by Hackr on 8/4/18.
//
//

import Foundation
import UIKit

class Comment: NSObject {
    
    var id: String?
    var text: String?
    var userId: String?
    var name: String?
    var username: String?
    var userImage: String?
    var timestamp: Date?
    
    init(_ data: [String:Any]) {
        let timestamp = data["timestamp"] as? TimeInterval ?? 0
        self.id = data["id"] as? String
        self.userId = data["userId"] as? String
        self.name = data["name"] as? String
        self.username = data["username"] as? String
        self.userImage = data["userImage"] as? String
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.text = data["text"] as? String
    }
    
}


extension Comment {
    
    func height() -> CGFloat {
        guard let text = text else { return 0 }
        var height = estimateChatBubbleSize(text: text, fontSize: 18).height
        height += 28
        return height
    }
    
}

    
