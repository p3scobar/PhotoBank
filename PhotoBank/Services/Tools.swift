//
//  Tools.swift
//  Sparrow
//
//  Created by Hackr on 8/6/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

extension Decimal {
    
    func rounded(_ decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: self as NSDecimalNumber) ?? ""
    }
    
//    var round: String {
//        let formatter = NumberFormatter()
//        formatter.generatesDecimalNumbers = true
//        formatter.minimumFractionDigits = 4
//        formatter.maximumFractionDigits = 4
//        return formatter.string(from: self as NSDecimalNumber) ?? ""
//    }
    
    func roundedDecimal() -> Decimal {
        let number = NSDecimalNumber(decimal: self)
        let rounding = NSDecimalNumberHandler(roundingMode: .bankers, scale: 7, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return number.rounding(accordingToBehavior: rounding).decimalValue
    }
}

extension String {
    func height(forWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func rounded(_ decimals: Int) -> String {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        let number = NSDecimalNumber(string: self)
        return formatter.string(from: number) ?? ""
    }
}

internal func isFavorited(id: String) -> Bool {
////    if Model.shared.favorites[id] == true {
////        print("LIKED POST ID: \(id)")
//        return true
//    } else {
////        print("DISLIKE POST ID: \(id)")
//        return false
//    }
    return false
}


extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

extension Date {
    
    func short() -> String {
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            return formatter
        }()
        return formatter.string(from: self)
    }
    
    func asString() -> String {
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }()
        return formatter.string(from: self)
    }
    
}


extension UIImageView {
    
    func spring() {
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
    }
    
    func shrinkOut() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }
    }
    
}

extension UIButton {
    func spring() {
        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(1.0),
                       initialSpringVelocity: CGFloat(1.0),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
    }
}


extension Status {
    
    func imageHeight(_ viewWidth: CGFloat) -> CGFloat {
        return viewWidth + 160
    }
    
    func cellHeight(_ viewWidth: CGFloat) -> CGFloat {
        var cellHeight = imageHeight(viewWidth)
        if let text = self.text {
            let textHeight = estimateFrameForText(text: text, fontSize: 18).height
            cellHeight += textHeight
        }
        return cellHeight
    }
    
}


extension Ad {
    
    func imageHeight(_ viewWidth: CGFloat) -> CGFloat {
        return viewWidth + 120
    }
    
    func cellHeight(_ viewWidth: CGFloat) -> CGFloat {
        var cellHeight = imageHeight(viewWidth) + 80
        if let text = self.text {
            let textHeight = estimateFrameForText(text: text, fontSize: 18).height
            cellHeight += textHeight+20
        }
        return cellHeight
    }
}


internal func generateChatId(ids:[String]) -> String {
    return ids.sorted(by:>).joined().sha256()
    
}


internal func estimateChatBubbleSize(text: String, fontSize: CGFloat) -> CGSize {
    let size = CGSize(width: 240, height: 480)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: Theme.medium(fontSize)], context: nil).size
}





extension UIView {
   
    func setX(_ x:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x = x
        self.frame = frame
    }
    
    func setY(_ y:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.y = y
        self.frame = frame
    }
    
    func setWidth(_ width:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.width = width
        self.frame = frame
    }

    func setHeight(_ height:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.height = height
        self.frame = frame
    }
}
