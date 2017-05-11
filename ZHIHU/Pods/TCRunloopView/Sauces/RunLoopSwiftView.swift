//
//  TCRunLoopView.swift
//  TCRunLoopView
//
//  Created by tanchao on 16/4/19.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage
public protocol TCRunLoopViewDelegate: NSObjectProtocol, UIScrollViewDelegate {
    func runLoopViewDidClick(_ loopView:TCRunLoopView, didSelectRowAtIndex index: NSInteger)
    func runLoopViewDidScroll(_ loopView: TCRunLoopView, didScrollRowAtIndex index: NSInteger)
}
public struct LoopData {
    public var imageUrl : String = ""
    public var desc : String = ""
    public init(image:String = "",des:String = ""){
        imageUrl = image
        desc = des
    }
    //    序列化
    public func serialize() -> [String : Any] {
        return ["imageUrl":imageUrl ,"desc":desc]
    }
}
// MARK:变量与控件
public class TCRunLoopView: UIView {
    
    /// 代理
    public var delegate : TCRunLoopViewDelegate?
    
    /// 轮播间隔
    public var loopInterval : TimeInterval = 5{
        didSet{
            assert(loopInterval > 0, "请设置一个大于0的数 the value of loopInterVal must be greater than 0")
            if timer != nil {
                self.stop()
            }
            timer = self.getTime()
            self.runloopViewFire()
        }
    }
    
    /// 轮播数据
    public  var loopDataGroup : [LoopData] = []{
        didSet{
            setUpRunloopView()
            pageControl.numberOfPages = loopDataGroup.count
            currIndex = 0
        }
    }
    //    私有变量
    fileprivate var currIndex : Int = 0{
        didSet{
            pageControl.currentPage = currIndex
            delegate?.runLoopViewDidScroll(self, didScrollRowAtIndex: currIndex)
//            if (delegate != nil) && (delegate?.responds(to: #selector(delegate?.runLoopViewDidScroll(_:didScrollRowAtIndex:))))! {
//                delegate?.runLoopViewDidScroll!(self, didScrollRowAtIndex: currIndex)
//            }
        }
    }
    fileprivate var timer : Timer?
    // MARK:懒加载控件
    lazy fileprivate  var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        self.addSubview(view)
        return view
    }()
    lazy fileprivate  var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.hidesForSinglePage = true
        view.currentPageIndicatorTintColor = UIColor.white
        view.pageIndicatorTintColor = UIColor.black
        view.addTarget(self, action: #selector(TCRunLoopView.pageAction), for: .touchUpInside)
        self.insertSubview(view, aboveSubview: self.scrollView)
        return view
    }()
    lazy fileprivate  var leftImageView: RunloopCell = {
        let iconView = RunloopCell()
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy fileprivate  var centerImageView: RunloopCell = {
        let iconView = RunloopCell()
        iconView.addOnClickListener(self, action: #selector(TCRunLoopView.pageAction))
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy fileprivate  var rightImageView: RunloopCell = {
        let iconView = RunloopCell()
        self.scrollView.addSubview(iconView)
        return iconView
    }()
    lazy fileprivate  var singleImageView: RunloopCell = {
        let iconView = RunloopCell()
        iconView.addOnClickListener(self, action: #selector(TCRunLoopView.pageAction))
        self.scrollView.addSubview(iconView)
        return iconView
    }()
}
// MARK:布局
extension TCRunLoopView{
    override public func layoutSubviews() {
        if  loopDataGroup.count < 2 {
            singleImageView.frame = frame
        }else{
            leftImageView.frame = frame
            centerImageView.frame = CGRect(origin: CGPoint(x: leftImageView.frame.maxX, y: 0), size: frame.size)
            rightImageView.frame = CGRect(origin: CGPoint(x: centerImageView.frame.maxX, y: 0), size: frame.size)
            scrollView.bringSubview(toFront: centerImageView)
            scrollView.frame = frame
            pageControl.setCenterX(getCenterX())
            pageControl.setY(frame.maxY - 20)
        }
    }
}
// MARK:UIScrollViewDelegate
extension TCRunLoopView:UIScrollViewDelegate{
    @objc  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stop()
        if delegate != nil && (delegate?.responds(to: #selector(delegate!.scrollViewWillBeginDragging(_:))))! {
            delegate?.scrollViewWillBeginDragging!(scrollView)
        }
    }
    @objc  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        runloopViewFire()
        if delegate != nil && (delegate?.responds(to: #selector(delegate!.scrollViewDidEndDragging(_:willDecelerate:))))! {
            delegate?.scrollViewDidEndDragging!(scrollView, willDecelerate: decelerate)
        }
    }
    @objc  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadImage(scrollView.contentOffset.x)
        if delegate != nil && (delegate?.responds(to: #selector(delegate!.scrollViewDidScroll(_:))))! {
            delegate?.scrollViewDidScroll!(scrollView)
        }
    }
    fileprivate func loadImage(_ offX:CGFloat) {
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
        if timer == nil { return }
        if loopDataGroup.count < 2 { return }
        timer!.invalidate()
        timer = nil
    }
    func runloopViewFire() {
        if loopDataGroup.count < 2 { return }
        RunLoop.current.add(getTime(), forMode: RunLoopMode.defaultRunLoopMode)
    }
}
extension TCRunLoopView{
    fileprivate func setUpRunloopView() {
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
    fileprivate func mapImage(_ left:NSInteger,center:NSInteger,right:NSInteger) {
        scrollView.setContentOffset(CGPoint(x: bounds.width, y: 0), animated: false)
        leftImageView.loopData = loopDataGroup[left]
        centerImageView.loopData = loopDataGroup[center]
        rightImageView.loopData = loopDataGroup[right]
    }
    fileprivate func getTime()->Timer{
        if (timer == nil)  {
            timer = Timer.scheduledTimer(timeInterval: loopInterval, target: self, selector: #selector(TCRunLoopView.timeAction), userInfo: nil, repeats: true)
        }
        return timer!
    }
    @objc func pageAction() {
          delegate?.runLoopViewDidClick(self, didSelectRowAtIndex: currIndex)
//        if (delegate != nil) && (delegate?.responds(to:  #selector(delegate!.runLoopViewDidClick(_:didSelectRowAtIndex:)) ))!{
//            delegate?.runLoopViewDidClick!(self, didSelectRowAtIndex: currIndex)
//        }
    }
    @objc fileprivate func timeAction() {
        if loopDataGroup.count < 2 { return }
        scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x + bounds.width, y: 0), animated: true)
    }
}
// MARK:RunloopCell
class RunloopCell: UIView {
    var loopData : LoopData?{
        didSet{
            iconView.sd_setImage(with: URL(string: (loopData?.imageUrl)!))
            desLabel.text = loopData?.desc
        }
    }
    lazy fileprivate  var iconView: UIImageView = {
        let object = UIImageView()
        object.contentMode = .scaleAspectFill
        self.addSubview(object)
        return object
    }()
    lazy fileprivate  var desLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byCharWrapping
        label.sizeToFit()
        self.addSubview(label)
        return label
    }()
}
// MARK:布局
extension RunloopCell{
    override func layoutSubviews() {
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: nil, views: ["view" : iconView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: nil, views: ["view" : iconView]))
        desLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .bottom, relatedBy: .equal, toItem: iconView, attribute: .bottom, multiplier: 1, constant: -20))
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .left, relatedBy: .equal, toItem: iconView, attribute: .left, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: desLabel, attribute: .right, relatedBy: .equal, toItem: iconView, attribute: .right, multiplier: 1, constant: -20))
    }
}
// MARK:添加点击事件
extension RunloopCell {
    func addOnClickListener(_ target: AnyObject, action: Selector) {
        let gr = UITapGestureRecognizer(target: target, action: action)
        gr.numberOfTapsRequired = 1
        isUserInteractionEnabled = true
        addGestureRecognizer(gr)
    }
}
// MARK: - 设置farme相关
fileprivate extension UIView{
    func setX(_ x:CGFloat){
        var frame = self.frame
        frame.origin.x = x
        self.frame = frame
    }
    func setY(_ y:CGFloat){
        var frame = self.frame
        frame.origin.y = y
        self.frame = frame
    }
    func getX() ->CGFloat{
        return self.frame.origin.x
    }
    func getY() ->CGFloat{
        return self.frame.origin.y
    }
    func setCenterX(_ centerX:CGFloat){
        var center = self.center
        center.x = centerX
        self.center = center
    }
    func setCenterY(_ centerY:CGFloat){
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
    func setWidth(_ width:CGFloat){
        var frame = self.frame
        frame.size.width = width
        self.frame = frame
    }
    func setHeight(_ height:CGFloat){
        var frame = self.frame
        frame.size.height = height
        self.frame = frame
    }
    func getHeight()->CGFloat{
        return self.frame.size.height
    }
    func getWidth()->CGFloat{
        return self.frame.size.width
    }
    func setSize(_ size:CGSize){
        var frame = self.frame
        frame.size = size
        self.frame = frame
    }
    func getSize()->CGSize{
        return self.frame.size
    }
    func setOrigin(_ origin:CGPoint){
        var frame = self.frame
        frame.origin = origin
        self.frame = frame
    }
    func getOrigin()->CGPoint{
        return self.frame.origin
    }
}
public extension TCRunLoopViewDelegate{
    func runLoopViewDidClick(_ loopView:TCRunLoopView, didSelectRowAtIndex index: NSInteger){}
    func runLoopViewDidScroll(_ loopView: TCRunLoopView, didScrollRowAtIndex index: NSInteger){}
}

