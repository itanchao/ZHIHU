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
struct SectionModel {
    var date : String?
    var stories : [Story]=[]
    var top_stories : [Top_story]=[]
    init(dict:[String : AnyObject]) {
        date = dict["date"] as? String ?? ""
        let top_storieslist = dict["top_stories"] as? [[String:AnyObject]] ?? [[:]]
        top_stories = top_storieslist.map({ (dic) in Top_story(dic:dic)})
        let storieslist = dict["stories"] as? [[String:AnyObject]] ?? [[:]]
        stories = storieslist.map({ (dic) in Story(dict:dic)})
        }
    }
// MARK:控制器
class HomePageController: UITableViewController,Homeprotocol {
    var sectionModels : [SectionModel] = []
        {
        didSet{
            guard sectionModels.count == 0 else{
                headerView.titlesGroup = sectionModels[0].top_stories.map { (top)  in top.title }
                headerView.imageURLStringsGroup = sectionModels[0].top_stories.map { (top)  in top.image }
                return

            }
        }
    }
    var loading :Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
//        self.automaticallyAdjustsScrollViewInsets = false
        //将其添加到ParallaxView
        let headerSubview: ParallaxHeaderView = ParallaxHeaderView.parallaxHeaderViewWithSubView(headerView, forSize: CGSize(width: tableView.frame.width, height: 154)) as! ParallaxHeaderView
        headerSubview.delegate  = self
        //将ParallaxView设置为tableHeaderView
        tableView.tableHeaderView = headerSubview
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        loadNewData()
    }
    func loadNewData() {
        guard loading else{
            loading = true
            Alamofire.request(.GET, Urls.homeUrl).responseJSON { (resultData) in
                guard resultData.result.error == nil else{
                    print("网络失败")
                    return
                }
                self.sectionModels.removeAll()
                let datalist = resultData.result.value as? [String:AnyObject] ?? [:]
                self.sectionModels.append(SectionModel(dict: datalist))
                self.tableView.reloadData()
                self.loading = false
            }
            return
        }
    }
    func loadMoreData() {
    guard loading else{
        loading = true
        let date = sectionModels.last?.date
        Alamofire.request(.GET, Urls.getMorehomedataUrl+date!).responseJSON { (resultData) in
            guard resultData.result.error == nil else{
                print("网络失败")
                return
            }
            let datalist = resultData.result.value as? [String:AnyObject] ?? [:]
            self.sectionModels.append(SectionModel(dict: datalist))
            self.tableView.reloadData()
//            self.tableView.reloadSections(NSIndexSet(index: self.sectionModels.count-2), withRowAnimation: UITableViewRowAnimation.Fade)
//            self.tableView.insertSections(NSIndexSet(index: self.sectionModels.count-1), withRowAnimation: UITableViewRowAnimation.Fade)
            self.loading = false
        }
        return
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(homeCellIdentifier) as? HomePageCell
        if cell == nil {
            cell = HomePageCell(style: .Default, reuseIdentifier: homeCellIdentifier)
        }
        cell?.story = sectionModels[indexPath.section].stories[indexPath.item]
        return cell!
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionModels.count
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].stories.count
    }
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        
//        return section>0 ? sectionModels[section].date : nil
//    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headerView;
        }else{
            var titleView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("titleView")
            if titleView == nil {
                titleView = UITableViewHeaderFooterView(reuseIdentifier: "titleView")
            }
//            titleView?.title = sectionModels[section].date
            titleView?.textLabel?.text = sectionModels[section].date
        return titleView
        }
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 64
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let top = sectionModels[indexPath.section].stories[indexPath.item]
        let detailVc = DetailStoryViewController()
        detailVc.storyID = top.id
        navigationController!.pushViewController(detailVc, animated: true)
    }
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    override func  scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - 1.5 * kScreenHeight {
            loadMoreData()
        }
        if scrollView.contentOffset.y < -150 {
            loadNewData()
        }
        
        navigationController?.navigationBarHidden = !(scrollView.contentOffset.y > 154)
        self.title = "今日热闻"
        navigationController?.navigationBar.backgroundColor = UIColor.blueColor()
        print(scrollView.contentOffset.y)
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
        
        let top = sectionModels[0].top_stories[index]
        printLog(top, logError: true)
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