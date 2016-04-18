//
//  UIWindowExtension.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/18.
//  Copyright © 2016年 谈超. All rights reserved.
//

import Foundation
import UIKit
private var statusBar:String = "Created by tanchao on 16/4/18.UIWindow为了防止重复我多写了点"
extension UIWindow{
   private func getStatusBar() -> UIWindow? {
        return objc_getAssociatedObject(self, &statusBar) as? UIWindow ?? nil
    }
    private func setStatusBar(statuswindow:UIWindow?) {
        objc_setAssociatedObject(self, &statusBar, statuswindow, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    func scrollsToTop(enabel:Bool){
        if getStatusBar() == nil {
            let window = UIWindow(frame: UIApplication.sharedApplication().statusBarFrame)
            window.windowLevel = UIWindowLevelStatusBar
            window.backgroundColor = UIColor.clearColor()
            window.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topWindowClick)))
            window.rootViewController = UIViewController()
            setStatusBar(window)
        }
        getStatusBar()?.hidden = !enabel
    }
    @objc func topWindowClick() {
        // 遍历当前主窗口所有view,将满足条件的scrollView滚动回原位
        UIWindow.searchAllowScrollViewInView(UIApplication.sharedApplication().keyWindow!)
    }
    private class func searchAllowScrollViewInView(superView: UIView) {
        for subview: UIView in superView.subviews {
            if subview.isKindOfClass(UIScrollView.self) && superView.viewIsInKeyWindow() {
                // 拿到scrollView的contentOffset
                var offest = (subview as! UIScrollView).contentOffset
                // 将offest的y轴还原成最开始的值
                offest.y = -(subview as! UIScrollView).contentInset.top
                // 重新设置scrollView的内容
                (subview as! UIScrollView).setContentOffset(offest, animated: true)
            }
            // 递归,让子控件再次调用这个方法判断时候还有满足条件的view
            searchAllowScrollViewInView(subview)
        }
    }
    
}
///  对UIView的一个扩展
extension UIView {
    ///  判断调用方法的view是否在keyWindow中
    func viewIsInKeyWindow() -> Bool {
        let keyWindow = UIApplication.sharedApplication().keyWindow!
        // 将当前view的坐标系转换到window.bounds
        let viewNewFrame = keyWindow.convertRect(self.frame, fromView: self.superview)
        let keyWindowBounds = keyWindow.bounds
        // 判断当前view是否在keyWindow的范围内
        let isIntersects = CGRectIntersectsRect(viewNewFrame, keyWindowBounds)
        // 判断是否满足所有条件
        return !self.hidden && self.alpha > 0.01 && self.window == keyWindow && isIntersects
    }
}
// MARK:设置farme相关
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

