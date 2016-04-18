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
        class_propertyList_recursivelyFetch(class_copyPropertyList(self.dynamicType, UnsafeMutablePointer<UInt32>.alloc(0)), list_pointer: &list)
        return dictionaryWithValuesForKeys(list)
    }
    /// 获取当前类的属性
    ///
    /// - parameter objc_property_t_pointer: class_copyPropertyList(self.dynamicType,UnsafeMutablePointer<UInt32>.alloc(0))
    /// - parameter list_pointer:            list_pointer description
    private func class_propertyList_recursivelyFetch(objc_property_t_pointer : UnsafeMutablePointer<objc_property_t>,list_pointer : UnsafeMutablePointer<[String]>)
    {
        guard objc_property_t_pointer.memory == nil else{
            let name =  NSString.init(UTF8String: property_getName(objc_property_t_pointer.memory))! as String
            if name != "description" { list_pointer.memory.append(name) }
            class_propertyList_recursivelyFetch(objc_property_t_pointer.successor(),list_pointer: list_pointer)
            return;
        }
    }

}
