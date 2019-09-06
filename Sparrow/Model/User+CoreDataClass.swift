//
//  User+CoreDataClass.swift
//  
//
//  Created by Hackr on 7/28/18.
//
//

import Foundation

class User: NSObject {
    
    public var id: String?
    public var bio: String?
    public var image: String?
    public var name: String?
    public var publicKey: String?
    public var url: String?
    public var username: String?
    public var followersCount: Int16
    

    init(data: [String:Any]) {
        self.id = data["id"] as? String ?? ""
        self.bio = data["bio"] as? String ?? ""
        self.image = data["image"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.publicKey = data["publicKey"] as? String ?? ""
        self.url = data["url"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.followersCount = data["followersCount"] as? Int16 ?? 0
    }
    
}

