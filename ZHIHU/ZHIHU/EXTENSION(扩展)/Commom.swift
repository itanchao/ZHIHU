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
let iphone4 : Bool = UIScreen.main.bounds.size.height == 480
let iphone5 : Bool = UIScreen.main.bounds.size.height == 568
let iphone6 : Bool = UIScreen.main.bounds.size.height == 667
let iphone6plus : Bool = UIScreen.main.bounds.size.height == 736
/// 屏幕Bounds
let kScreenBounds: CGRect = UIScreen.main.bounds
/// 屏幕宽
let kScreenWidth : CGFloat = UIScreen.main.bounds.size.width
/// 屏幕高
let kScreenHeight: CGFloat = UIScreen.main.bounds.size.height

func kHeight(_ R:CGFloat)->CGFloat{
    return R*(kScreenHeight/(iphone4 ? 480 : 568 ))
}
func KWidth(_ R:CGFloat)->CGFloat{
    return (R)*(kScreenWidth)/320
}
// MARK: 颜色相关
/// 白色
let KwhiteColor:UIColor = UIColor.white
let KblackColor:UIColor = UIColor.black
let kblueColor:UIColor = UIColor.blue
//获取总代理
func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}
// MARK: - 输出日志
/// 输出日志
///
/// - parameter message:  日志消息
/// - parameter logError: 错误标记，默认是 false，如果是 true，发布时仍然会输出
/// - parameter file:     文件名
/// - parameter method:   方法名
/// - parameter line:     代码行数
func printLog<T>(_ message: T,
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
//extension NSObject{
//     // MARK:NSObject序列化
//    func serialize() -> [String : AnyObject] {
//        var list : [String] = []
//        class_propertyList_recursivelyFetch(class_copyPropertyList(type(of: self), UnsafeMutablePointer<UInt32>.allocate(capacity: 0)), list_pointer: &list)
//        return dictionaryWithValues(forKeys: list) as [String : AnyObject]
//    }
//    /// 获取当前类的属性
//    ///
//    /// - parameter objc_property_t_pointer: class_copyPropertyList(self.dynamicType,UnsafeMutablePointer<UInt32>.alloc(0))
//    /// - parameter list_pointer:            list_pointer description
//    fileprivate func class_propertyList_recursivelyFetch(_ objc_property_t_pointer : UnsafeMutablePointer<objc_property_t>,list_pointer : UnsafeMutablePointer<[String]>)
//    {
//        guard objc_property_t_pointer.pointee == nil else{
//            let name =  NSString.init(utf8String: property_getName(objc_property_t_pointer.pointee))! as String
//            if name != "description" { list_pointer.pointee.append(name) }
//            class_propertyList_recursivelyFetch(objc_property_t_pointer.successor(),list_pointer: list_pointer)
//            return
//        }
//    }
//
//}
// MARK: - 设置farme相关
extension UIView{
    func setX(_ x:CGFloat){
        var frame = self.frame
        frame.origin.x = x
        self.frame = frame 
    }
    func setY(_ y:CGFloat){
        var frame = self.frame
        frame.origin.y = y
        self.frame = frame 
    }
    func getX() ->CGFloat{
        return self.frame.origin.x 
    }
    func getY() ->CGFloat{
        return self.frame.origin.y 
    }
    func setCenterX(_ centerX:CGFloat){
        var center = self.center
        center.x = centerX
        self.center = center
    }
    func setCenterY(_ centerY:CGFloat){
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
    func setWidth(_ width:CGFloat){
        var frame = self.frame
        frame.size.width = width 
        self.frame = frame
    }
    func setHeight(_ height:CGFloat){
        var frame = self.frame
        frame.size.height = height 
        self.frame = frame
    }
    func getHeight()->CGFloat{
        return self.frame.size.height
    }
    func getWidth()->CGFloat{
        return self.frame.size.width
    }
    func setSize(_ size:CGSize){
        var frame = self.frame 
        frame.size = size
        self.frame = frame
    }
    func getSize()->CGSize{
        return self.frame.size
    }
    func setOrigin(_ origin:CGPoint){
        var frame = self.frame
        frame.origin = origin
        self.frame = frame
    }
    func getOrigin()->CGPoint{
        return self.frame.origin
    }
}
public protocol Storage {
    func storageSaveObj(_ object:AnyObject,key:String)
    func storageGetObjWithKey(_ key:String) -> AnyObject?
    func StorageRemoveObjWithKey(_ key:String)
}
extension Storage{
    func storageSaveObj(_ object:AnyObject,key:String) {
        UserDefaults.standard.set(object, forKey: key)
        UserDefaults.standard.synchronize()
    }
    func storageGetObjWithKey(_ key:String) -> AnyObject? {
        return UserDefaults.standard.object(forKey: key) as AnyObject?
    }
    func StorageRemoveObjWithKey(_ key:String){
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
}

