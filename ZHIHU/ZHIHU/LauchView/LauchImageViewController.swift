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
    let data = UserDefaults.standard.object(forKey: Keys.launchimgData) as? Data ?? (try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "Default-568h@2x.png", ofType: "")!)))
}
extension LauchData{
    internal init(){
        let dic = UserDefaults.standard.object(forKey: Keys.launchKey) as? [String : Any] ?? ["":""]
        img = dic["img"] as? String ?? ""
        text = dic["text"]as? String ?? ""
    }
    func serialize() -> [String : Any] {
        return ["img":img,"text":text] 
    }
    init(dic:[String : AnyObject]) {
        img = dic["img"] as? String ?? ""
        text = dic["text"]as? String ?? ""
        Alamofire.request(img).responseData { (responseData) in
            guard responseData.result.error == nil else{
                print("失败")
                return
            }
            UserDefaults.standard.set(responseData.data, forKey: Keys.launchimgData)
            UserDefaults.standard.synchronize()
        }
    }
    /*!
     保存到沙盒
     */
    func save(){
        UserDefaults.standard.setValue(self.serialize(), forKey: Keys.launchKey)
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
        Alamofire.request(Urls.launchUrl).responseJSON
            { (response) in
                guard response.result.error == nil else{
                    printLog(response.result.error, logError: true)
                    return 
                }
                self.lauchData = LauchData(dic: response.result.value as? [String : Any] as [String : AnyObject]? ?? ["":"" as AnyObject])
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(launchImage)
        view.bringSubview(toFront: launchImage)
        view.addSubview(imageTitle)
        view.addSubview(logoImage)
        UIView.animate(withDuration: 3.0, animations: { () -> Void in
            self.launchImage.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: { (result) -> Void in
                self.view.removeFromSuperview()
        })
        updateLanunchImage()
    }
    // MARK:懒加载控件
    lazy fileprivate  var launchImage: UIImageView = {
        let launchImage = UIImageView(frame: kScreenBounds)
        launchImage.image = UIImage(data:self.lauchData.data!)
        return launchImage
    }()
    lazy fileprivate  var logoImage: UIImageView = {
        let logoImage = UIImageView(frame: CGRect(x: KWidth(95), y: kHeight(458), width: KWidth(128), height: kHeight(49)))
        logoImage.image = UIImage(named: "Login_Logo")
        return logoImage
    }()
    lazy fileprivate  var imageTitle: UILabel = {
        let imageTitle = UILabel()
        imageTitle.textColor = KwhiteColor
        imageTitle.font = UIFont.systemFont(ofSize: 14)
        imageTitle.text = self.lauchData.text
        imageTitle.sizeToFit()
        imageTitle.setCenterX(self.view.getCenterX())
        imageTitle.setY(self.view.getHeight() - 30)
        return imageTitle
    }()
}
