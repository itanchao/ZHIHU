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
    @discardableResult
    static func showImageWithUrls(_ urls:[String], currentImg:String) -> BrowseImagesView {
        let browseImagesView = BrowseImagesView(frame: kScreenBounds)
        browseImagesView.initSubviews()
        UIApplication.shared.keyWindow?.addSubview(browseImagesView)
        browseImagesView.imageList = urls
        browseImagesView.imgUrl = currentImg
        return browseImagesView
    }
    /// 计算frame
    ///
    /// - parameter image: 网络图片
    fileprivate func calculateImageFrameWithImage(_ image:UIImage)  {
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
        getImageView().transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.2, animations: { 
            self.getImageView().transform = CGAffineTransform.identity
        }) 
    }
    @objc internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if imageList == nil {return}
        if imageList?.count == 1 {return}
        if changeFinished {return}
        if getScaleView().frame.equalTo(scrollView.frame){
            if (scrollView.contentOffset.y >  70){ self.changeImage(true)}
            if (scrollView.contentOffset.y < -70){ self.changeImage(false)}
        }
    }
    /// 切换图片成功标示
    fileprivate var changeFinished : Bool = false
    /// 切换图片
    ///
    /// - parameter next: 方向
    fileprivate func changeImage(_ next:Bool) {
        UIView.animate(withDuration: 0.5, animations: { 
            self.changeFinished = true
            var viewY:CGFloat = 0
            if next{ viewY = -kScreenHeight}else{viewY = kScreenHeight}
            self.getImageView().transform = CGAffineTransform(translationX: 0, y: viewY)
            }, completion: { (finished) in
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

        }) 
    }
    /// 移除当前浏览器
    fileprivate func removeView() {
        UIView.animate(withDuration: 0.2, animations: { 
            self.getImageView().transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.alpha = 0.5
            }, completion: { (finished) in
                self.removeFromSuperview()
                self.scrollView.removeFromSuperview()
        }) 
    }
    fileprivate func initSubviews() {
        self.backgroundColor = UIColor.black
        self.alpha = 0
        scrollView.addSubview(getScaleView())
        getScaleView().addSubview(getImageView())
        UIView .animate(withDuration: 0.2, animations: { 
            self.alpha = 0.8
        }) 
    }
    @objc internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scaleView
    }
    /// 当前图片
    fileprivate var currenteImgIndex : Int = 0
    fileprivate func getCurrenteImgIndex() -> Int {
        for i in 0 ... getImageList().count-1{
            if imgUrl! == getImageList()[i] {
                currenteImgIndex = i
                break
            }
        }
        return currenteImgIndex
    }
        /// 当前图片url
    fileprivate var imgUrl : String?{
        didSet{
            UIApplication.shared.keyWindow?.addSubview(scrollView)
            SDWebImageDownloader.shared().downloadImage(with: URL(string: imgUrl!), options: SDWebImageDownloaderOptions.init(rawValue: 0), progress: { (a, b, _) in
            }) { (icon, _, error, finished) in
                self.calculateImageFrameWithImage(icon!)
            }
//            SDWebImageDownloader.shared().downloadImage(with: URL(string: imgUrl!), options: SDWebImageOptions.init(rawValue: 0), progress: { (a, b) in }) { (icon, error, cacheType, finished, imgUrl) in
//                self.calculateImageFrameWithImage(icon)
//            }
        }
    }
    /// 图片列表
    fileprivate var imageList : [String]?
    fileprivate func getImageList() -> [String] {
        if imageList == nil {
            imageList = [imgUrl!]
        }
        return imageList!
    }
    fileprivate var scaleView : UIView?
    fileprivate func getScaleView() -> UIView {
        if scaleView == nil {
            let object = UIView(frame: self.scrollView.frame)
            let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BrowseImagesView.handleTapGesture))
            singleTapGestureRecognizer.numberOfTapsRequired = 1
            object.addGestureRecognizer(singleTapGestureRecognizer)
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BrowseImagesView.handleTapGesture))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            object.addGestureRecognizer(doubleTapGestureRecognizer)
            singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
            object.backgroundColor = UIColor.clear
            scaleView = object
        }
        return scaleView!
    }
    @objc fileprivate func handleTapGesture(_ sender:UITapGestureRecognizer)  {
        if sender.numberOfTapsRequired == 1 {
            if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
                removeView()
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                })
            }
            return
        }
        if sender.numberOfTapsRequired == 2 {
            UIView.animate(withDuration: 0.2, animations: {
                if self.scrollView.zoomScale <= 1.7{  self.scrollView.zoomScale = self.scrollView.maximumZoomScale}else{self.scrollView.zoomScale = self.scrollView.minimumZoomScale}
            })
        }
    }
    
    fileprivate var imageView : UIImageView?
    func getImageView() -> UIImageView {
        if imageView == nil {
            let object = UIImageView()
            object.clipsToBounds = true
            object.contentMode = .scaleAspectFill
            imageView = object
        }
        return imageView!
    }
    lazy fileprivate  var scrollView: UIScrollView = {
        let object = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: kScreenWidth, height: kScreenHeight)))
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
