//
//  AdService.swift
//  Sparrow
//
//  Created by Hackr on 8/25/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import Foundation
import Alamofire
import stellarsdk

struct AdService {
    
//    static func viewed(_ id: String, completion: () -> Void) {
//        print("Viewed: \(id)")
//        let amount = 0.0025
//        let pk = KeychainHelper.publicKey
//        WalletService.adPayout(id) { (_) in
//
//        }
////   sendPayment(token: , toAccountID: T##String, amount: <#T##Decimal#>, completion: <#T##(Bool) -> Void#>)
//    }
    
    
//    static func fetchAds(completion: @escaping ([Status]) -> Void) {
//        DispatchQueue.global(qos: .background).async {
//            let urlString = "\(baseUrl)/ads"
//            let url = URL(string: urlString)!
//            let token = Model.shared.token
//            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//            let params: Parameters = [:]
//            Alamofire.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//                var feed = [Status]()
//                guard let json = response.result.value as? [String:Any],
//                    let resp = json["response"] as? [String:Any],
//                    let results = resp["ads"] as? [[String:Any]] else { return }
////                    let unread = resp["unread"] as? Int else { return }
//                results.forEach({ (result) in
////                    let id = result["_id"] as? String ?? ""
//                    print(result)
////                    let status = Status.findOrCreateStatus(id: id, data: result, in: PersistenceService.context)
////                    feed.append(status)
//                })
//                completion(feed)
//            }
//        }
//    }

//    static func fetchActivity(completion: @escaping ([Activity]) -> Void) {
//        DispatchQueue.global(qos: .background).async {
//            let urlString = "\(baseUrl)/activity"
//            let url = URL(string: urlString)!
//            let token = Model.shared.token
//            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
//            let params: Parameters = [:]
//            Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
//                var notifications = [Activity]()
//                guard let json = response.result.value as? [String:Any],
//                    let resp = json["response"] as? [String:Any],
//                    let results = resp["activity"] as? [[String:Any]] else { return }
//                results.forEach({ (data) in
//                    let id = data["_id"] as? String ?? ""
//                    let activity = Activity.findOrCreateActivity(id: id, data: data, in: PersistenceService.context)
//                    notifications.append(activity)
//                })
//                completion(notifications)
//                NotificationCenter.default.post(name: Notification.Name("unread"), object: nil, userInfo: ["count":0])
//            }
//        }
//    }
    
}

