//
//  TC_UIColor.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/18.
//  Copyright © 2016年 谈超. All rights reserved.
//

import Foundation
import UIKit
extension UIColor{
    /// 取色
    ///
    /// - parameter colrStr: 色值
    ///
    /// - returns: 颜色
    class func Color(_ colrStr:String) -> UIColor {
        var cString = colrStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased() as NSString
        if (cString.length < 6) {
            return UIColor.clear
        }
        // strip 0X if it appears
        if cString.hasPrefix("0X") {
            cString = cString.substring(from: 2) as NSString
        }
        if cString.hasPrefix("#") {
            cString = cString.substring(from: 1) as NSString
        }
        if cString.length != 6 {
            return UIColor.clear
        }
        // Separate into r, g, b substrings
        var range = NSRange()
        range.location = 0 
        range.length = 2 
        //r
        let rString = cString.substring(with: range)
        //g
        range.location = 2 
        let gString = cString.substring(with: range)
        //b
        range.location = 4 
        let bString = cString.substring(with: range)
        // Scan values
        var r :Int32 = 0
        var g :Int32 = 0
        var b :Int32 = 0
        //    var r: Int32 = 0,g :Int32 = 0,b :Int32 = 0
        Scanner(string: rString).scanInt32(&r)
        Scanner(string: gString).scanInt32(&g)
        Scanner(string: bString).scanInt32(&b)
        return UIColor(red: CGFloat(r)/255.0 , green: CGFloat(g)/255.0, blue:CGFloat(b)/255.0, alpha: 1.0)
    }
}
