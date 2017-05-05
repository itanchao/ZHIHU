//
//  TCCircleChart.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/22.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

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
        context2?.addArc(center: CGPoint(x: frame.size.width*0.5, y: frame.size.width*0.5), radius: 0, startAngle: .pi * 2, endAngle: .pi * 2, clockwise: false)
        UIColor.lightGray.set()
        context2?.strokePath()
        let context = UIGraphicsGetCurrentContext()
        let endAngle = -.pi / 30 * offsetY! - .pi * 1.5
        context?.addArc(center: CGPoint(x: frame.size.width * 0.5, y: frame.size.width * 0.5), radius: radius, startAngle:  -.pi * 1.5, endAngle: endAngle, clockwise: false)
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
        }
    }
    fileprivate var target :AnyObject?
    fileprivate var action : Selector?
    fileprivate var refreshing: Bool = false
    fileprivate var canLoading :Bool = false
    fileprivate var hidding:Bool = false
    fileprivate var offsetY: CGFloat?

}
