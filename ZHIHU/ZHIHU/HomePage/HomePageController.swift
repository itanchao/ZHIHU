//
//  HomePageController.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/12.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import Alamofire
let rowHeight :CGFloat = 90.0
let sectionHeight :CGFloat = 35.0
let homeCellIdentifier:String = "HomeCell"
typealias Homeprotocol = protocol<SDCycleScrollViewDelegate,ParallaxHeaderViewDelegate>

// MARK:轮播图数据模型
struct Top_story{
    var image : String
    var ga_prefix : String
    var id : NSNumber
    var title : String
    var type : Int
    init(dic:[String : AnyObject]) {
        image = dic["image"] as? String ?? ""
        ga_prefix = dic["ga_prefix"] as? String ?? ""
        id = dic["id"] as? NSNumber ?? 0
        title = dic["title"] as? String ?? ""
        type = dic["type"] as? Int ?? 0
    }
//    序列化
    func serialize() -> [String : AnyObject] {
        return ["image":image,"ga_prefix":ga_prefix,"id":id,"title":title,"type":type];
    }
}
// MARK:cell数据模型
struct Story {
    var images:[String]
    var type : Int
    var id : NSNumber
    var ga_prefix : String
    var title : String
    init(dict:[String : AnyObject]) {
        images = dict["images"] as? [String] ?? [""]
        type = dict["type"] as? Int ?? 0
        id = dict["id"] as? NSNumber ?? 0
        ga_prefix = dict["ga_prefix"] as? String ?? ""
        title = dict["title"] as? String ?? ""
    }
    func serialize() -> [String : AnyObject] {
        return ["images":images,"type":type,"id":id,"ga_prefix":ga_prefix,"title":title];
    }
}
// MARK:控制器
class HomePageController: UITableViewController,Homeprotocol {
    var top_stories : [Top_story] = []{
        didSet{
            headerView.titlesGroup = top_stories.map { (top)  in top.title }
            headerView.imageURLStringsGroup = top_stories.map { (top)  in top.image }
        }
    }
    var stories : [Story] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        //将其添加到ParallaxView
        let headerSubview: ParallaxHeaderView = ParallaxHeaderView.parallaxHeaderViewWithSubView(headerView, forSize: CGSize(width: tableView.frame.width, height: 154)) as! ParallaxHeaderView
        headerSubview.delegate  = self
        //将ParallaxView设置为tableHeaderView
        tableView.tableHeaderView = headerSubview
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        prepareForData()
    }
    func prepareForData() {
        Alamofire.request(.GET, Urls.homeUrl).responseJSON { (resultData) in
            guard resultData.result.error == nil else{
                print("网络失败")
                return
            }
            let top_stories = resultData.result.value!["top_stories"] as? [[String:AnyObject]] ?? [[:]]
            self.top_stories = top_stories.map({ (dic) in Top_story(dic:dic)})
            let stories = resultData.result.value!["stories"] as? [[String:AnyObject]] ?? [[:]]
            self.stories = stories.map({ (dic) in Story(dict:dic)})
            self.tableView.reloadData()
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(homeCellIdentifier) as? HomePageCell
        if cell == nil {
            cell = HomePageCell(style: .Default, reuseIdentifier: homeCellIdentifier)
        }
        cell?.story = stories[indexPath.item]
//        cell!.backgroundColor = Color("#343434")
        return cell!
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let top = stories[indexPath.item]
        let detailVc = DetailStoryViewController()
        detailVc.storyID = top.id
        navigationController?.pushViewController(detailVc, animated: true)
    }
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    override func  scrollViewDidScroll(scrollView: UIScrollView) {
        //Parallax效果
        guard scrollView == tableView else{
            printLog("hahahah", logError: true)
            return
        }
        let header = tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        header.delegate = self
        tableView.tableHeaderView = header
    }
    // MARK:SDCycleScrollViewDelegate
    func cycleScrollView(cycleScrollView: SDCycleScrollView!, didSelectItemAtIndex index: Int) {
        let top = top_stories[index]
        let detailVc = DetailStoryViewController()
        detailVc.storyID = top.id
        navigationController?.pushViewController(detailVc, animated: true)
    }
    
    // MARK: ParallaxHeaderViewDelegate
    func lockDirection() {
        tableView.contentOffset.y = -154
    }
    // MARK:懒加载headerView
    lazy private  var headerView: SDCycleScrollView = {
        let runloopView = SDCycleScrollView(frame: CGRect(origin: CGPointZero, size: CGSize(width: self.tableView.frame.width, height: 154)), imageURLStringsGroup: nil)
        runloopView.infiniteLoop = true
        runloopView.delegate = self
        runloopView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated
        runloopView.autoScrollTimeInterval = 3.0;
        runloopView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic
        runloopView.titleLabelTextFont = UIFont(name: "STHeitiSC-Medium", size: 21)
        runloopView.titleLabelBackgroundColor = UIColor.clearColor()
        runloopView.titleLabelHeight = 60
        //alpha在未设置的状态下默认为0
        runloopView.titleLabelAlpha = 1
        return runloopView
    }()
}
