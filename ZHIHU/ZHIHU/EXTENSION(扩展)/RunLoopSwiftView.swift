//
//  RunLoopSwiftView.swift
//  RunloopSwiftView
//
//  Created by tanchao on 16/4/19.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage
protocol RunLoopSwiftViewDelegate {
    func runLoopSwiftViewDidClick(loopView: RunLoopSwiftView, didSelectRowAtIndex index: NSInteger)
}
class RunLoopSwiftView: UIView,UIScrollViewDelegate {
    var delegate : RunLoopSwiftViewDelegate?
    
    var urls : [String] = []{
        didSet{
            setUpRunloopView()
            pageControl.numberOfPages = urls.count
        }
    }
    private var currIndex : Int = 0{
        didSet{
            pageControl.currentPage = currIndex
        }
    }
    private func setUpRunloopView() {
        if urls.count < 2 {
            scrollView.contentSize = bounds.size
            let iconView = UIImageView()
            scrollView.addSubview(iconView)
            iconView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : iconView]))
            scrollView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : iconView]))
            iconView.sd_setImageWithURL(NSURL(string: urls[0]))
            iconView.addOnClickListener(self, action: #selector(RunLoopSwiftView.pageAction))
        }else{
            layOutImageViews()
            runloopViewFire()
            mapImage(urls.count - 1, center: 0, right: 1)
        }
    }
    func mapImage(left:NSInteger,center:NSInteger,right:NSInteger) {
        scrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false)
        leftImageView.sd_setImageWithURL(NSURL(string: urls[left]))
        centerImageView.sd_setImageWithURL(NSURL(string: urls[center]))
        rightImageView.sd_setImageWithURL(NSURL(string: urls[right]))
        
    }
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        stop()
    }
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        runloopViewFire()
    }
    func stop() {
        if urls.count < 2 { return }
        getTime().invalidate()
        timer = nil
    }
    func runloopViewFire() {
        if urls.count < 2 { return }
        NSRunLoop.currentRunLoop().addTimer(getTime(), forMode: NSDefaultRunLoopMode)
    }
    var timer : NSTimer?
    func getTime()->NSTimer{
        if (timer == nil)  {
            timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(RunLoopSwiftView.timeAction), userInfo: nil, repeats: true)
        }
        return timer!
    }
    @objc func pageAction() {
        delegate?.runLoopSwiftViewDidClick(self, didSelectRowAtIndex: currIndex)
    }
    override func layoutSubviews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: self.bounds.width * 3, height: 0)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : scrollView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : scrollView]))
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: -0.005 * bounds.height))
        print(-0.005 * bounds.height)
        
    }
    func timeAction() {
        if urls.count < 2 { return }
        scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x + bounds.width, y: 0), animated: true)
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        loadImage(scrollView.contentOffset.x)
    }
    func loadImage(offX:CGFloat) {
        if offX >= bounds.width * 2 {
            currIndex = currIndex + 1
            if currIndex == urls.count - 1  {
                mapImage(currIndex - 1, center: currIndex, right: 0)
            }
            else if currIndex == urls.count {
                currIndex = 0
                mapImage(urls.count - 1, center: currIndex, right: currIndex+1)
            }
            else{
                mapImage(currIndex - 1, center: currIndex, right: currIndex+1)
            }
        }
        if offX <= 0 {
            currIndex = currIndex - 1
            if currIndex == 0 {
                mapImage(urls.count-1, center: 0, right: 1)
            }else
                if currIndex == -1 {
                    currIndex = urls.count - 1
                    mapImage(currIndex - 1, center: currIndex, right: 0)
                }else{
                    mapImage(currIndex - 1, center: currIndex, right: currIndex+1)
            }
        }
    }
    func layOutImageViews(){
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: leftImageView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: leftImageView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: leftImageView, attribute: .Left, relatedBy: .Equal, toItem: scrollView, attribute: .Left, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: leftImageView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1, constant: 0))
        
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: centerImageView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: centerImageView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: centerImageView, attribute: .Left, relatedBy: .Equal, toItem: leftImageView, attribute: .Right, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: centerImageView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1, constant: 0))
        
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: rightImageView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: rightImageView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: rightImageView, attribute: .Left, relatedBy: .Equal, toItem: centerImageView, attribute: .Right, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: rightImageView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1, constant: 0))
        
    }
    lazy private  var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.pagingEnabled = true
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        self.addSubview(view)
        return view
    }()
    lazy private  var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.hidesForSinglePage = true
        view.currentPageIndicatorTintColor = UIColor.redColor()
        view.pageIndicatorTintColor = UIColor.blackColor()
        view.addTarget(self, action: #selector(RunLoopSwiftView.pageAction), forControlEvents: .TouchUpInside)
        self.insertSubview(view, aboveSubview: self.scrollView)
        return view
    }()
    lazy private  var leftImageView: UIImageView = {
        let iconView = UIImageView()
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy private  var centerImageView: UIImageView = {
        let iconView = UIImageView()
        iconView.addOnClickListener(self, action: #selector(RunLoopSwiftView.pageAction))
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy private  var rightImageView: UIImageView = {
        let iconView = UIImageView()
        self.scrollView.addSubview(iconView)
        return iconView
    }()
}
extension UIView {
    func addOnClickListener(target: AnyObject, action: Selector) {
        let gr = UITapGestureRecognizer(target: target, action: action)
        gr.numberOfTapsRequired = 1
        userInteractionEnabled = true
        addGestureRecognizer(gr)
    }
}
