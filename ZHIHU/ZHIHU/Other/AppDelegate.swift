//
//  AppDelegate.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/12.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import Alamofire
// MARK:URL管理
struct Urls {
    static let launchUrl = "http://news-at.zhihu.com/api/4/start-image/1080*1776"
    static let  homeUrl = "http://news-at.zhihu.com/api/4/news/latest"
    static let  getMorehomedataUrl = "http://news-at.zhihu.com/api/4/news/before/"
    static let  detailStoryUrl = "http://news-at.zhihu.com/api/4/news/"
}
// MARK:静态变量
struct Keys {
    static let launchKey = "launchKey"
    static let launchimgData = "launchimgData"
}

// MARK:启动页展示
extension UIWindow{
    func showLauchPage(){
        let lauchVC = LauchImageViewController()
        self .addSubview(lauchVC.view);
    }
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: kScreenBounds)
        let rootVc = UINavigationController(rootViewController: HomePageController())
        rootVc.navigationBarHidden = true
        window?.rootViewController = rootVc;
        window?.makeKeyAndVisible()
        window?.scrollsToTop(true)
        window?.showLauchPage()
        return true
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
