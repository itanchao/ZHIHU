//
//  HomePageCell.swift
//  ZHIHU
//
//  Created by tanchao on 16/4/13.
//  Copyright © 2016年 谈超. All rights reserved.
//

import UIKit
import SDWebImage
class HomePageCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var story: Story?{
        didSet{
            titleLabel.text = story?.title
            iconView.sd_setImageWithURL(NSURL(string: (story?.images[0])!))
        }
    }
    private var titleLabel: UILabel!
    private var iconView: UIImageView!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        backgroundColor = UIColor.Color("#fe4438")
        titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFontOfSize(20)
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignment.Left;
        //自动折行设置
        titleLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping;
        iconView = UIImageView()
        addSubview()
    }
    private func addSubview(){
        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: -20))
        contentView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 80))
        contentView.addConstraint(NSLayoutConstraint(item: iconView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 80))
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: iconView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -20))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[view]-60-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : titleLabel]))
//contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[view]-20-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["view" : titleLabel]))

