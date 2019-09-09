//
//  Message.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit
import Firebase

enum MessageType: String {
    case Text = "text"
    case Money = "money"
}

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
    var amount: String?
    var assetCode: String?
    var status: String?
    
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
        self.status = dict["status"] as? String
        self.amount = dict["amount"] as? String
        self.assetCode = dict["assetCode"] as? String
        self.type = .Text
        let messageType = dict["type"] as? String ?? "text"
        self.type = MessageType(rawValue: messageType) ?? .Text
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
        case .Money:
            return 180
        }
    }
    
}




extension Message {
        
        func cellForMessageType(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
            switch self.type {
            case .Text:
                let cell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! MessageCell
                return cell
            case .Money:
                 let cell = tableView.dequeueReusableCell(withIdentifier: "money", for: indexPath) as! MessageMoneyCell
                return cell
            }
        }
    
    
}
