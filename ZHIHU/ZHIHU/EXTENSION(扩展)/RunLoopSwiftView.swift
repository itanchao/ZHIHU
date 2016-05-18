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
    //    序列化
    func serialize() -> [String : AnyObject] {
        return ["imageUrl":imageUrl,"desc":desc]
    }
}
// MARK:变量与控件
class RunLoopSwiftView: UIView {
    var delegate : RunLoopSwiftViewDelegate?
    var loopDataGroup : [LoopData] = []{
        didSet{
            setUpRunloopView()
            pageControl.numberOfPages = loopDataGroup.count
        }
    }
//    私有变量
    private var currIndex : Int = 0{
        didSet{
            pageControl.currentPage = currIndex
        }
    }
    private var timer : NSTimer?
// MARK:懒加载控件
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
        view.currentPageIndicatorTintColor = UIColor.whiteColor()
        view.pageIndicatorTintColor = UIColor.blackColor()
        view.addTarget(self, action: #selector(RunLoopSwiftView.pageAction), forControlEvents: .TouchUpInside)
        self.insertSubview(view, aboveSubview: self.scrollView)
        return view
    }()
    lazy private  var leftImageView: RunloopCell = {
        let iconView = RunloopCell()
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy private  var centerImageView: RunloopCell = {
        let iconView = RunloopCell()
        iconView.addOnClickListener(self, action: #selector(RunLoopSwiftView.pageAction))
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy private  var rightImageView: RunloopCell = {
        let iconView = RunloopCell()
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy private  var singleImageView: RunloopCell = {
        let iconView = RunloopCell()
        iconView.addOnClickListener(self, action: #selector(RunLoopSwiftView.pageAction))
        self.scrollView.addSubview(iconView)
        return iconView
    }()
}
// MARK:布局
extension RunLoopSwiftView{
    internal override func layoutSubviews() {
        if  loopDataGroup.count < 2 {
            singleImageView.frame = frame
        }else{
            leftImageView.frame = frame
            centerImageView.frame = CGRect(origin: CGPoint(x: CGRectGetMaxX(leftImageView.frame), y: 0), size: frame.size)
            rightImageView.frame = CGRect(origin: CGPoint(x: CGRectGetMaxX(centerImageView.frame), y: 0), size: frame.size)
            scrollView.bringSubviewToFront(centerImageView)
            scrollView.frame = frame
            pageControl.setCenterX(getCenterX())
            pageControl.setY(frame.maxY - 20)
        }
    }
}
// MARK:UIScrollViewDelegate
extension RunLoopSwiftView:UIScrollViewDelegate{
    @objc internal func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        stop()
    }
    @objc internal func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        runloopViewFire()
    }
    @objc internal func scrollViewDidScroll(scrollView: UIScrollView) {
        loadImage(scrollView.contentOffset.x)
    }
    private func loadImage(offX:CGFloat) {
        if offX >= bounds.width * 2
        {
            currIndex = currIndex + 1
            if currIndex == loopDataGroup.count - 1
            {
                mapImage(currIndex - 1, center: currIndex, right: 0)
            }
            else if currIndex == loopDataGroup.count
            {
                currIndex = 0
                mapImage(loopDataGroup.count - 1, center: currIndex, right: currIndex+1)
            }else
            {
                mapImage(currIndex - 1, center: currIndex, right: currIndex+1)
            }
        }
        if offX <= 0
        {
            currIndex = currIndex - 1
            if currIndex == 0
            {
                mapImage(loopDataGroup.count-1, center: 0, right: 1)
            }
            else if currIndex == -1
            {
                currIndex = loopDataGroup.count - 1
                mapImage(currIndex - 1, center: currIndex, right: 0)
            }else
            {
                mapImage(currIndex - 1, center: currIndex, right: currIndex+1)
            }
        }
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
}
extension RunLoopSwiftView{
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
    private func getTime()->NSTimer{
        if (timer == nil)  {
            timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(RunLoopSwiftView.timeAction), userInfo: nil, repeats: true)
        }
        return timer!
    }
    @objc func pageAction() {
        delegate?.runLoopSwiftViewDidClick(self, didSelectRowAtIndex: currIndex)
    }
    @objc private func timeAction() {
        if loopDataGroup.count < 2 { return }
        scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x + bounds.width, y: 0), animated: true)
    }
}
// MARK:RunloopCell
class RunloopCell: UIView {
    var loopData : LoopData?{
        didSet{
            iconView.sd_setImageWithURL(NSURL(string: (loopData?.imageUrl)!))
            desLabel.text = loopData?.desc
        }
    }
    lazy private  var iconView: UIImageView = {
        let object = UIImageView()
        object.contentMode = .ScaleAspectFill
        self.addSubview(object)
        return object
    }()
    lazy private  var desLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(20)
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 0
        label.textAlignment = .Left
        label.lineBreakMode = .ByCharWrapping
        label.sizeToFit()
        self.addSubview(label)
        return label
    }()
}
// MARK:布局
extension RunloopCell{
    override func layoutSubviews() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: .AlignAllBaseline, metrics: nil, views: ["view" : iconView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: .AlignAllBaseline, metrics: nil, views: ["view" : iconView]))
        desLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .Bottom, relatedBy: .Equal, toItem: iconView, attribute: .Bottom, multiplier: 1, constant: -20))
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .Left, relatedBy: .Equal, toItem: iconView, attribute: .Left, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .Right, relatedBy: .Equal, toItem: iconView, attribute: .Right, multiplier: 1, constant: -20))
    }
}
// MARK:添加点击事件
extension RunloopCell {
     func addOnClickListener(target: AnyObject, action: Selector) {
        let gr = UITapGestureRecognizer(target: target, action: action)
        gr.numberOfTapsRequired = 1
        userInteractionEnabled = true
        addGestureRecognizer(gr)
    }
}
