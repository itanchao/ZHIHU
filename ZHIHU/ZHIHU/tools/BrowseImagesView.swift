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
    var imgUrl : String?{
        didSet{
            UIApplication.sharedApplication().keyWindow?.addSubview(scrollView)
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imgUrl!), options: SDWebImageOptions.init(rawValue: 0), progress: { (a, b) in }) { (icon, error, cacheType, finished, imgUrl) in
                self.calculateImageFrameWithImage(icon)
            }
        }
    }
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
    
    var changeFinished : Bool = false
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if imageList == nil {return}
        if imageList?.count == 1 {return}
        if changeFinished {return}
        if CGRectEqualToRect(getScaleView().frame, scrollView.frame){
            if (scrollView.contentOffset.y >  70){ self.changeImage(true)}
            if (scrollView.contentOffset.y < -70){ self.changeImage(false)}
        }
    }
        /// 当前图片
    var currenteImgIndex : Int = 0
    func getCurrenteImgIndex() -> Int {
        for i in 0 ... getImageList().count-1{
            if imgUrl! == getImageList()[i] {
                currenteImgIndex = i
                break
            }
        }
        return currenteImgIndex
    }
        /// 图片列表
    var imageList : [String]?
    func getImageList() -> [String] {
        if imageList == nil {
            imageList = [imgUrl!]
        }
        return imageList!
    }
    func changeImage(next:Bool) {
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
    func removeView() {
        UIView.animateWithDuration(0.2, animations: { 
            self.getImageView().transform = CGAffineTransformMakeScale(0.7, 0.7)
            self.alpha = 0.5
            }) { (finished) in
                self.removeFromSuperview()
                self.scrollView.removeFromSuperview()
        }
    }
    static func showImageWithUrls(urls:[String], currentImg:String) -> BrowseImagesView {
        let browseImagesView = BrowseImagesView(frame: kScreenBounds)
        UIApplication.sharedApplication().keyWindow?.addSubview(browseImagesView)
        browseImagesView.imageList = urls
        browseImagesView.imgUrl = currentImg
        return browseImagesView
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    func initSubviews() {
        self.backgroundColor = UIColor.blackColor()
        self.alpha = 0
        scrollView.addSubview(getScaleView())
        getScaleView().addSubview(getImageView())
        UIView .animateWithDuration(0.2) { 
            self.alpha = 0.8
        }
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return scaleView
    }
    var scaleView : UIView?
    
    func getScaleView() -> UIView {
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
    lazy private  var scrollView: UIScrollView = {
        let object = UIScrollView(frame: CGRect(origin: CGPointZero, size: CGSize(width: kScreenWidth, height: kScreenHeight-40)))
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
    var imageView : UIImageView?
    func getImageView() -> UIImageView {
        if imageView == nil {
            let object = UIImageView()
            object.clipsToBounds = true
            object.contentMode = .ScaleAspectFill
            imageView = object
        }
        return imageView!;
    }

}
