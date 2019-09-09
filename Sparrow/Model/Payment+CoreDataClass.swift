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
        payment.assetCode = data["assetCode"] as? String
        payment.amount = data["amount"] as? String
//        payment.issuer = data["issuer"] as? String
        payment.from = data["from"] as? String
        payment.to = data["to"] as? String
        payment.timestamp = data["timestamp"] as? Date
        payment.isReceived = CurrentUser.uid == payment.to
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
    
    static func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Payment")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let container = PersistenceService.persistentContainer
        do {
            try container.viewContext.execute(deleteRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
}

extension Payment {
    
    func otherUserKey() -> String? {
        let pk = KeychainHelper.publicKey
        guard let fromPK = from,
            let toPK = to else { return nil }
        return fromPK != pk ? fromPK : toPK
    }
    
//    func fetchOtherName() -> String {
//        let pk = KeychainHelper.publicKey
//        guard let from = from,
//            let fromName = fromName,
//            let toName = toName else { return "" }
//        return from != pk ? fromName : toName
//    }
//
//    func fetchOtherUsername() -> String {
//        let pk = KeychainHelper.publicKey
//        guard let from = from,
//            let fromUsername = fromUsername,
//            let toUsername = toUsername else { return "" }
//        return from != pk ? fromUsername : toUsername
//    }
//
//    func fetchOtherImage() -> String {
//        let pk = KeychainHelper.publicKey
//        guard let from = from,
//            let fromImage = fromImage,
//            let toImage = toImage else { return "" }
//        return from != pk ? fromImage : toImage
//    }
    
}
