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
    class func Color(colrStr:String) -> UIColor {
        var cString = colrStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString as NSString
        if (cString.length < 6) {
            return UIColor.clearColor()
        }
        // strip 0X if it appears
        if cString.hasPrefix("0X") {
            cString = cString.substringFromIndex(2)
        }
        if cString.hasPrefix("#") {
            cString = cString.substringFromIndex(1)
        }
        if cString.length != 6 {
            return UIColor.clearColor()
        }
        // Separate into r, g, b substrings
        var range = NSRange()
        range.location = 0;
        range.length = 2;
        //r
        let rString = cString.substringWithRange(range)
        //g
        range.location = 2;
        let gString = cString.substringWithRange(range)
        //b
        range.location = 4;
        let bString = cString.substringWithRange(range)
        // Scan values
        var r :Int32 = 0
        var g :Int32 = 0
        var b :Int32 = 0
        //    var r: Int32 = 0,g :Int32 = 0,b :Int32 = 0
        NSScanner(string: rString).scanInt(&r)
        NSScanner(string: gString).scanInt(&g)
        NSScanner(string: bString).scanInt(&b)
        return UIColor(red: CGFloat(r)/255.0 , green: CGFloat(g)/255.0, blue:CGFloat(b)/255.0, alpha: 1.0)
    }
}