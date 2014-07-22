//
//  DetailViewController.swift
//  Swifter
//
//  Created by yuichiro_t on 2014/07/21.
//  Copyright (c) 2014年 加藤　佑一朗. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var profileImageView: UIImageView
    @IBOutlet var nameView: UITextView
    @IBOutlet var textView: UITextView
    
    var tweetText: String?
    var name: String?
    var profileImage: UIImage?
    var identifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("tweetText = \(tweetText?)")
        self.profileImageView.image = profileImage.getOrElse(UIImage(named: "blank.png"))
        self.textView.text = tweetText.getOrElse("読み込みエラー！")
        self.nameView.text = name.getOrElse("読み込みエラー！")
        self.navigationItem.title = tweetText.getOrElse("読み込みエラー！")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
}
