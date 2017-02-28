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
    var id   : NSNumber
    var name : String
    var thumbnail : String
    init(dic:[String:AnyObject]){
        id = dic["id"] as? NSNumber ?? 0
        name = dic["name"] as? String  ?? ""
        thumbnail = dic["thumbnail"] as? String ?? ""
    }
    func serialize() -> [String : Any] {
        return ["id":id,"name":name,"thumbnail":thumbnail]
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
    var htmlStr : String
}
extension DetailStory{
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
    func serialize() -> [String : Any] {
        return ["body":body,"css":css,"ga_prefix":ga_prefix,"id":id,"image":image,"image_source":image_source,"images":images,"js":js,"section":section.serialize(),"share_url":share_url,"title":title,"type":type,"htmlStr":htmlStr]
    }
    static func getDetailStory(_ storyId:NSNumber)->DataRequest{
        return Alamofire.request(Urls.detailStoryUrl+storyId.stringValue)
    }
}
class DetailStoryViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view = webView
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webHeaderView.refreshBlurViewForNewImage()
    }
    var storyID : NSNumber?{
        didSet{
            DetailStory.getDetailStory(storyID!).responseJSON { (responsData) in
                guard responsData.result.error == nil else{
                    printLog(responsData.result.error)
                    return
                }
                let detail = DetailStory(dict: responsData.result.value as? [String : AnyObject] ?? [:])
                self.webView.loadHTMLString(detail.htmlStr, baseURL: URL(string: ""))
                self.headerView.sd_setImage(with: URL(string: detail.image))
            }
        }
    }
    ///     网页图片集合
    var webPageimageList:[String] = []
    ///     ImageUrlprefix
    fileprivate var ImageUrlprefix:String = "imageurlprefix:"
    ///     webJS方法
    let ImageSrc_javascript : String = try! String(contentsOf:Bundle.main.url(forResource: "tools.js", withExtension: nil)!, encoding: String.Encoding.utf8)
    // MARK:懒加载控件
    lazy fileprivate  var webView: UIWebView = {
        let viewWeb = UIWebView()
        viewWeb.delegate = self
        return viewWeb
    }()
    lazy fileprivate  var headerView: UIImageView = {
        let  object = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 223))
        object.contentMode = .scaleAspectFill
        return object
    }()
    lazy fileprivate  var webHeaderView: ParallaxScrollView = {
        let object = (ParallaxScrollView.creatParallaxWebHeaderViewWithSubView(self.headerView, forSize: CGSize(width: kScreenWidth, height: 223), referView: self.webView))
        self.webView.scrollView.addSubview(object)
        return object
    }()
}
// MARK:UIGestureRecognizerDelegate
extension DetailStoryViewController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return false
        }
        return true
    }
}
// MARK:UIWebViewDelegate
extension DetailStoryViewController:UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        ///     加载本地html
        if request.url!.absoluteString  == "about:blank"{return true}
        ///     获取页面所有图片
        if request.url!.absoluteString.hasPrefix("imagelist:") {
            webPageimageList = (request.url!.absoluteString as NSString).substring(from: 10).components(separatedBy: ",")
            return false
        }
        ///    点击了其中一张图片
        if request.url!.absoluteString.hasPrefix(ImageUrlprefix) {
            let iconUrl = (request.url!.absoluteString as NSString).substring(from: 15)
            BrowseImagesView.showImageWithUrls(webPageimageList, currentImg: iconUrl)
            return false
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return true
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        ///     调整字号
        let str = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '100%'"
        webView.stringByEvaluatingJavaScript(from: str)
        webView.stringByEvaluatingJavaScript(from: ImageSrc_javascript)
        webView.stringByEvaluatingJavaScript(from: "getimageSrc('\(ImageUrlprefix)')")
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print(error)
    }
    func getImageSrcJs() -> String {
        do {
            return try! String(contentsOf:Bundle.main.url(forResource: "tools.js", withExtension: nil)!, encoding: String.Encoding.utf8)
        }
    }
}

