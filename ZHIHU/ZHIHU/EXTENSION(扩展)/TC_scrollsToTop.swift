//
//  TC_scrollsToTop.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/18.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
// MARK: - UIStatusBar设置
extension UIWindow{
    func scrollsToTop(_ enabel:Bool){
        if getStatusBar() == nil {
            let window = UIWindow(frame: UIApplication.shared.statusBarFrame)
            window.windowLevel = UIWindowLevelStatusBar
            window.backgroundColor = UIColor.clear
            window.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(topWindowClick)))
            window.rootViewController = UIViewController()
            setStatusBar(window)
        }
        getStatusBar()?.isHidden = !enabel
    }
    @objc func topWindowClick() {
        // 遍历当前主窗口所有view,将满足条件的scrollView滚动回原位
        UIWindow.searchAllowScrollViewInView(UIApplication.shared.keyWindow!)
    }
    fileprivate class func searchAllowScrollViewInView(_ superView: UIView) {
        for subview: UIView in superView.subviews {
            if subview.isKind(of: UIScrollView.self) && superView.viewIsInKeyWindow() {
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
    fileprivate func getStatusBar() -> UIWindow? {
        return objc_getAssociatedObject(self, &statusBar) as? UIWindow ?? nil
    }
    fileprivate func setStatusBar(_ statuswindow:UIWindow?) {
        objc_setAssociatedObject(self, &statusBar, statuswindow, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
private var statusBar:String = "Created by tanchao on 16/4/18.UIWindow为了防止重复我多写了点"
// MARK: - view是否在keyWindow中
extension UIView {
    ///  判断调用方法的view是否在keyWindow中
    func viewIsInKeyWindow() -> Bool {
        let keyWindow = UIApplication.shared.keyWindow!
        // 将当前view的坐标系转换到window.bounds
        let viewNewFrame = keyWindow.convert(self.frame, from: self.superview)
        let keyWindowBounds = keyWindow.bounds
        // 判断当前view是否在keyWindow的范围内
        let isIntersects = viewNewFrame.intersects(keyWindowBounds)
        // 判断是否满足所有条件
        return !self.isHidden && self.alpha > 0.01 && self.window == keyWindow && isIntersects
    }
}

