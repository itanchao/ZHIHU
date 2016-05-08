//
//  DetailStoryViewController.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/13.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import Alamofire
struct Section {
    var  id : NSNumber
    var name : String
    var thumbnail : String
    init(dic:[String:AnyObject]){
        id = dic["id"] as? NSNumber ?? 0
        name = dic["name"] as? String  ?? ""
        thumbnail = dic["thumbnail"] as? String ?? ""
    }
    func serialize() -> [String : AnyObject] {
        return ["id":id,"name":name,"thumbnail":thumbnail];
    }
}
struct DetailStory {
    var body : String
    var css :[String]
    var ga_prefix : String
    var id : NSNumber
    var image : String
    var image_source : String
    var images : [String]
    var js :[String]
    var section : Section
    var share_url : String
    var title : String
    var type : Int
    //    var recommenders : String
    var htmlStr : String
    init(dict: [String : AnyObject]){
        body = dict["body"] as? String ?? ""
        css = dict["css"] as? [String] ?? []
        ga_prefix = dict["ga_prefix"] as? String ?? ""
        id = dict["id"] as? NSNumber ?? 0
        image = dict["image"] as? String ?? ""
        image_source = dict["image_source"] as? String ?? ""
        images = dict["images"] as? [String] ?? [""]
        js = dict["js"] as? [String] ?? [""]
        section = Section( dic: (dict["section"] as?[String: AnyObject] ?? [:]))
        share_url = dict["share_url"] as? String ?? ""
        title = dict["title"] as? String ?? ""
        type = dict["type"] as? Int ?? 0
        htmlStr = "<html><head><link rel=\"stylesheet\" href="+css[0]+"></head><body>"+body+"</body></html>"
    }
    func serialize() -> [String : AnyObject] {
        return ["body":body,"css":css,"ga_prefix":ga_prefix,"id":id,"image":image,"image_source":image_source,"images":images,"js":js,"section":section.serialize(),"share_url":share_url,"title":title,"type":type,"htmlStr":htmlStr]
    }
    static func getDetailStory(storyId:NSNumber)->Request{
        return Alamofire.request(.GET, Urls.detailStoryUrl+storyId.stringValue)
    }
}
class DetailStoryViewController: UIViewController,UIWebViewDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate {
    var storyID : NSNumber?{
        didSet{
            DetailStory.getDetailStory(storyID!).responseJSON { (responsData) in
                guard responsData.result.error == nil else{
                    printLog(responsData.result.error)
                    return
                }
                let detail = DetailStory(dict: responsData.result.value as? [String : AnyObject] ?? [:])
                self.webView.loadHTMLString(detail.htmlStr, baseURL: NSURL())
                self.headerView.sd_setImageWithURL(NSURL(string: detail.image))
            }
        }
    }
        /// 网页图片集合
    var webPageimageList:[String] = []
    
        /// ImageUrlprefix
    private var ImageUrlprefix:String = "imageurlprefix:"
    func getImageSrcJs() -> String {
        do {
            return try! String(contentsOfURL:NSBundle.mainBundle().URLForResource("tools.js", withExtension: nil)!, encoding: NSUTF8StringEncoding)
        }
    }
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
///    点击了其中一张图片
        if request.URLString.hasPrefix(ImageUrlprefix) {
            let iconUrl = (request.URLString as NSString).substringFromIndex(15)
            BrowseImagesView.showImageWithUrls(webPageimageList, currentImg: iconUrl)
            return false
        }
///     获取页面所有图片
        if request.URLString.hasPrefix("imagelist:") {
            webPageimageList = (request.URLString as NSString).substringFromIndex(10).componentsSeparatedByString(",")
            return false;
        }
        if request.URLString  == "about:blank"{
//            webView.scrollView.addSubview(webHeaderView)
            return true
        }
        print(request.URLString)
//        webHeaderView.removeFromSuperview()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        return true
    }
    func webViewDidFinishLoad(webView: UIWebView) {
         UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//        调整字号
        let str = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'"
        webView.stringByEvaluatingJavaScriptFromString(str)
        webView.stringByEvaluatingJavaScriptFromString(getImageSrcJs())
        webView.stringByEvaluatingJavaScriptFromString("getimageSrc('\(ImageUrlprefix)')")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view = webView
        navigationController?.interactivePopGestureRecognizer?.enabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        webHeaderView.refreshBlurViewForNewImage()
    }
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return false
        }
        return true
    }
    
    // MARK:懒加载控件
    lazy private  var webView: UIWebView = {
        let viewWeb = UIWebView()
        viewWeb.delegate = self
        return viewWeb
    }()
    lazy private  var headerView: UIImageView = {
        let  object = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, 223))
        object.contentMode = .ScaleAspectFill
        return object
    }()
    lazy private  var webHeaderView: ParallaxScrollView = {
        let object = (ParallaxScrollView.creatParallaxWebHeaderViewWithSubView(self.headerView, forSize: CGSize(width: kScreenWidth, height: 223), referView: self.webView))
        self.webView.scrollView.addSubview(object)
        return object
    }()

}

