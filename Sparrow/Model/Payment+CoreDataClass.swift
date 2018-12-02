//
//  Payment+CoreDataClass.swift
//  
//
//  Created by Hackr on 8/5/18.
//
//

import Foundation
import CoreData


enum PaymentType: String {
    case send = "send"
    case receive = "receive"
}


@objc(Payment)
public class Payment: NSManagedObject {
    
    static func findOrCreatePayment(id: String, data: [String:Any], in context: NSManagedObjectContext) -> Payment {
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", id)
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                assert(matches.count == 1, "Payment.findOrCreateStatus -- Database inconsistency")
                return matches[0]
            }
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        let payment = Payment(context: context)
        payment.id = id
        payment.from = data["from"] as? String
        payment.fromImage = data["from_image"] as? String
        payment.fromName = data["from_name"] as? String
        payment.fromUsername = data["from_username"] as? String
        payment.to = data["to"] as? String
        payment.toImage = data["to_image"] as? String
        payment.toName = data["to_name"] as? String
        payment.toUsername = data["to_username"] as? String
        payment.amount = data["amount"] as? String ?? "0.000"
        let rawDate = data["timestamp"] as? Int ?? 0
        if let double = Double(exactly: rawDate/1000) {
            let date = Date(timeIntervalSince1970: double)
            payment.timestamp = date
        }
        payment.isReceived = Model.shared.uuid == payment.to
        return payment
    }
    
    
    static func fetchAll(in context: NSManagedObjectContext) -> [Payment] {
        let request: NSFetchRequest<Payment> = Payment.fetchRequest()
        let timestamp = NSSortDescriptor(key: "timestamp", ascending: true)
        request.sortDescriptors = [timestamp]
        var payments: [Payment] = []
        do {
            payments = try context.fetch(request)
        } catch {
            let error = error
            print(error.localizedDescription)
        }
        return payments
    }
    
    
}

extension Payment {
    
    func fetchOtherName() -> String {
        let pk = KeychainHelper.publicKey
        guard let from = from,
            let fromName = fromName,
            let toName = toName else { return "" }
        return from != pk ? fromName : toName
    }
    
    func fetchOtherUsername() -> String {
        let pk = KeychainHelper.publicKey
        guard let from = from,
            let fromUsername = fromUsername,
            let toUsername = toUsername else { return "" }
        return from != pk ? fromUsername : toUsername
    }
    
    func fetchOtherImage() -> String {
        let pk = KeychainHelper.publicKey
        guard let from = from,
            let fromImage = fromImage,
            let toImage = toImage else { return "" }
        return from != pk ? fromImage : toImage
    }
    
}
