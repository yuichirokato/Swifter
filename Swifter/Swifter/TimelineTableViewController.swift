//
//  TimelineTableViewController.swift
//  Swifter
//
//  Created by 加藤　佑一朗 on 2014/06/11.
//  Copyright (c) 2014年 加藤　佑一朗. All rights reserved.
//

import UIKit
import Accounts
import Social

class TimelineTableViewController: UITableViewController {
    
    var timelineData: NSArray?
    var identifier: String?
    var dataController = TwitterDataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendRequest()
        self.tableView.registerClass(TimelineCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func sendRequest() {
        
        let params: NSDictionary = ["count": "20", "trim_user": "0"]
        let url_str = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        let requestData = RequestDataModel(identifier: self.identifier!, url: url_str, params: params)
        
        let request = dataController.makeRequest(requestData, method: SLRequestMethod.GET)
        
        dataController.startIndicator()
        
        dataController.sendRequest((request, self), fSuccess: { json in
            self.timelineData = json as? NSArray
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.dataController.endIndicator()
            })
        }, fComplete: {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.dataController.endIndicator()
            })
        })
    }
    
    func labelHeight(labelString: String?) -> Float {
        let aLabel = UILabel()
        let lineHeight: Float = 18.0
        let pragrahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        pragrahStyle.minimumLineHeight = lineHeight
        pragrahStyle.maximumLineHeight = lineHeight
        
        let text = labelString!
        let font = UIFont(name:"HiraKakuProN-W3", size: 14)
        let attributes = [NSParagraphStyleAttributeName: pragrahStyle, NSFontAttributeName: font]
        let aText = NSAttributedString(string: text, attributes: attributes)
        aLabel.attributedText = aText
        let options: NSStringDrawingOptions = .UsesLineFragmentOrigin
        
        let aLabelHieght: Float = aLabel.attributedText.boundingRectWithSize(CGSize(width: 257, height: MAXFLOAT),
            options: options, context: nil).size.height
        return aLabelHieght
    }
    
    func getImageData(dic: NSDictionary) -> NSData {
        let image_url_string: String = dic["user"].objectForKey("profile_image_url") as String
        let image_url = NSURL(string: image_url_string)
        return NSData(contentsOfURL: image_url)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableview: UITableView) -> Int { return 1 }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection: Int) -> Int {
        switch timelineData {
            case nil: return 1
            case let data: return data!.count
        }
    }
    
    override func tableView(tableView: UITableView?, cellForRowAtIndexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: TimelineCell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as TimelineCell
        
        if let timeline = timelineData {
            let body = timeline[cellForRowAtIndexPath.row].objectForKey("text") as String
            cell.nameLabel.text = timeline[cellForRowAtIndexPath.row].objectForKey("user").objectForKey("screen_name") as String
            cell.tweetTextLabel.text = body
            cell.tweetTextLabelHeight = self.labelHeight(body)
            
            let image_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
            dispatch_async(image_queue, {
                let dictionary = timeline[cellForRowAtIndexPath.row] as NSDictionary
                let data = self.getImageData(dictionary)
                dispatch_async(dispatch_get_main_queue(), {
                    self.dataController.endIndicator()
                    cell.profileImageView.image = UIImage(data: data)
                    cell.setNeedsLayout()
                })
            })
            return cell
        }
        cell.nameLabel.text = "Loading..."
        return cell
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath: NSIndexPath!) -> CGFloat {
        if let timleines = self.timelineData {
            let tweetText = self.timelineData![heightForRowAtIndexPath.row].objectForKey("text") as String
            let height = self.labelHeight(tweetText)
            return height + 35
        }
        return 35
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)  {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as TimelineCell
        let dvc = self.storyboard.instantiateViewControllerWithIdentifier("DetailView") as DetailViewController
        
        dvc.tweetText = cell.tweetTextLabel.text
        dvc.name = cell.nameLabel.text
        dvc.profileImage = cell.profileImageView.image
        dvc.identifier = self.identifier
        self.navigationController.pushViewController(dvc, animated: true)
    }
    
}
