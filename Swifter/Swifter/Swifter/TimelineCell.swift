//
//  TimelineCell.swift
//  Swifter
//
//  Created by 加藤　佑一朗 on 2014/06/11.
//  Copyright (c) 2014年 加藤　佑一朗. All rights reserved.
//

import UIKit

class TimelineCell: UITableViewCell {

    var tweetTextLabel: UILabel = UILabel()
    var nameLabel: UILabel = UILabel()
    var profileImageView: UIImageView = UIImageView()
    var tweetTextLabelHeight: Float = 0.0
    
    init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: UITableViewCellStyle.Value1, reuseIdentifier: reuseIdentifier)
        tweetTextLabel = UILabel(frame: CGRectZero)
        tweetTextLabel.attributedText = self.makeAttributedString(14)
        tweetTextLabel.numberOfLines = 0
        self.contentView.addSubview(tweetTextLabel)
        
        nameLabel = UILabel(frame: CGRectZero)
        nameLabel.attributedText = self.makeAttributedString(12)
        self.contentView.addSubview(nameLabel)
        
        profileImageView = UIImageView(frame: CGRectZero)
        self.contentView.addSubview(profileImageView)
        self.backgroundView = makeBlurView()
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.frame = CGRect(x: 5, y: 5, width: 48, height: 48)
        println(self.tweetTextLabelHeight)
        tweetTextLabel.frame = CGRect(x: 58, y: 5, width: 257, height: self.tweetTextLabelHeight)
        nameLabel.frame = CGRect(x: 58, y: self.tweetTextLabelHeight + 15, width: 257, height: 15)
    }
    
    func makeAttributedString(size: Float) -> NSAttributedString {
        let attrStr = NSMutableAttributedString()
        attrStr.addAttribute(NSFontAttributeName, value: UIFont(name: "Futura-CondensedMedium", size: size),
            range: NSMakeRange(0, attrStr.length))
        attrStr.addAttribute(NSStrokeColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, attrStr.length))
        return attrStr
    }
    
    // CellにBlur(磨りガラス効果)をかける
    func makeBlurView() -> UIVisualEffectView {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurEffectView.frame = self.bounds
        return blurEffectView
    }
}
