//
//  Message.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var id: String?
    var text: String?
    var timestamp: Date
    var imageUrl: String?
    var userId: String?
    var name: String?
    var username: String?
    var userImage: String?
    var txId: String?
    var url: String?
    var incoming: Bool
    var type: MessageType
    
    enum MessageType {
        case Text
        case Photo
        case Transaction
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String:Any],
            let id = dict["id"] as? String,
            let userId = dict["userId"] as? String,
            let timestamp = dict["timestamp"] as? TimeInterval
            else { return nil }
        
        self.id = id
        self.userId = userId
        self.name = dict["name"] as? String
        self.username = dict["username"] as? String
        self.userImage = dict["userImage"] as? String
        self.timestamp = Date(timeIntervalSince1970: timestamp)
        self.text = dict["text"] as? String
        self.imageUrl = dict["imageUrl"] as? String
        self.txId = dict["txId"] as? String
        self.url = dict["url"] as? String
        self.type = .Text
        self.incoming = CurrentUser.uid != userId
    }
    
}


extension Message {
    
    func height(_ isGroup: Bool) -> CGFloat {
        switch self.type {
        case .Text:
            guard let text = self.text else { return 0 }
            var height = estimateChatBubbleSize(text: text, fontSize: 18).height
            height += 28
            if isGroup && self.incoming { height += 20 }
            return height
        case .Photo:
            return 240
        case .Transaction:
            return 240
        }
    }
    
}

