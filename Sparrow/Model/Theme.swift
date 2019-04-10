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
        return UIColor(220, 220, 220)
    }

    public static var border: UIColor {
        return UIColor(200, 200, 200)
    }
    
    public static var gray: UIColor {
        return UIColor(100, 100, 100)
    }
    
    
    public static var highlight: UIColor {
        return UIColor(100, 100, 100)
    }
    
    public static var unfilled: UIColor {
        return UIColor(140, 140, 140)
    }
    
    public static var charcoal: UIColor {
        return UIColor(40, 40, 40)
    }
    
    public static var black: UIColor {
        return UIColor(30, 30, 30)
    }
    
    public static var blue: UIColor {
        return UIColor(23, 78, 161)
    }
    
    public static var lightBackground: UIColor {
        return UIColor(218, 218, 224)
    }
    
    public static var red: UIColor {
        return UIColor(214, 21, 92)
    }
    
    public static var green: UIColor {
        return UIColor(19, 221, 80)
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
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: Theme.medium(18)], context: nil)
}


internal func estimateFrameForTextWidth(width: CGFloat, text: String, fontSize: CGFloat) -> CGFloat {
    let size = CGSize(width: width, height: 320)
    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize)], context: nil).height
}



