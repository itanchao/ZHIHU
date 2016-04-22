//
//  TCCircleChart.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/22.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit

class TCCircleChart: UIView {
    static func attachObserveToScrollView(crollView:UIScrollView,target:AnyObject,action:Selector) -> TCCircleChart {
        let circleView = TCCircleChart()
        circleView.scrollView = crollView
        circleView.target = target
        circleView.action = action
        circleView.backgroundColor = UIColor.clearColor()
        circleView.addSubview(circleView.activityView)
        return circleView
    }
    lazy private  var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView()
        activityView.hidesWhenStopped = true
        activityView.stopAnimating()
        return activityView
    }()
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath != "contentOffset" {return}
         offsetY = scrollView!.contentOffset.y + 20
        if hidding && offsetY >= 0 {
            hidding = false
            refreshing = false
            activityView.stopAnimating()
        }
        if refreshing {return}
        if offsetY! < -60 && offsetY! >= -90 && !scrollView!.dragging {
            refreshing = true
            activityView.startAnimating()
            UIControl().sendAction(action!, to: target, forEvent: .None)
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
    override func drawRect(rect: CGRect) {
        if scrollView?.contentOffset.y >= 0 || refreshing {return}
        let radius = (frame.size.width - 5) * 0.5
        let context2 = UIGraphicsGetCurrentContext()
        CGContextAddArc(context2, frame.size.width * 0.5, frame.size.width * 0.5, 0, 0, CGFloat(M_PI) * 2, 0)
        UIColor.lightGrayColor().set()
        CGContextStrokePath(context2)
        let context = UIGraphicsGetCurrentContext()
        let endAngle = CGFloat(-M_PI) / 30 * offsetY! - CGFloat(M_PI) * 1.5
        CGContextAddArc(context, frame.size.width * 0.5, frame.size.width * 0.5, radius, CGFloat(-M_PI) * 1.5, endAngle, 0)
        UIColor.whiteColor().set()
        CGContextStrokePath(context)
    }
    override var frame: CGRect{
        didSet{
            activityView.frame = bounds
        }
    }
    private var scrollView : UIScrollView?{
        didSet{
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [.New,.Old], context: UnsafeMutablePointer<Void>.alloc(0))
        }
    }
    private var target :AnyObject?
    private var action : Selector?
    private var refreshing: Bool = false
    private var canLoading :Bool = false
    private var hidding:Bool = false
    private var offsetY: CGFloat?

}
