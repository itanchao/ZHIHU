//
//  Commom.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/12.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit

// MARK: 设备相关
//判断设备类型
let iphone4 : Bool = UIScreen.mainScreen().bounds.size.height == 480
let iphone5 : Bool = UIScreen.mainScreen().bounds.size.height == 568
let iphone6 : Bool = UIScreen.mainScreen().bounds.size.height == 667
let iphone6plus : Bool = UIScreen.mainScreen().bounds.size.height == 736
/// 屏幕Bounds
let kScreenBounds: CGRect = UIScreen.mainScreen().bounds
/// 屏幕宽
let kScreenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
/// 屏幕高
let kScreenHeight: CGFloat = UIScreen.mainScreen().bounds.size.height

func kHeight(R:CGFloat)->CGFloat{
    return R*(kScreenHeight/(iphone4 ? 480 : 568 ))
}
func KWidth(R:CGFloat)->CGFloat{
    return (R)*(kScreenWidth)/320
}
// MARK: 颜色相关
/// 白色
let KwhiteColor:UIColor = UIColor.whiteColor()
let KblackColor:UIColor = UIColor.blackColor()
let kblueColor:UIColor = UIColor.blueColor()
/*!
 颜色
 
 - parameter colrStr: 色值
 
 - returns: 颜色
 */
func Color(colrStr:String) -> UIColor {
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
    NSScanner(string: rString).scanInt(&r)
    NSScanner(string: gString).scanInt(&g)
    NSScanner(string: bString).scanInt(&b)
    return UIColor(red: CGFloat(r)/255.0 , green: CGFloat(g)/255.0, blue:CGFloat(b)/255.0, alpha: 1.0)
}
//获取总代理
func appCloud() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}
// MARK: - 输出日志
/// 输出日志
///
/// - parameter message:  日志消息
/// - parameter logError: 错误标记，默认是 false，如果是 true，发布时仍然会输出
/// - parameter file:     文件名
/// - parameter method:   方法名
/// - parameter line:     代码行数
func printLog<T>(message: T,
              logError: Bool = false,
              file: String = #file,
              method: String = #function,
              line: Int = #line)
{
    if logError {
        print("\((file as NSString).lastPathComponent) <line:\(line)> <function: \(method)>{\n\(message)\n}")
    } else {
        #if DEBUG
            print("\((file as NSString).lastPathComponent) <line:\(line)> <function: \(method)>{\n\(message)\n}")
        #endif
    }
}
extension NSObject{
     // MARK:NSObject序列化
    func serialize() -> [String : AnyObject] {
        var list : [String] = []
        class_operationPropertyList_map(class_copyPropertyList(self.dynamicType, UnsafeMutablePointer<UInt32>.alloc(0)), list_pointer: &list)
                return dictionaryWithValuesForKeys(list)
    }
    /*!
     获取当前类的属性
     
     - parameter objc_property_t_pointer:  class_copyPropertyList(self.dynamicType, UnsafeMutablePointer<UInt32>.alloc(0))
     - parameter list_pointer:            list_pointer description
     */
    private func class_operationPropertyList_map(objc_property_t_pointer : UnsafeMutablePointer<objc_property_t>,list_pointer : UnsafeMutablePointer<[String]>)
    {
        guard objc_property_t_pointer.memory == nil else{
            let name =  NSString.init(UTF8String: property_getName(objc_property_t_pointer.memory))! as String
            if name != "description" { list_pointer.memory.append(name) }
            class_operationPropertyList_map(objc_property_t_pointer.successor(),list_pointer: list_pointer)
            return;
        }
    }

}
extension UIView{
    func setX(x:CGFloat){
        var frame = self.frame
        frame.origin.x = x
        self.frame = frame;
    }
    func setY(y:CGFloat){
        var frame = self.frame
        frame.origin.y = y
        self.frame = frame;
    }
    func getX() ->CGFloat{
        return self.frame.origin.x;
    }
    func getY() ->CGFloat{
        return self.frame.origin.y;
    }
    
    func setCenterX(centerX:CGFloat){
        var center = self.center
        center.x = centerX
        self.center = center
    }
    func setCenterY(centerY:CGFloat){
        var center = self.center
        center.y = centerY
        self.center = center
    }
    func getCenterX() -> CGFloat{
        return self.center.x
    }
    func getCenterY() -> CGFloat{
        return self.center.y
    }
    func setWidth(width:CGFloat){
        var frame = self.frame
        frame.size.width = width;
        self.frame = frame
    }
    func setHeight(height:CGFloat){
        var frame = self.frame
        frame.size.height = height;
        self.frame = frame
    }
    func getHeight()->CGFloat{
        return self.frame.size.height
    }
    func getWidth()->CGFloat{
        return self.frame.size.width
    }
    func setSize(size:CGSize){
        var frame = self.frame;
        frame.size = size
        self.frame = frame
    }
    func getSize()->CGSize{
        return self.frame.size
    }
    func setOrigin(origin:CGPoint){
        var frame = self.frame
        frame.origin = origin
        self.frame = frame
    }
    func getOrigin()->CGPoint{
        return self.frame.origin
    }
}
