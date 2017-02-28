//
//  HomePageHeaderView.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/22.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
// MARK: 类方法加载headerView
extension HomePageHeaderView{
    ///  类方法加载headerView
    ///
    ///  - parameter tableView: tableView description
    ///
    class func homePageHeaderViewWithTableView(_ tableView:UITableView) -> HomePageHeaderView {
        var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HomePageHeaderView") as? HomePageHeaderView
        if (headerView == nil) {
            headerView = HomePageHeaderView(reuseIdentifier: "HomePageHeaderView")
            headerView?.contentView.backgroundColor = UIColor(red: 1/255.0, green: 131/255.0, blue: 209/255.0, alpha: 1)
        }
        return  headerView!
    }
}
class HomePageHeaderView: UITableViewHeaderFooterView {
    var date : String?{
        didSet{
            dateFormatter.dateFormat = "yyyyMMdd"
            let datetempt = dateFormatter.date(from: date!)
            dateFormatter.dateFormat = "MM月dd日 EEEE"
            textLabel?.text = dateFormatter.string(from: datetempt!)
            textLabel?.font = UIFont.systemFont(ofSize: 18)
            textLabel?.textColor = UIColor.white
            textLabel?.sizeToFit()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.setCenterX(getCenterX())
    }
    lazy fileprivate  var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-CH")
        return formatter
    }()
}
