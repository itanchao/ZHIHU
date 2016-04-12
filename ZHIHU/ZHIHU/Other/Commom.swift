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
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    } else {
        #if DEBUG
            print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
        #endif
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
