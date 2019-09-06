//
//  UserService.swift
//  Sparrow
//
//  Created by Hackr on 8/2/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import Alamofire
import stellarsdk
import Firebase

struct UserService {

    static func follow(userId: String, follow: Bool, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
        let urlString = "\(baseUrl)/follow"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["userId":userId, "follow": follow.description]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            print(response)
            guard let json = response.result.value as? [String:Any],
                let resp = json["response"] as? [String:Any] else { return }
            let following = resp["following"] as? Bool ?? false
            completion(following)
        }
        }
    }

    static func block(userId: String, block: Bool, completion: @escaping (Bool) -> Void) {
        let urlString = "\(baseUrl)/block"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["userId":userId, "block": block.description]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            print(response)
            guard let json = response.result.value as? [String:Any],
                let resp = json["response"] as? [String:Any] else { return }
            let following = resp["blocked"] as? Bool ?? false
            completion(following)
        }
    }

   
    static func fetchUsers(query username: String, completion: @escaping ([User]) -> Swift.Void) {
        DispatchQueue.global(qos: .background).async {
        var users: [User] = []
        let blocked = Model.shared.blocked ?? [:]
        let ref = db.collection("users").whereField("username", isGreaterThanOrEqualTo: username)
        ref.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else { return }
            for item in documents {
                let user = User(data: item.data())
                if let userId = user.id {
                    if blocked[userId] != true {
                        users.append(user)
                    } else {
                        print("\(user.name ?? "") is blocked.")
                    }
                }
            }
            completion(users)
        }
        }
    }
    
    
//    static func fetchUsers(username: String, completion: @escaping ([User]) -> Void) {
//        let urlString = "\(baseUrl)/users"
//        let url = URL(string: urlString)!
//        let params: [String:Any] = ["text":username]
//        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
//            var users = [User]()
//            guard let json = response.result.value as? [String:Any],
//                let resp = json["response"] as? [String:Any],
//                let results = resp["users"] as? [[String:Any]] else { return }
//            results.forEach({ (data) in
//                print(data)
//                let id = data["_id"] as? String ?? ""
//                let user = User.findOrCreateUser(id: id, data: data, in: PersistenceService.context)
//                users.append(user)
//            })
//            completion(users)
//        }
//    }

//    static func fetchUser(uuid: String, completion: @escaping (User, Bool) -> Void) {
//        let urlString = "\(baseUrl)/user"
//        let url = URL(string: urlString)!
//        let token = bubbleAPIKey
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//        let params: [String:Any] = ["userId":uuid]
//        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//            print(response)
//            guard let json = response.result.value as? [String:Any],
//                let resp = json["response"] as? [String:Any],
//                let result = resp["user"] as? [String:Any] else { return }
//
//            let following: Bool = resp["following"] as? Bool ?? false
//            let id = result["_id"] as? String ?? ""
//            let user = User.findOrCreateUser(id: id, data: result, in: PersistenceService.context)
//            completion(user, following)
//        }
//    }

//    static func fetchUser(byPublicKey publicKey: String, completion: @escaping (User, Bool) -> Void) {
//        let urlString = "\(baseUrl)/user"
//        let url = URL(string: urlString)!
//        let token = bubbleAPIKey
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//        let params: [String:Any] = ["publicKey":publicKey]
//        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//            print(response)
//            guard let json = response.result.value as? [String:Any],
//                let resp = json["response"] as? [String:Any],
//                let result = resp["user"] as? [String:Any] else { return }
//
//            let following: Bool = resp["following"] as? Bool ?? false
//            let id = result["_id"] as? String ?? ""
//            let user = User.findOrCreateUser(id: id, data: result, in: PersistenceService.context)
//            completion(user, following)
//        }
//    }

//
//    static func signup(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
//        let urlString = "\(baseUrl)/signup"
//        let url = URL(string: urlString)!
//        let params: [String:Any] = ["name":name, "email":email, "password":password]
//        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
//            print(response)
//            guard let json = response.result.value as? [String:Any],
//                let resp = json["response"] as? [String:Any],
//                let userData = resp["user"] as? [String:Any] else { return }
//
//            let token = resp["token"] as? String ?? ""
//            let id = userData["_id"] as? String ?? ""
//            let user = User.findOrCreateUser(id: id, data: userData, in: PersistenceService.context)
//            Model.shared.token = token
//            Model.shared.uuid = user.id ?? ""
//            Model.shared.name = user.name ?? ""
//            Model.shared.email = email
//            Model.shared.username = user.username ?? ""
//            Model.shared.bio = user.bio ?? ""
//            KeychainHelper.mnemonic = Wallet.generate12WordMnemonic()
//            completion(true)
//        }
//    }




    static func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            if let error = err {
                print(error.localizedDescription)
                completion(false)
            } else {
                setCurrentUser()
                loginBubble(email, password)
                completion(true)
            }
        }
    }
    
    static private func loginBubble(_ email: String, _ password: String) {
        let urlString = "\(baseUrl)/login"
        let url = URL(string: urlString)!
        let headers: HTTPHeaders = [:]
        let params: [String:Any] = ["email":email, "password":password]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            Model.shared.uid = ""
            Model.shared.name = ""
            Model.shared.username = ""
            Model.shared.image = ""
            Model.shared.bio = ""
            KeychainHelper.publicKey = ""
            KeychainHelper.privateSeed = ""
            Payment.deleteAll()
//            completion(true)
        }
    }
    

    static func signout(completion: @escaping (Bool) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        
        let urlString = "\(baseUrl)/signout"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: [String:Any] = [:]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            Model.shared.uid = ""
            Model.shared.name = ""
            Model.shared.username = ""
            Model.shared.image = ""
            Model.shared.bio = ""
            KeychainHelper.publicKey = ""
            KeychainHelper.privateSeed = ""
            Payment.deleteAll()
            completion(true)
        }
    }

//    static func updateUsername(userId: String, username: String, completion: @escaping (Bool) -> Void) {
//        let urlString = "\(baseUrl)/username"
//        let url = URL(string: urlString)!
//        let token = bubbleAPIKey
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//        let params: [String:Any] = ["userId":userId, "username":username]
//        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//            if let error = response.error {
//                print(error.localizedDescription)
//                completion(false)
//            } else {
//                guard let value = response.result.value as? [String:Any],
//                let status = value["status"] as? String, status == "success" else {
//                    completion(false)
//                    return
//                }
//                Model.shared.username = username
//                completion(true)
//            }
//        }
//    }


    static func updatePublicKey(pk: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
        let urlString = "\(baseUrl)/publickey"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: [String:Any] = ["key":pk]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
        }
    }


    static func updateUser(name: String, bio: String, website: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
        let urlString = "\(baseUrl)/updateuser"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: [String:Any] = ["name":name, "bio":bio, "url":website]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            if let error = response.error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
        }
    }


    static func updateProfilePic(image: UIImage, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .background).async {
            uploadImageToStorage(image: image) { (imageUrl) in
                updateUserInfo(values: ["image":imageUrl], completion: { (success) in
                    completion(imageUrl)
                })
            }
        }
    }


}



extension UserService {
    
    static func getUserWithUsername(_ username: String, completion: @escaping (User?) -> Void) {
        let ref = db.collection("users").whereField("username", isEqualTo: username)
        ref.getDocuments { (snap, error) in
            if let err = error {
                print(err.localizedDescription)
                completion(nil)
            } else {
                guard let data = snap?.documents.first?.data() else {
                    print("No user fetched from username")
                    completion(nil)
                    return
                }
                let user = User(data: data)
                completion(user)
            }
        }
    }
    
    
    static func usernameAvailable(_ username: String, completion: @escaping (Bool) -> Swift.Void) {
        let ref = db.collection("users").whereField("username", isEqualTo: username)
        ref.getDocuments { (snap, error) in
            if let err = error {
                print(err.localizedDescription)
                completion(false)
            } else {
                if snap!.documents.count > 0 {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    
    static func updateUserInfo(values: [String:Any], completion: @escaping (Bool) -> Void) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("users").document(id)
        ref.setData(values, merge: true) { err in
            if let err = err {
                print(err.localizedDescription)
                completion(false)
            } else {
                completion(true)
                print("user data updated")
            }
        }
    }
    
    
    static func getUserWithPublicKey(_ publicKey: String, completion: @escaping (User?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let ref = db.collection("users").whereField("publicKey", isEqualTo: publicKey)
            ref.getDocuments { (snap, error) in
                if let err = error {
                    print(err.localizedDescription)
                    completion(nil)
                } else {
                    guard let data = snap?.documents.first?.data() else {
                        print("No user fetched from public key")
                        completion(nil)
                        return
                    }
                    let user = User(data: data)
                    completion(user)
                }
            }
        }
    }

    
    static func fetchUser(userId: String, completion: @escaping (User) -> Swift.Void) {
        guard userId != "" else {
            print("COULD NOT FETCH USER FROM EMPTY USER ID")
            return
        }
        print("USER ID: \(userId)")
        
        let ref = db.collection("users").document(userId)
        ref.getDocument { (document, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                if let document = document, let data = document.data(), document.exists {
                    let user = User(data: data)
                    completion(user)
                }
            }
        }
    }
    
    static func getUser(_ id: String, completion: @escaping (User?) -> Swift.Void) {
        DispatchQueue.global(qos: .background).async {
            let ref = db.collection("users").document(id)
            ref.getDocument { (document, error) in
                if let document = document, let data = document.data(), document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    
                    let user = User(data: data)
                    completion(user)
                } else {
                    completion(nil)
                    print("Document does not exist")
                }
            }
        }
    }
    
//    let docRef = db.collection("cities").document("SF")
//
//    docRef.getDocument { (document, error) in
//    if let document = document, document.exists {
//    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
//    print("Document data: \(dataDescription)")
//    } else {
//    print("Document does not exist")
//    }
//    }

    
    internal static func setCurrentUser() {
        DispatchQueue.global(qos: .background).async {
        guard let id = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(id).getDocument { (snap, err) in
            if let error = err {
                print(error.localizedDescription)
            } else {
                guard let data = snap?.data() else { return }
                let user = User(data: data)
                Model.shared.uid = id
                Model.shared.bio = user.bio ?? ""
                Model.shared.image = user.image ?? ""
                Model.shared.username = user.username ?? ""
                Model.shared.name = user.name ?? ""
            }
        }
        }
    }
    
    
    
    static func signup(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
        Auth.auth().createUser(withEmail: email, password: password) { (auth, err) in
            if let error = err {
                print(error.localizedDescription)
                completion(false)
            } else {
                updateUserInfo(values: ["name":name], completion: { _ in })
                completion(true)
                createBubbleUser(email, password)
            }
        }
        }
    }
    
    private static func createBubbleUser(_ email: String, _ password: String) {
        DispatchQueue.global(qos: .background).async {
        let urlString = "\(baseUrl)/signup"
        let url = URL(string: urlString)!
        let params: [String:Any] = ["email":email, "password":password]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(response)
            
//            guard let json = response.result.value as? [String:Any],
//                let resp = json["response"] as? [String:Any],
//                let userData = resp["user"] as? [String:Any] else { return }
//
//            let token = resp["token"] as? String ?? ""
//            let id = userData["_id"] as? String ?? ""
            
        }
        }
    }
    
    
}
