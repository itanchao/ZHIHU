//
//  HomeViewController.swift
//  ZHIHU
//
//  Created by 谈超 on 2017/5/5.
//  Copyright © 2017年 谈超. All rights reserved.
//

import UIKit
import BouncyLayout
import Alamofire
class HomeViewController: UIViewController {
    var sectionModels : [SectionModel] = []
    //    {
    //        didSet{
    //            guard sectionModels.count == 0 else{
    //                headerView.loopDataGroup = sectionModels[0].top_stories.map { (top)  in LoopData(image: top.image, des: top.title) }
    //                return
    //            }
    //        }
    //    }
    var loading = false

    lazy private  var layout: BouncyLayout = {
        let _layout = BouncyLayout(style: .regular)
        _layout.minimumLineSpacing = 0
        _layout.minimumInteritemSpacing = 0
        return _layout
    }()
    lazy fileprivate  var headerView: RunLoopSwiftView = {
        let object = RunLoopSwiftView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
        object.delegate = self
        return object
    }()
    lazy fileprivate  var circleChart: TCCircleChart = {
        let view = TCCircleChart.attachObserveToScrollView(self.collectionView, target: self, action: #selector(HomePageController.loadNewData))
        view.frame = CGRect(x: 10, y: 20, width: 20, height: 20)
        view.setCenterY(35)
        view.setX(self.naviTitle.getX()-30)
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: kScreenHeight)), collectionViewLayout: self.layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delaysContentTouches = false
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = false
        view.backgroundColor = nil
        view.isOpaque = false
        view.delegate = self
        view.dataSource = self
        view.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
        view.showsVerticalScrollIndicator = false
//        view.register(HomeCellHeaderView.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: HomeCellHeaderView.reuseIdentifier)
//        view.register(HomeCellHeaderView.self, forSupplementaryViewOfKind: "UICollectionElementKindSectionHeader", withReuseIdentifier: HomeCellHeaderView.reuseIdentifier)

        return view
    }()
    lazy fileprivate  var navBar: UIView = {
        let object = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: kScreenWidth, height: 64)))
        return object
    }()
    lazy fileprivate  var barButtonItem: UIButton = {
        let object = UIButton()
        object.setBackgroundImage(UIImage(named: "menu"), for: UIControlState())
        object.setCenterY(30)
        object.setX(20)
        object.tintColor = UIColor.white
        object.sizeToFit()
        object.addTarget(self, action: #selector(HomePageController.revealToggle(_:)), for: .touchUpInside)
        return object
    }()
    lazy fileprivate  var naviTitle: UILabel = {
        let object = UILabel()
        object.font = UIFont.systemFont(ofSize: 18)
        object.textColor = UIColor.white
        object.text = "今日热闻"
        object.sizeToFit()
        return object
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)
        loadNewData()
        view.addSubview(navBar)
        navBar.backgroundColor = UIColor.clear
        view.addSubview(barButtonItem)
        view.addSubview(naviTitle)
        naviTitle.setCenterY(44)
        naviTitle.setCenterX(view.getCenterX())
        view.addSubview(circleChart)
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension HomeViewController{
    func revealToggle(_ sender:UIButton) {
        print("------------")
    }
    func loadNewData() {
        guard loading else{
            loading = true
            Alamofire.request(Urls.homeUrl).responseJSON(completionHandler: { (resultData) in
                guard resultData.result.error == nil else{
                    print("网络失败")
                    return
                }
                self.sectionModels.removeAll()
                let datalist = resultData.result.value as? [String:AnyObject] ?? [:]
                self.sectionModels.append(SectionModel(dict: datalist))
                self.collectionView.reloadData()
                self.loading = false
                self.circleChart.stopAnimating()
            })
            return
        }
    }
    func loadMoreData() {
        guard loading else{
            loading = true
            let date = sectionModels.last?.date
            Alamofire.request(Urls.getMorehomedataUrl+date!).responseJSON(completionHandler: { (resultData) in
                guard resultData.result.error == nil else{
                    print("网络失败")
                    return
                }
                let datalist = resultData.result.value as? [String:AnyObject] ?? [:]
                self.sectionModels.append(SectionModel(dict: datalist))
//                self.collectionView.insertSections(IndexSet(integer: self.sectionModels.count - 1), with: .fade)
                self.collectionView.insertSections(IndexSet(integer: self.sectionModels.count - 1))
                self.loading = false
            })
            return
        }
    }

}
extension HomeViewController: UICollectionViewDataSource,UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionModels.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return sectionModels[section].stories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseIdentifier, for: indexPath) as! HomeCell
        cell.story = sectionModels[indexPath.section].stories[indexPath.item]
            
        return cell
    }
    func  scrollViewDidScroll(_ scrollView: UIScrollView) {
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
            navBar.backgroundColor = color.withAlphaComponent(alpha)
        }else{
            navBar.backgroundColor = UIColor.clear
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: kScreenWidth, height: section == 0 ? 0.001 : 44)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if indexPath.section == 0 {
            navBar.setHeight(20)
            naviTitle.alpha = 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if (indexPath.section == 0) {
            navBar.setHeight(20)
            naviTitle.alpha = 0
        }
    }
}
extension HomeViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section > 0 && indexPath.row == 0 {
            return CGSize(width: kScreenWidth, height: 20)
        }
        return CGSize(width: kScreenWidth, height: 100)
    }
}
extension HomeViewController:RunLoopSwiftViewDelegate{
    func runLoopSwiftViewDidClick(_ loopView: RunLoopSwiftView, didSelectRowAtIndex index: NSInteger) {
        let top = sectionModels[0].top_stories[index]
        let detailVc = DetailStoryViewController()
        detailVc.storyID = top.id
        navigationController!.pushViewController(detailVc, animated: true)
    }
}
class HomeCellHeaderView: UICollectionReusableView {
    static let reuseIdentifier: String = "HomeCellHeaderView"
    var date : String?{
        didSet{
            dateFormatter.dateFormat = "yyyyMMdd"
            let datetempt = dateFormatter.date(from: date!)
            dateFormatter.dateFormat = "MM月dd日 EEEE"
            
            textLabel.text = dateFormatter.string(from: datetempt!)
            textLabel.font = UIFont.systemFont(ofSize: 18)
            textLabel.textColor = UIColor.white
            textLabel.sizeToFit()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy fileprivate  var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-CH")
        return formatter
    }()
    
    lazy private  var textLabel: UILabel = UILabel()

}
