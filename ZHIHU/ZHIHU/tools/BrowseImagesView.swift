//
//  BrowseImagesView.swift
//  ZHIHU
//
//  Created by tanchao on 16/5/7.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage
class BrowseImagesView: UIView,UIScrollViewDelegate {
    /// 图片浏览器
    ///
    /// - parameter urls:       网络图片数组
    /// - parameter currentImg: 当前图片数组
    ///
    static func showImageWithUrls(urls:[String], currentImg:String) -> BrowseImagesView {
        let browseImagesView = BrowseImagesView(frame: kScreenBounds)
        browseImagesView.initSubviews()
        UIApplication.sharedApplication().keyWindow?.addSubview(browseImagesView)
        browseImagesView.imageList = urls
        browseImagesView.imgUrl = currentImg
        return browseImagesView
    }
    /// 计算frame
    ///
    /// - parameter image: 网络图片
    private func calculateImageFrameWithImage(image:UIImage)  {
        self.getImageView().image = image
        let scaleX = scrollView.getWidth()/image.size.width
        let scaleY = scrollView.getHeight()/image.size.height
        if scaleX > scaleY {
            let imgViewWidth = image.size.width * scaleY
            getImageView().frame = CGRect(x: 0.5*(scrollView.getWidth()-imgViewWidth), y: 0, width: imgViewWidth, height: scrollView.getHeight())
        }else{
            let imgViewHeight = image.size.height*scaleX
            getImageView().frame = CGRect(x: 0, y: 0.5*(scrollView.getHeight()-imgViewHeight), width: scrollView.getWidth(), height: imgViewHeight)
        }
        getImageView().transform = CGAffineTransformMakeScale(0.7, 0.7)
        UIView.animateWithDuration(0.2) { 
            self.getImageView().transform = CGAffineTransformIdentity
        }
    }
    @objc internal func scrollViewDidScroll(scrollView: UIScrollView) {
        if imageList == nil {return}
        if imageList?.count == 1 {return}
        if changeFinished {return}
        if CGRectEqualToRect(getScaleView().frame, scrollView.frame){
            if (scrollView.contentOffset.y >  70){ self.changeImage(true)}
            if (scrollView.contentOffset.y < -70){ self.changeImage(false)}
        }
    }
    /// 切换图片成功标示
    private var changeFinished : Bool = false
    /// 切换图片
    ///
    /// - parameter next: 方向
    private func changeImage(next:Bool) {
        UIView.animateWithDuration(0.5, animations: { 
            self.changeFinished = true
            var viewY:CGFloat = 0
            if next{ viewY = -kScreenHeight}else{viewY = kScreenHeight}
            self.getImageView().transform = CGAffineTransformMakeTranslation(0, viewY)
            }) { (finished) in
                self.getImageView().removeFromSuperview()
                self.getScaleView().removeFromSuperview()
                self.imageView = nil
                self.scaleView = nil
                self.scrollView.addSubview(self.getScaleView())
                self.getScaleView().addSubview(self.getImageView())
                if next{self.currenteImgIndex = self.getCurrenteImgIndex()+1}else{self.currenteImgIndex = self.getCurrenteImgIndex()-1}
                if (self.currenteImgIndex  < 0 ){ self.currenteImgIndex = self.getImageList().count - 1}
                if (self.currenteImgIndex > (self.getImageList().count - 1))  {  self.currenteImgIndex = 0 }
                self.imgUrl = self.getImageList()[self.currenteImgIndex]
                self.changeFinished = false

        }
    }
    /// 移除当前浏览器
    private func removeView() {
        UIView.animateWithDuration(0.2, animations: { 
            self.getImageView().transform = CGAffineTransformMakeScale(0.7, 0.7)
            self.alpha = 0.5
            }) { (finished) in
                self.removeFromSuperview()
                self.scrollView.removeFromSuperview()
        }
    }
    private func initSubviews() {
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0
        scrollView.addSubview(getScaleView())
        getScaleView().addSubview(getImageView())
        UIView .animateWithDuration(0.2) { 
            self.alpha = 0.8
        }
    }
    @objc internal func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scaleView
    }
    /// 当前图片
    private var currenteImgIndex : Int = 0
    private func getCurrenteImgIndex() -> Int {
        for i in 0 ... getImageList().count-1{
            if imgUrl! == getImageList()[i] {
                currenteImgIndex = i
                break
            }
        }
        return currenteImgIndex
    }
        /// 当前图片url
    private var imgUrl : String?{
        didSet{
            UIApplication.sharedApplication().keyWindow?.addSubview(scrollView)
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgUrl!), options: SDWebImageOptions.init(rawValue: 0), progress: { (a, b) in }) { (icon, error, cacheType, finished, imgUrl) in
                self.calculateImageFrameWithImage(icon)
            }
        }
    }
    /// 图片列表
    private var imageList : [String]?
    private func getImageList() -> [String] {
        if imageList == nil {
            imageList = [imgUrl!]
        }
        return imageList!
    }
    private var scaleView : UIView?
    private func getScaleView() -> UIView {
        if scaleView == nil {
            let object = UIView(frame: self.scrollView.frame)
            let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BrowseImagesView.handleTapGesture))
            singleTapGestureRecognizer.numberOfTapsRequired = 1
            object.addGestureRecognizer(singleTapGestureRecognizer)
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BrowseImagesView.handleTapGesture))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            object.addGestureRecognizer(doubleTapGestureRecognizer)
            singleTapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGestureRecognizer)
            object.backgroundColor = UIColor.clearColor()
            scaleView = object
        }
        return scaleView!
    }
    @objc private func handleTapGesture(sender:UITapGestureRecognizer)  {
        if sender.numberOfTapsRequired == 1 {
            if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
                removeView()
            }else{
                UIView.animateWithDuration(0.2, animations: {
                    self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                })
            }
            return
        }
        if sender.numberOfTapsRequired == 2 {
            UIView.animateWithDuration(0.2, animations: {
                if self.scrollView.zoomScale <= 1.7{  self.scrollView.zoomScale = self.scrollView.maximumZoomScale}else{self.scrollView.zoomScale = self.scrollView.minimumZoomScale}
            })
        }
    }
    
    private var imageView : UIImageView?
    func getImageView() -> UIImageView {
        if imageView == nil {
            let object = UIImageView()
            object.clipsToBounds = true
            object.contentMode = .ScaleAspectFill
            imageView = object
        }
        return imageView!;
    }
    lazy private  var scrollView: UIScrollView = {
        let object = UIScrollView(frame: CGRect(origin: CGPointZero, size: CGSize(width: kScreenWidth, height: kScreenHeight)))
        object.showsVerticalScrollIndicator = false
        object.showsHorizontalScrollIndicator = false
        object.bouncesZoom = true
        object.delegate = self
        object.bounces = true
        object.alwaysBounceVertical = true
        object.minimumZoomScale = 1.0
        object.maximumZoomScale = 2.5
        return object
    }()

}
