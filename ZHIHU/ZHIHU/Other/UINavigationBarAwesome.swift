//
//  UINavigationBarAwesome.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/18.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
private var navigationBarLayKey:String = "Copyright © 2016年 谈超. All rights reserved..navigationBarLay为了防止重复我多写了点"
extension UINavigationBar{
    private func getOverlay() -> UIView? {
        return objc_getAssociatedObject(self, &navigationBarLayKey) as? UIView ?? nil
    }
    private func setOverlay(overlay:UIView?) {
        objc_setAssociatedObject(self, &navigationBarLayKey, overlay, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    func tc_setBackgroundColor(backgroundColor:UIColor) {
        if (getOverlay() == nil) {
            setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            let view = UIView(frame: CGRect(x: 0, y: -20, width: UIScreen.mainScreen().bounds.size.width, height: CGRectGetHeight(self.bounds)+20))
            view.userInteractionEnabled = false
            view.autoresizingMask =  UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
            setOverlay(view)
            insertSubview(view, atIndex: 0)
        }
        getOverlay()?.backgroundColor = backgroundColor
    }
    func tc_setTranslationY(translationY:CGFloat){
        transform = CGAffineTransformMakeTranslation(0, translationY);
    }
    func tc_setElementsAlpha(alpha:CGFloat) {
        let leftViews = valueForKey("_leftViews") as? [UIView] ?? []
        for leftView in leftViews { leftView.alpha = alpha }
        let rightViews = valueForKey("_rightViews") as? [UIView] ?? []
        for rightView in rightViews { rightView.alpha = alpha }
        let titleView = valueForKey("_titleView") as? UIView
        titleView?.alpha = alpha
    }
    func tc_reset() {
        setBackgroundImage(nil, forBarMetrics: .Default)
        getOverlay()?.removeFromSuperview()
        setOverlay(nil)
    }
//    func getNaviUnderline() -> UIImageView {
//        
//    }
}