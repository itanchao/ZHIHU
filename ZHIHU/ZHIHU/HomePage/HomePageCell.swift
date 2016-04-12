//
//  HomePageCell.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/13.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit

class HomePageCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var titleLabel: UILabel!
    var iconView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFontOfSize(20)
        titleLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -60))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20))
        titleLabel.text = "zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三zhangsan章三"
         titleLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
