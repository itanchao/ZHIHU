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
typealias Homeprotocol = protocol<RunLoopSwiftViewDelegate,UITableViewDelegate,UITableViewDataSource>

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
class HomePageController: UIViewController,Homeprotocol {
    var sectionModels : [SectionModel] = []
        {
        didSet{
            guard sectionModels.count == 0 else{
                headerView.loopDataGroup = sectionModels[0].top_stories.map { (top)  in LoopData(image: top.image, des: top.title) }
                criticaloffSetY =  CGFloat(152) + CGFloat(sectionModels[0].stories.count * 101) - 20
                return
            }
        }
    }
    var loading :Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(navBar)
        navBar.backgroundColor = UIColor.clearColor()
        view.addSubview(barButtonItem)
        view.addSubview(naviTitle)
        naviTitle.setCenterY(44)
        naviTitle.setCenterX(view.getCenterX())
        tableView.showsVerticalScrollIndicator = false
        loadNewData()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        (tableView.tableHeaderView as! ParallaxScrollView).refreshBlurViewForNewImage()
    }
    func revealToggle(sender:UIButton) {
        print("------------")
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
//            self.tableView.reloadData()
            self.tableView.insertSections(NSIndexSet(index: self.sectionModels.count - 1), withRowAnimation: UITableViewRowAnimation.Fade)
            self.loading = false
        }
        return
        }
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(homeCellIdentifier) as? HomePageCell
        if cell == nil {
            cell = HomePageCell(style: .Default, reuseIdentifier: homeCellIdentifier)
        }
        cell?.story = sectionModels[indexPath.section].stories[indexPath.item]
        return cell!
    }
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionModels.count
    }
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].stories.count
    }
     func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headerView;
        }else{
            let titleView = HomePageHeaderView.homePageHeaderViewWithTableView(tableView)
            titleView.date = sectionModels[section].date
        return titleView
        }
    }
     func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 44
    }
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let top = sectionModels[indexPath.section].stories[indexPath.item]
        let detailVc = DetailStoryViewController()
        detailVc.storyID = top.id
        navigationController!.pushViewController(detailVc, animated: true)
    }
    func runLoopSwiftViewDidClick(loopView: RunLoopSwiftView, didSelectRowAtIndex index: NSInteger) {
        let top = sectionModels[0].top_stories[index]
        let detailVc = DetailStoryViewController()
        detailVc.storyID = top.id
        navigationController!.pushViewController(detailVc, animated: true)
    }
    func  scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        naviTitle.alpha = 1
        if offsetY>criticaloffSetY {
            var h = offsetY - criticaloffSetY
            if h > 44 {
                h = 44
                naviTitle.alpha = 0
            }
            navBar.setHeight(64-h)
            naviTitle.setCenterY(44-h)
        }else{
            navBar.setHeight(64)
            naviTitle.setCenterY(44)
        }
        if offsetY > scrollView.contentSize.height - 1.5 * kScreenHeight {
            loadMoreData()
        }
        if offsetY < -150 {
//            loadNewData()
        }
        guard scrollView == tableView else{
            printLog("hahahah", logError: true)
            return
        }
        //NavBar及titleLabel透明度渐变
        let color = UIColor(red: 1/255.0, green: 131/255.0, blue: 209/255.0, alpha: 1)
        let prelude: CGFloat = 90
        if offsetY > -20 {
            let alpha = min(1, (20 + offsetY) / (20 + prelude))
            //NavBar透明度渐变
            navBar.backgroundColor = color.colorWithAlphaComponent(alpha)
        }else{
            navBar.backgroundColor = UIColor.clearColor()
        }
    }
    lazy private  var navBar: UIView = {
        let object = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: kScreenWidth, height: 64)))
        return object
    }()
    lazy private  var barButtonItem: UIButton = {
        let object = UIButton()
        object.setBackgroundImage(UIImage(named: "menu"), forState: .Normal)
        object.setCenterY(30)
        object.setX(20)
        object.tintColor = UIColor.whiteColor()
        object.sizeToFit()
        object.addTarget(self, action: #selector(HomePageController.revealToggle(_:)), forControlEvents: .TouchUpInside)
        return object
    }()
    lazy private  var naviTitle: UILabel = {
        let object = UILabel()
        object.font = UIFont.systemFontOfSize(18)
        object.textColor = UIColor.whiteColor()
        object.text = "今日热闻"
        object.sizeToFit()
        return object
    }()
    lazy private  var tableView: UITableView = {
        let view = UITableView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight), style: .Plain)
        view.rowHeight = 100
        let parallaxScrollView = ParallaxScrollView.creatParallaxScrollViewWithSubView(self.headerView, referView: view)
        view.tableHeaderView = parallaxScrollView
        view.delegate = self
        view.dataSource = self
        return view
    }()
    lazy private  var headerView: RunLoopSwiftView = {
        let object = RunLoopSwiftView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
        object.delegate = self
        return object
    }()
    var criticaloffSetY : CGFloat = 199.9
    
}