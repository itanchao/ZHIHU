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
typealias Homeprotocol = protocol<RunLoopSwiftViewDelegate>
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
class HomePageController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(navBar)
        navBar.backgroundColor = UIColor.clearColor()
        view.addSubview(barButtonItem)
        view.addSubview(naviTitle)
        naviTitle.setCenterY(44)
        naviTitle.setCenterX(view.getCenterX())
        view.addSubview(circleChart)
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
    var sectionModels : [SectionModel] = []
        {
        didSet{
            guard sectionModels.count == 0 else{
                headerView.loopDataGroup = sectionModels[0].top_stories.map { (top)  in LoopData(image: top.image, des: top.title) }
                return
            }
        }
    }
    var loading :Bool = false
    // MARK:- 懒加载控件
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
        view.tableHeaderView = ParallaxScrollView.creatParallaxScrollViewWithSubView(self.headerView, referView: view)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    lazy private  var headerView: RunLoopSwiftView = {
        let object = RunLoopSwiftView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
        object.delegate = self
        return object
    }()
    lazy private  var circleChart: TCCircleChart = {
        let view = TCCircleChart.attachObserveToScrollView(self.tableView, target: self, action: #selector(HomePageController.loadNewData))
        view.frame = CGRect(x: 10, y: 20, width: 20, height: 20)
        view.setCenterY(35)
        view.setX(self.naviTitle.getX()-30)
        return view
    }()
}
// MARK:网络请求
extension HomePageController{
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
                self.circleChart.stopAnimating()
                //                self.circleChart.activityView.stopAnimating()
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
                self.tableView.insertSections(NSIndexSet(index: self.sectionModels.count - 1), withRowAnimation: UITableViewRowAnimation.Fade)
                self.loading = false
            }
            return
        }
    }
}
extension HomePageController:RunLoopSwiftViewDelegate{
    
    func runLoopSwiftViewDidClick(loopView: RunLoopSwiftView, didSelectRowAtIndex index: NSInteger) {
        let top = sectionModels[0].top_stories[index]
        let detailVc = DetailStoryViewController()
        detailVc.storyID = top.id
        navigationController!.pushViewController(detailVc, animated: true)
    }
}
extension HomePageController:UITableViewDelegate,UITableViewDataSource{
    // MARK:设置navgationBar高度
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.min : 44
    }
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if (section == 0) {
            navBar.setHeight(64)
            naviTitle.alpha = 1
        }
    }
    func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if (section == 0) {
            navBar.setHeight(20)
            naviTitle.alpha = 0
        }
    }
    // MARK:-UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = HomePageCell.homePageCellWithTableView(tableView)
        cell.story = sectionModels[indexPath.section].stories[indexPath.item]
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionModels.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionModels[section].stories.count
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleView = HomePageHeaderView.homePageHeaderViewWithTableView(tableView)
        titleView.date = sectionModels[section].date
        return section == 0 ? nil : titleView
    }
    // MARK:-UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let top = sectionModels[indexPath.section].stories[indexPath.item]
        let detailVc = DetailStoryViewController()
        detailVc.storyID = top.id
        navigationController!.pushViewController(detailVc, animated: true)
    }
    func  scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY > scrollView.contentSize.height - 1.5 * kScreenHeight {
            loadMoreData()
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
}