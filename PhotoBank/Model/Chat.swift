//
//  Chat.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class Chat: NSObject {
    
    var id: String
    var messages: [Message] = []
    var userIds: [String] = []
    var lastMessage: String?
    var lastMessageSent: TimeInterval?
    var fromId: String?
    var image: String?
    var title: String?
    var isGroup: Bool
    var users: [User] = []
    
    init?(snapshot: DataSnapshot) {
        guard let data = snapshot.value as? [String:Any],
            let id = data["id"] as? String,
            let timestamp = data["timestamp"] as? TimeInterval else {
                return nil
        }
        self.lastMessage = data["lastMessage"] as? String
        self.userIds = data["users"] as? [String] ?? []
        self.id = id
        self.fromId = data["fromId"] as? String
        self.lastMessageSent = timestamp
        self.isGroup = data["isGroup"] as? Bool ?? false
        self.title = data["title"] as? String
        self.image = data["image"] as? String
        super.init()
        setupTitle()
    }
    
    init(userIds: [String]) {
        self.id = generateChatId(ids: userIds)
        self.userIds = userIds
        self.isGroup = userIds.count > 2
        super.init()
        setupTitle()
    }
    
    
    
        public func chatPartnerId() -> String? {
            guard userIds.count > 1 else { return nil }
            return userIds[0] != Auth.auth().currentUser?.uid ? userIds[0] : userIds[1]
        }
    
    public var partnerId: String? {
        guard userIds.count > 1 else { return nil }
        return userIds[0] != Auth.auth().currentUser?.uid ? userIds[0] : userIds[1]
    }
    
    func setupTitle() {
        if isGroup {
            
        } else {
            guard let id = partnerId else { return }
            UserService.fetchUser(userId: id) { (user) in
                self.image = user.image ?? ""
                self.title = user.name ?? ""
                self.users.append(user)
            }
        }
    }
    
}

