//
//  HomePageCell.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/13.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import SDWebImage
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
    func serialize() -> [String : Any] {
        return ["images":images,"type":type,"id":id,"ga_prefix":ga_prefix,"title":title]
    }
}
class HomePageCell: UITableViewCell {
    ///  类方法创建cell
    ///
    ///  - parameter tableView: tableView
    ///
    class func homePageCellWithTableView(_ tableView:UITableView) -> HomePageCell {
        var tableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomePageCell") as? HomePageCell
        if (tableViewCell == nil) {
            tableViewCell = HomePageCell(style: .default, reuseIdentifier: "HomePageCell")
        }
        return tableViewCell!
    }
    var story: Story?{
        didSet{
            titleLabel.text = story?.title
            iconView.sd_setImage(with: URL(string: (story?.images[0])!))
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview()
    }
    fileprivate func addSubview(){
        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -20))
        contentView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 60))
        contentView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 60))
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: iconView, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: iconView, attribute: .left, multiplier: 1, constant: -20))
    }
    // MARK:懒加载控件
    lazy fileprivate  var titleLabel: UILabel = {
        let object = UILabel()
        object.font = UIFont.boldSystemFont(ofSize: 16)
        object.numberOfLines = 0
        object.textAlignment = NSTextAlignment.left
        //自动折行设置
        object.lineBreakMode = NSLineBreakMode.byCharWrapping
        return object
    }()
    lazy fileprivate  var iconView: UIImageView = {
        let object = UIImageView()
        return object
    }()

}

//contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[view]-60-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : titleLabel]))
//contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[view]-20-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : titleLabel]))

