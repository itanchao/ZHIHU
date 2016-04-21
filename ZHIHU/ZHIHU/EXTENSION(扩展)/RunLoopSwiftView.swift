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
struct LoopData {
    var imageUrl : String = ""
    var desc : String = ""
    init(image:String = "",des:String = ""){
        imageUrl = image
        desc = des
    }
}
class RunLoopSwiftView: UIView,UIScrollViewDelegate {
    var delegate : RunLoopSwiftViewDelegate?
    var loopDataGroup : [LoopData] = []{
        didSet{
            setUpRunloopView()
            pageControl.numberOfPages = loopDataGroup.count
        }
    }
    
    private var currIndex : Int = 0{
        didSet{
            pageControl.currentPage = currIndex
        }
    }
    private func setUpRunloopView() {
        if loopDataGroup.count < 2 {
            scrollView.contentSize = bounds.size
            singleImageView.frame = frame
            singleImageView.loopData = loopDataGroup[0]
        }else{
            scrollView.contentSize = CGSize(width: self.bounds.width * 3, height: 0)
            runloopViewFire()
            mapImage(loopDataGroup.count - 1, center: 0, right: 1)
        }
    }
    private func mapImage(left:NSInteger,center:NSInteger,right:NSInteger) {
        scrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false)
        leftImageView.loopData = loopDataGroup[left]
        centerImageView.loopData = loopDataGroup[center]
        rightImageView.loopData = loopDataGroup[right]
    }
    @objc internal func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        stop()
    }
    @objc internal func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        runloopViewFire()
    }
    func stop() {
        if loopDataGroup.count < 2 { return }
        getTime().invalidate()
        timer = nil
    }
    func runloopViewFire() {
        if loopDataGroup.count < 2 { return }
        NSRunLoop.currentRunLoop().addTimer(getTime(), forMode: NSDefaultRunLoopMode)
    }
    private var timer : NSTimer?
    private func getTime()->NSTimer{
        if (timer == nil)  {
            timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(RunLoopSwiftView.timeAction), userInfo: nil, repeats: true)
        }
        return timer!
    }
    @objc func pageAction() {
        delegate?.runLoopSwiftViewDidClick(self, didSelectRowAtIndex: currIndex)
    }
    override func layoutSubviews() {
        if  loopDataGroup.count < 2 {
           singleImageView.frame = frame
        }else{
            leftImageView.frame = frame
            centerImageView.frame = CGRect(origin: CGPoint(x: CGRectGetMaxX(leftImageView.frame), y: 0), size: frame.size)
            rightImageView.frame = CGRect(origin: CGPoint(x: CGRectGetMaxX(centerImageView.frame), y: 0), size: frame.size)
            scrollView.frame = frame
            pageControl.setCenterX(getCenterX())
            pageControl.setY(frame.maxY - 20)
        }
    }
    func timeAction() {
        if loopDataGroup.count < 2 { return }
        scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x + bounds.width, y: 0), animated: true)
    }
    @objc internal func scrollViewDidScroll(scrollView: UIScrollView) {
        loadImage(scrollView.contentOffset.x)
    }
    private func loadImage(offX:CGFloat) {
        if offX >= bounds.width * 2 {
            currIndex = currIndex + 1
            if currIndex == loopDataGroup.count - 1  {
                mapImage(currIndex - 1, center: currIndex, right: 0)
            }
            else if currIndex == loopDataGroup.count {
                currIndex = 0
                mapImage(loopDataGroup.count - 1, center: currIndex, right: currIndex+1)
            }
            else{
                mapImage(currIndex - 1, center: currIndex, right: currIndex+1)
            }
        }
        if offX <= 0 {
            currIndex = currIndex - 1
            if currIndex == 0 {
                mapImage(loopDataGroup.count-1, center: 0, right: 1)
            }else
                if currIndex == -1 {
                    currIndex = loopDataGroup.count - 1
                    mapImage(currIndex - 1, center: currIndex, right: 0)
                }else{
                    mapImage(currIndex - 1, center: currIndex, right: currIndex+1)
            }
        }
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
    lazy private  var leftImageView: ImageLabelView = {
        let iconView = ImageLabelView()
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy private  var centerImageView: ImageLabelView = {
        let iconView = ImageLabelView()
        iconView.addOnClickListener(self, action: #selector(RunLoopSwiftView.pageAction))
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy private  var rightImageView: ImageLabelView = {
        let iconView = ImageLabelView()
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy private  var singleImageView: ImageLabelView = {
        let iconView = ImageLabelView()
        iconView.addOnClickListener(self, action: #selector(RunLoopSwiftView.pageAction))
        self.scrollView.addSubview(iconView)
        return iconView
    }()
}
class ImageLabelView: UIView {
    var loopData : LoopData?{
        didSet{
            iconView.sd_setImageWithURL(NSURL(string: (loopData?.imageUrl)!))
            desLabel.text = loopData?.desc
        }
    }
    override func layoutSubviews() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : iconView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : iconView]))
        desLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .Bottom, relatedBy: .Equal, toItem: iconView, attribute: .Bottom, multiplier: 1, constant: -20))
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .Left, relatedBy: .Equal, toItem: iconView, attribute: .Left, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .Right, relatedBy: .Equal, toItem: iconView, attribute: .Right, multiplier: 1, constant: -20))
    }
    lazy private  var iconView: UIImageView = {
        let object = UIImageView()
        self.addSubview(object)
        return object
    }()
    lazy private  var desLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(20)
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignment.Left;
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping;
        label.sizeToFit()
        self.addSubview(label)
        return label
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
