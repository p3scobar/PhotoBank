//
//  NewsService.swift
//  Sparrow
//
//  Created by Hackr on 7/27/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import Alamofire
import CoreData
import FirebaseStorage
import FirebaseAuth
import Firebase

struct NewsService {
    
    static func discover(cursor: Int, query: String?, completion: @escaping ([Status]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let urlString = "\(baseUrl)/discover"
            let url = URL(string: urlString)!
            let token = bubbleAPIKey
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
            let query = query ?? ""
            let params: Parameters = ["cursor":cursor, "query": query]
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                var feed = [Status]()
                guard let json = response.result.value as? [String:Any],
                    let resp = json["response"] as? [String:Any],
                    let results = resp["posts"] as? [[String:Any]] else { return }
                results.forEach({ (result) in
                    let id = result["_id"] as? String ?? ""
                    let status = Status.findOrCreateStatus(id: id, data: result, in: PersistenceService.context)
                    feed.append(status)
                })
                completion(feed)
            }
        }
    }
    
    
    static func stories(completion: @escaping ([Status]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let urlString = "\(baseUrl)/stories"
            let url = URL(string: urlString)!
            let token = bubbleAPIKey
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
            
            Alamofire.request(url, method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                var feed = [Status]()
                print(response.result.value)
                guard let json = response.result.value as? [String:Any],
                    let resp = json["response"] as? [String:Any],
                    let results = resp["stories"] as? [[String:Any]] else { return }
                results.forEach({ (result) in
                    let id = result["_id"] as? String ?? ""
                    let status = Status.findOrCreateStatus(id: id, data: result, in: PersistenceService.context)
                    feed.append(status)
                })
                DispatchQueue.main.async {
                    completion(feed)
                }
            }
        }
    }

    
    static func getTimeline(cursor: Int, completion: @escaping (_ feed: [Status], _ ads: [Ad], _ stories: [Story]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let urlString = "\(baseUrl)/timeline"
            let url = URL(string: urlString)!
            let token = bubbleAPIKey
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
            let adSet = cursor/8
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let params: Parameters = ["cursor":cursor, "adSet":adSet, "userId": userId]
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                var feed = [Status]()
                var ads = [Ad]()
                guard let json = response.result.value as? [String:Any],
                    let resp = json["response"] as? [String:Any],
                    let postsJSON = resp["posts"] as? [[String:Any]],
                    let unread = resp["unread"] as? Int else {
                        completion([], [], [])
                        return }
                let adsJson = resp["ads"] as? [[String:Any]] ?? []
                let storiesJSON = resp["stories"] as? [[String:Any]] ?? []
                postsJSON.forEach({ (result) in
                    let id = result["_id"] as? String ?? ""
                    let status = Status.findOrCreateStatus(id: id, data: result, in: PersistenceService.context)
                    feed.append(status)
                })
                adsJson.forEach({ (ad) in
                    print(ad)
                    let id = ad["_id"] as? String ?? ""
                    let status = Ad.findOrCreateAd(id: id, data: ad, in: PersistenceService.context)
                    ads.append(status)
                })
                var stories: [Story] = []
                storiesJSON.forEach({ (result) in
                    let id = result["_id"] as? String ?? ""
                    let status = Story.findOrCreateStory(id: id, data: result, in: PersistenceService.context)
                    stories.append(status)
                })
                DispatchQueue.main.async {
                    completion(feed, ads, stories)
                }
//                NotificationCenter.default.post(name: Notification.Name("unread"), object: nil, userInfo: ["count":unread])
            }
        }
    }

    
    static func fetchPosts(forUser userId: String, completion: @escaping ([Status]) -> Void) {
        let urlString = "\(baseUrl)/posts"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: [String:Any] = ["userId":userId]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            var feed = [Status]()
            guard let json = response.result.value as? [String:Any],
                let resp = json["response"] as? [String:Any],
                let results = resp["posts"] as? [[String:Any]] else { return }
            results.forEach({ (result) in
                let id = result["_id"] as? String ?? ""
                let status = Status.findOrCreateStatus(id: id, data: result, in: PersistenceService.context)
                feed.append(status)
            })
            completion(feed)
        }
    }
    
    static func fetchPost(postId: String, completion: @escaping (Status) -> Void) {
        let urlString = "\(baseUrl)/post"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["postId":postId]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            guard let json = response.result.value as? [String:Any],
                let resp = json["response"] as? [String:Any],
                let data = resp["post"] as? [String:Any] else { return }
                let id = data["_id"] as? String ?? ""
                let status = Status.findOrCreateStatus(id: id, data: data, in: PersistenceService.context)
            completion(status)
        }
    }
    
    static func postPhoto(text: String, image: UIImage) {
        let urlString = "\(baseUrl)/newpost"
        let imageLarge = image.resized(toWidth: 1280)
        let height = imageLarge.size.height
        let width = imageLarge.size.width
        let imageThumb = image.resized(toWidth: 480)
        let name = CurrentUser.name
        let username = CurrentUser.username
        let userImage = CurrentUser.image
        let publicKey = KeychainHelper.publicKey
        let url = URL(string: urlString)!
        let uid = CurrentUser.uid
        print("UID: \(uid)")
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        var params: [String:Any] = ["userId":uid,
                                    "text":text,
                                    "height":height,
                                    "width":width,
                                    "name": name,
                                    "userImage":userImage,
                                    "username":username,
                                    "image":image,
                                    "publicKey":publicKey]
        uploadImageToStorage(image: imageLarge) { (photoUrl) in
            uploadImageToStorage(image: imageThumb, completion: { (thumbnailUrl) in
                params["image"] = photoUrl
                params["thumbnail"] = thumbnailUrl
                Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                    guard let json = response.result.value as? [String:Any],
                        let resp = json["response"] as? [String:Any],
                        let result = resp["post"] as? [String:Any] else { return }
                    let id = result["_id"] as? String ?? ""
                    let photo = Status.findOrCreateStatus(id: id, data: result, in: PersistenceService.context)
                    NotificationCenter.default.post(name: Notification.Name("newPost"), object: nil, userInfo: ["photo":photo])
                }
            })
        }
    }
    
    
    static func deletePost(postId: String) {
        let urlString = "\(baseUrl)/delete"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["postId":postId]
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            guard let json = response.result.value as? [String:Any],
                let status = json["status"] as? String else { return }
            if status == "NOT_RUN" {
                
            } else {
                
            }
        }
    }
    
    
//    static func fetchComments(photoId: String, completion: @escaping ([Comment]) -> Void) {
//        let urlString = "\(baseUrl)/comments"
//        let url = URL(string: urlString)!
//        let token = bubbleAPIKey
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//        let params: [String:Any] = ["id":photoId]
//        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//            var comments = [Comment]()
//            guard let json = response.result.value as? [String:Any],
//                let resp = json["response"] as? [String:Any],
//                let results = resp["comments"] as? [[String:Any]] else { return }
//            results.forEach({ (result) in
//                let id = result["_id"] as? String ?? ""
//                let comment = Comment.findOrCreateComment(id: id, data: result, in: PersistenceService.context)
//                comments.append(comment)
//            })
//            completion(comments)
//        }
//    }
    
    
//    static func deleteComment(id: String, post: Status, completion: @escaping (Bool) -> Void) {
//        let urlString = "\(baseUrl)/deletecomment"
//        let url = URL(string: urlString)!
//        let token = bubbleAPIKey
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//        let params: [String:Any] = ["id":id]
//        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//            print(response)
//            post.commentCount -= Int16(exactly: 1)!
//            completion(true)
//        }
//    }
    
//    static func postComment(post: Status, text: String, completion: @escaping (Comment) -> Void) {
//        let urlString = "\(baseUrl)/comment"
//        let url = URL(string: urlString)!
//        let token = bubbleAPIKey
//        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//        guard let postId = post.id else { return }
//        let params: [String:Any] = ["postId":postId, "text":text]
//        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//            guard let json = response.result.value as? [String:Any],
//                let resp = json["response"] as? [String:Any],
//                let data = resp["comment"] as? [String:Any] else { return }
//            let id = data["_id"] as? String ?? ""
//            let comment = Comment.findOrCreateComment(id: id, data: data, in: PersistenceService.context)
//            post.commentCount += Int16(exactly: 1)!
//            completion(comment)
//        }
//    }
    
    
    static func deleteComment(statusID: String, commentID: String) {
           
           let ref = db.collection("status").document(statusID).collection("comments").document(commentID)
        ref.delete()
//           ref.setData(data, merge: true) { err in
//               if let err = err {
//                   print(err.localizedDescription)
//                   completion(nil)
//               } else {
//                   let comment = Comment(data)
//                   completion(comment)
//                   print("Comment Added")
//               }
//           }
       }
    
    
    static func postComment(status: Status, text: String, completion: @escaping (Comment?) -> Void) {
        
        let id = UUID.init().uuidString
        let userId = CurrentUser.uid
        let name = CurrentUser.name
        let username = CurrentUser.username
        let userImage = CurrentUser.image
        let timestamp = FieldValue.serverTimestamp()
        let data: [String:Any] = ["id":id,
                                  "userId":userId,
                                  "name":name,
                                  "username":username,
                                  "userImage":userImage,
                                  "timestamp":timestamp,
                                  "text":text]
        guard let statusId = status.id else { return }
        let ref = db.collection("status").document(statusId).collection("comments").document(id)
        ref.setData(data, merge: true) { err in
            if let err = err {
                print(err.localizedDescription)
                completion(nil)
            } else {
                let comment = Comment(data)
                completion(comment)
                print("Comment Added")
            }
        }
    }
    
    static func getComments(statusID: String, completion: @escaping ([Comment]) -> Void) {
        let ref = db.collection("status").document(statusID).collection("comments").limit(to: 50).order(by: "timestamp", descending: true)
        ref.getDocuments { (snap, error) in
            if let err = error {
                print(err.localizedDescription)
                completion([])
            } else {
                var comments: [Comment] = []
                snap?.documents.forEach({ (doc) in
                    let data = doc.data()
                    let comment = Comment(data)
                    comments.append(comment)
                })
                completion(comments)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    static func likePost(post: Status) {
        guard let id = post.id else { return }
        let like = Like.likePost(statusID: id, in: PersistenceService.context)
        if like {
            post.likes += Int16(exactly: 1)!
        } else {
            post.likes -= Int16(exactly: 1)!
        }
        let urlString = "\(baseUrl)/like"
        let url = URL(string: urlString)!
        let token = bubbleAPIKey
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["postId":id, "like":like.description]
//        Model.shared.favorites[id] = like
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
        }
    }
    
    static func fetchLikes(completion: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let urlString = "\(baseUrl)/likes"
            let url = URL(string: urlString)!
            let token = bubbleAPIKey
            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
            let params: [String:Any] = [:]
            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in

                guard let json = response.result.value as? [String:Any],
                    let resp = json["response"] as? [String:Any],
                    let likes = resp["likes"] as? [String] else { return }
                
                likes.forEach({ (id) in
//                    Model.shared.favorites[id] = true
                    
                })
            }
        }
    }
    
    
}


internal func uploadImageToStorage(image: UIImage, completion: @escaping (String) -> Swift.Void) {
    let imageName = UUID.init().uuidString
    let ref = Storage.storage().reference().child("images").child(imageName)
    if let uploadData = image.jpegData(compressionQuality: 0.9) {
        ref.putData(uploadData, metadata: nil, completion: { (metaData, error) in
            if error != nil {
                print("failed to upload image:", error!)
                return
            }
            ref.downloadURL(completion: { (url, err) in
                if let link = url?.absoluteString {
                    completion(link)
                }
            })
        })
    }
}

internal func convertImageToBase64(image: UIImage) -> String {
    guard let imageData = image.pngData() else { return "" }
    let base64 = imageData.base64EncodedString()
    return base64
}


