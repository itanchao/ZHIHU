//
//  TCCircleChart.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/22.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class TCCircleChart: UIView {
    static func attachObserveToScrollView(_ crollView:UIScrollView,target:AnyObject,action:Selector) -> TCCircleChart {
        let circleView = TCCircleChart()
        circleView.scrollView = crollView
        circleView.target = target
        circleView.action = action
        circleView.backgroundColor = UIColor.clear
        circleView.addSubview(circleView.activityView)
        return circleView
    }
    lazy fileprivate  var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        activityView.hidesWhenStopped = true
        activityView.stopAnimating()
        return activityView
    }()
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath != "contentOffset" {return}
         offsetY = scrollView!.contentOffset.y + 20
        if hidding && offsetY >= 0 {
            hidding = false
            refreshing = false
            activityView.stopAnimating()
        }
        if refreshing {return}
        if offsetY! < -60 && offsetY! >= -90 && !scrollView!.isDragging {
            refreshing = true
            activityView.startAnimating()
            UIControl().sendAction(action!, to: target, for: .none)
        }
        setNeedsDisplay()
    }
    func stopAnimating(){
        refreshing = false
        activityView.stopAnimating()
    }
    func endRefreshing() {
        if scrollView?.contentOffset.y <= -20 {
            hidding = false
        }else{
            refreshing = false
            activityView.stopAnimating()
        }
    }
    override func draw(_ rect: CGRect) {
        if scrollView?.contentOffset.y >= 0 || refreshing {return}
        let radius = (frame.size.width - 5) * 0.5
        let context2 = UIGraphicsGetCurrentContext()
//        context2?.addRect(CGRect(x: frame.size.width*0.5, y: frame.size.width*0.5, width: 0, height: 0))
        context2?.addArc(center: CGPoint(x: frame.size.width*0.5, y: frame.size.width*0.5), radius: 0, startAngle: CGFloat(M_PI) * 2, endAngle: CGFloat(M_PI) * 2, clockwise: false)
            
//        CGContext.addArc(context2, frame.size.width * 0.5, frame.size.width * 0.5, 0, 0, CGFloat(M_PI) * 2, 0)
        UIColor.lightGray.set()
        context2?.strokePath()
        let context = UIGraphicsGetCurrentContext()
        let endAngle = CGFloat(-M_PI) / 30 * offsetY! - CGFloat(M_PI) * 1.5
        context?.addArc(center: CGPoint(x: frame.size.width * 0.5, y: frame.size.width * 0.5), radius: radius, startAngle:  CGFloat(-M_PI) * 1.5, endAngle: endAngle, clockwise: false)
//        CGContextAddArc(context, frame.size.width * 0.5, frame.size.width * 0.5, radius, CGFloat(-M_PI) * 1.5, endAngle, 0)
        UIColor.white.set()
        context?.strokePath()
    }
    override var frame: CGRect{
        didSet{
            activityView.frame = bounds
        }
    }
    fileprivate var scrollView : UIScrollView?{
        didSet{
            scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [.new,.old], context: UnsafeMutableRawPointer.allocate(bytes: 0, alignedTo: 0))
//        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [.new,.old], context: UnsafeMutableRawPointer.allocate(capacity: 0))
        }
    }
    fileprivate var target :AnyObject?
    fileprivate var action : Selector?
    fileprivate var refreshing: Bool = false
    fileprivate var canLoading :Bool = false
    fileprivate var hidding:Bool = false
    fileprivate var offsetY: CGFloat?

}
