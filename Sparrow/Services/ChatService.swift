//
//  ChatService.swift
//  Sparrow
//
//  Created by Hackr on 9/5/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import Firebase

struct ChatService {
    
    static var chatsDictionary: [String:Chat] = [:] {
        didSet {
            let convos = Array(chatsDictionary.values)
            let chatsSorted = convos.sorted { $0.lastMessageSent ?? 0.0 > $1.lastMessageSent ?? 0.0 }
            chats?(chatsSorted)
        }
    }
    
    static var chats: (([Chat]) -> Void)?
    
    
    static func fetchChats() {
        DispatchQueue.global(qos: .background).async {
            guard let id = Auth.auth().currentUser?.uid else { return }
            let userChatsRef = dbRealtime.child("userChats").child(id)
            let chatRef = dbRealtime.child("chats")
            
            userChatsRef.observe(.value) { (snap) in
                guard let chatDict = snap.value as? [String:Bool] else { return }
                chatDict.forEach({ (key, _)  in
                    chatRef.child(key).observe(.value, with: { (snap) in
                        if let chat = Chat(snapshot: snap) {
                            chatsDictionary.updateValue(chat, forKey: snap.key)
                        }
                    })
                })
            }
            
        }
    }
    
    
    static func fetchChat(chatId: String, completion: @escaping (Chat?) -> Swift.Void) {
        DispatchQueue.global(qos: .background).async {
        let ref = dbRealtime.child("chats").child(chatId)
        ref.observeSingleEvent(of: .value) { (snap) in
            guard let chat = Chat(snapshot: snap) else {
                return completion(nil)
            }
            completion(chat)
        }
        }
    }
    
    
    
    static func observeMessages(chatId: String, completion: @escaping (Message?) -> Void) {
        DispatchQueue.global(qos: .background).async {
        let ref = dbRealtime.child("messages").child(chatId)
        ref.observe(.childAdded, with: { (snap) in
            guard let message = Message(snapshot: snap) else {
                return completion(nil)
            }
            completion(message)
        })
        }
    }
    
    static func removeObserverForChat(chatId: String) {
        
        let ref = dbRealtime.child("messages").child(chatId)
        ref.removeAllObservers()
    }
    
    
    static func sendMessage(chat: Chat, properties: [String: Any]) {
        DispatchQueue.global(qos: .background).async {
        let userId = CurrentUser.uid
        let userImage = CurrentUser.image
        let name = CurrentUser.name
        let username = CurrentUser.username
        let messageId: String = UUID.init().uuidString
        let messageRef = dbRealtime.child("messages").child(chat.id).child(messageId)
        let timestamp = ServerValue.timestamp()
        var messageValues = ["id": messageId,
                             "userId": userId,
                             "timestamp": timestamp,
                             "userImage": userImage,
                             "name": name,
                             "username": username
            ] as [String : Any]
        var chatValues = ["fromId": userId,
                          "timestamp": timestamp,
                          "id": chat.id,
                          "isGroup":chat.isGroup] as [String : Any]
        if let lastMessage = properties["text"] as? String {
            chatValues["lastMessage"] = lastMessage
        }
        properties.forEach({messageValues[$0] = $1})
        messageRef.updateChildValues(messageValues) { (err, ref) in
            if let error = err {
                print(error.localizedDescription)
            } else {
                updateChat(chat: chat, values: chatValues)
            }
        }
        }
    }
    
    fileprivate static func updateChat(chat: Chat, values:[String:Any]) {
        DispatchQueue.global(qos: .background).async {
        let chatRef = dbRealtime.child("chats").child(chat.id)
        chatRef.updateChildValues(values)
        chatRef.child("users").setValue(chat.userIds)
        chat.userIds.forEach { (id) in
            dbRealtime.child("userChats").child(id).child(chat.id).setValue(true)
            if !chat.isGroup, id != CurrentUser.uid {
//                ActivityManager.pushNotification(toId: id, message: "Sent you a message.")
            }
        }
        }
    }
    
    
//    static func deleteChat(chatId: String) {
//        guard chatId != "" else { return }
//        DispatchQueue.global(qos: .background).async {
//        let userId = CurrentUser.uid
//        let ref = dbRealtime.child("userChats").child(userId).child(chatId)
//        ref.removeValue()
//        chatsDictionary[chatId] = nil
//        }
//    }
    
    static func deleteChat(chatId: String) {
        let userId = CurrentUser.uid
        guard userId != "" else { return }
        let ref = dbRealtime.child("userChats").child(userId).child(chatId)
        ref.removeValue()
        chatsDictionary[chatId] = nil
    }
    
    
}





