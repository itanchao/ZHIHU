//
//  TrickyNavigationBar.swift
//  TCNavigationBar
//
//  Created by tanchao on 16/4/19.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
public extension UINavigationBar{
    /// 设置背景颜色
    ///
    /// - parameter backgroundColor: 颜色
    public func tc_setBackgroundColor(_ backgroundColor:UIColor) {
        if (getOverlay() == nil) {
            setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            let view = UIView(frame: CGRect(x: 0, y: -20, width: UIScreen.main.bounds.size.width, height: self.bounds.height+20))
            view.isUserInteractionEnabled = false
            view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,UIViewAutoresizing.flexibleHeight]
//            view.autoresizingMask =  UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
            setOverlay(view)
            insertSubview(view, at: 0)
        }
        getOverlay()?.backgroundColor = backgroundColor
    }
    /// 设置位移
    ///
    /// - parameter translationY: 高度偏移
    public func tc_setTranslationY(_ translationY:CGFloat){
        transform = CGAffineTransform(translationX: 0, y: translationY);
    }
    /// 设置透明度
    ///
    /// - parameter alpha: 透明度
    public func tc_setElementsAlpha(_ alpha:CGFloat) {
//        self.alpha = alpha
//        subviews.map { (subView)  in
//            subView.alpha = alpha
//        }
        let leftViews = value(forKey: "_leftViews") as? [UIView] ?? []
        for leftView in leftViews { leftView.alpha = alpha }
        let rightViews = value(forKey: "_rightViews") as? [UIView] ?? []
        for rightView in rightViews { rightView.alpha = alpha }
        let titleView = value(forKey: "_titleView") as? UIView
        titleView?.alpha = alpha
    }
    /// 重置
   public func tc_reset() {
        setBackgroundImage(nil, for: .default)
        getOverlay()?.removeFromSuperview()
        setOverlay(nil)
    }
    fileprivate func getOverlay() -> UIView? {
        return objc_getAssociatedObject(self, &navigationBarLayKey) as? UIView ?? nil
    }
    fileprivate func setOverlay(_ overlay:UIView?) {
        objc_setAssociatedObject(self, &navigationBarLayKey, overlay, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
private var navigationBarLayKey:String = "TC_UINavigationBarLayKey"
