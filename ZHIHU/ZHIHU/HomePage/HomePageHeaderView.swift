//
//  HomePageHeaderView.swift
//  ZHIHU
//
//  Created by wzh on 16/4/22.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit

class HomePageHeaderView: UITableViewHeaderFooterView {
    var date : String?{
        didSet{
            dateFormatter.dateFormat = "yyyyMMdd"
            let datetempt = dateFormatter.dateFromString(date!)
            dateFormatter.dateFormat = "MM月dd日 EEEE"
            textLabel?.text = dateFormatter.stringFromDate(datetempt!)
            textLabel?.font = UIFont.systemFontOfSize(18)
            textLabel?.textColor = UIColor.whiteColor()
            textLabel?.sizeToFit()
        }
    }
    
    class func homePageHeaderViewWithTableView(tableView:UITableView) -> HomePageHeaderView {
        var headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HomePageHeaderView") as? HomePageHeaderView
        if (headerView == nil) {
            headerView = HomePageHeaderView(reuseIdentifier: "HomePageHeaderView")
            headerView?.contentView.backgroundColor = UIColor(red: 1/255.0, green: 131/255.0, blue: 209/255.0, alpha: 1)
        }
        return  headerView!
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.setCenterX(getCenterX())
    }
    lazy private  var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "zh-CH")
        return formatter
    }()

}