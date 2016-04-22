//
//  LauchImageViewController.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/12.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit

import Alamofire

// MARK: 数据模型
struct LauchData{
    var img : String
    var text : String
    let data = NSUserDefaults.standardUserDefaults().objectForKey(Keys.launchimgData) as? NSData ?? NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("Default-568h@2x.png", ofType: "")!)
}
extension LauchData{
    internal init(){
        let dic = NSUserDefaults.standardUserDefaults().objectForKey(Keys.launchKey) as? [String : AnyObject] ?? ["":""]
        img = dic!["img"] as? String ?? ""
        text = dic!["text"]as? String ?? ""
    }
    func serialize() -> [String : AnyObject] {
        return ["img":img,"text":text];
    }
    init(dic:[String : AnyObject]) {
        img = dic["img"] as? String ?? ""
        text = dic["text"]as? String ?? ""
        Alamofire.request(.GET, img).responseData { (responseData) in
            guard responseData.result.error == nil else{
                print("失败")
                return
            }
            NSUserDefaults.standardUserDefaults().setObject(responseData.data, forKey: Keys.launchimgData)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    /*!
     保存到沙盒
     */
    func save(){
        NSUserDefaults.standardUserDefaults().setValue(self.serialize(), forKey: Keys.launchKey)
    }
}
class LauchImageViewController: UIViewController,Storage {
    var  lauchData  = LauchData(){
        didSet{
            lauchData.save()
        }
    }
    // MARK:网络请求
    func updateLanunchImage(){
        Alamofire.request(.GET, Urls.launchUrl).responseJSON
            { (response) in
                guard response.result.error == nil else{
                    printLog(response.result.error, logError: true)
                    return;
                }
                self.lauchData = LauchData(dic: response.result.value as? [String : AnyObject] ?? ["":""])
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(launchImage)
        view.bringSubviewToFront(launchImage)
        view.addSubview(imageTitle)
        view.addSubview(logoImage)
        UIView.animateWithDuration(3.0, animations: { () -> Void in
            self.launchImage.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }, completion: { (result) -> Void in
                self.view.removeFromSuperview()
        })
        updateLanunchImage()
    }
    // MARK:懒加载控件
    lazy private  var launchImage: UIImageView = {
        let launchImage = UIImageView(frame: kScreenBounds)
        launchImage.image = UIImage(data:self.lauchData.data!)
        return launchImage
    }()
    lazy private  var logoImage: UIImageView = {
        let logoImage = UIImageView(frame: CGRect(x: KWidth(95), y: kHeight(458), width: KWidth(128), height: kHeight(49)))
        logoImage.image = UIImage(named: "Login_Logo")
        return logoImage
    }()
    lazy private  var imageTitle: UILabel = {
        let imageTitle = UILabel()
        imageTitle.textColor = KwhiteColor
        imageTitle.font = UIFont.systemFontOfSize(14)
        imageTitle.text = self.lauchData.text
        imageTitle.sizeToFit()
        imageTitle.setCenterX(self.view.getCenterX())
        imageTitle.setY(self.view.getHeight() - 30)
        return imageTitle
    }()
}
