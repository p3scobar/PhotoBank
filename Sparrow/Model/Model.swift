//
//  Model.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import Firebase

class Model {
    
//    var notifications = [Activity]()
//    var notificationAdded: ((Activity) -> Void)?
//    var notificationRead: ((String) -> Void)?

    var favorites: [String:Bool] = [:]
    
    static let shared: Model = Model()
    
    
    var uid: String {
        get { return UserDefaults.standard.string(forKey: "uid") ?? "" }
        set (uid) { UserDefaults.standard.setValue(uid, forKey: "uid") }
    }
    
    var email: String {
        get { return UserDefaults.standard.string(forKey: "email") ?? "" }
        set (param) { UserDefaults.standard.setValue(param, forKey: "email") }
    }
    
    var name: String {
        get { return UserDefaults.standard.string(forKey: "name") ?? "" }
        set (param) { UserDefaults.standard.setValue(param, forKey: "name") }
    }
    
    var username: String {
        get { return UserDefaults.standard.string(forKey: "username") ?? "" }
        set (param) { UserDefaults.standard.setValue(param, forKey: "username") }
    }
    
    var image: String {
        get { return UserDefaults.standard.string(forKey: "image") ?? "" }
        set (param) { UserDefaults.standard.setValue(param, forKey: "image") }
    }
    
    var bio: String {
        get { return UserDefaults.standard.string(forKey: "bio") ?? "" }
        set (param) { UserDefaults.standard.setValue(param, forKey: "bio") }
    }
    
    var url: String {
        get { return UserDefaults.standard.string(forKey: "url") ?? "" }
        set (param) { UserDefaults.standard.setValue(param, forKey: "url") }
    }
    
    var soundsEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: "soundEnabled") }
        set (enabled) { UserDefaults.standard.set(enabled, forKey: "soundEnabled") }
    }

    
    var blocked: [String:Bool]?
    
    init() {}
    
    static func fetchCurrentUser() {
        
    }
    
}
