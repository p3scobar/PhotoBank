//
//  Theme.swift
//  Sparrow
//
//  Created by Hackr on 7/28/18.
//  Copyright © 2018 Sugar. All rights reserved.
//

import Foundation
import UIKit

public struct Theme {}

extension Theme {
    
    static func bold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
    }
    
    static func semibold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
    }
    
    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
    }
    
    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.regular)
    }
    
    public static var lightGray: UIColor {
        return UIColor(181, 181, 186)
    }

    public static var border: UIColor {
        return UIColor(200, 200, 200)
    }
    
    public static var gray: UIColor {
        return UIColor(120, 120, 120)
    }
    
    public static var darkGray: UIColor {
        return UIColor(50, 50, 50)
    }
    
    
    public static var highlight: UIColor {
        return UIColor(0, 110, 207)
    }
    
    public static var unfilled: UIColor {
        return UIColor(140, 140, 140)
    }
    
    public static var tint: UIColor {
        return UIColor(20, 20, 20)
    }
    
    public static var black: UIColor {
        return UIColor(12, 12, 12)
    }
    
    public static var blue: UIColor {
        return UIColor(23, 78, 161)
    }
    
    public static var lightBackground: UIColor {
        return UIColor(212, 212, 218)
    }
    
    public static var red: UIColor {
        return UIColor(214, 21, 92)
    }
    
    public static var green: UIColor {
        return UIColor(19, 221, 80)
    }
    
    public static var incoming: UIColor {
//        return UIColor(191, 191, 196)
        return Theme.lightBackground
    }
    
    public static var outgoing: UIColor {
        return UIColor(60, 64, 67)
    }
    
    public static var link: UIColor {
//        return UIColor(0, 158, 21)
        return UIColor(33, 111, 219)
    }
    
    public static var card: UIColor {
        return UIColor(220, 220, 220).withAlphaComponent(0.2)
    }
    
}



extension UIColor {
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}


internal func estimateFrameForText(text: String, fontSize: CGFloat) -> CGRect {
    let width = UIScreen.main.bounds.width-84
    let size = CGSize(width: width, height: 320)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: Theme.medium(18)], context: nil)
}


internal func estimateFrameForTextWidth(width: CGFloat, text: String, fontSize: CGFloat) -> CGFloat {
    let size = CGSize(width: width, height: 320)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil).height
}



