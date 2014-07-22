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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendRequest()
        
        let image = UIImage(named: "IMG_0278.JPG")
        
        self.tableView.registerClass(TimelineCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.backgroundColor = UIColor.blackColor()
        self.tableView.backgroundView = UIImageView(image: image)
    }
    
    func sendRequest() {
        let identifier: String? = self.identifier
        let accountStore = ACAccountStore()
        let account = accountStore.accountWithIdentifier(identifier)
        
        let params: NSDictionary = ["count": "20", "trim_user": "0"]
        let url_str = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let url = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: params)
        
        //let userinfo = ["id": self.identifier, "url": url_str, "params": params]
        
        request.account = account
        
        self.startIndicator()
        request.performRequestWithHandler({responseData, urlResponse, error in
            if responseData {
                let status = urlResponse.statusCode
                var error: NSError? = NSError()
                
                if status >= 200 && status < 300 {
                    let options = NSJSONReadingOptions.AllowFragments
                    let jsonData: NSArray = NSJSONSerialization.JSONObjectWithData(responseData, options: options,
                        error: &error) as NSArray
                    self.timelineData = jsonData
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                        self.endIndicator()
                    })
                    return
                }
                
                let title = "\(status)リクエストエラー"
                dispatch_async(dispatch_get_main_queue(), {
                    self.makeAlert(title, message: "通信に失敗しました").show()
                    self.endIndicator()
                })
                }
        })
    }
    
    func makeRequest(userinfo: NSDictionary, method: SLRequestMethod) -> SLRequest {
        let account = ACAccountStore().accountWithIdentifier(userinfo["id"] as String)
        let url = NSURL(string: userinfo["url"] as String)
        let params = userinfo["params"] as Dictionary<String, String>
        let request =  SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: method, URL: url, parameters: params)
        request.account = account
        return request
    }
    
    func makeAlert(title: String, message: String) -> UIAlertView {
        let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle:"OK")
        return alert
    }
    
    func startIndicator() {
        let application: UIApplication = UIApplication.sharedApplication()
        application.networkActivityIndicatorVisible = true
    }
    
    func endIndicator() {
        let application = UIApplication.sharedApplication()
        application.networkActivityIndicatorVisible = false
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
    
    func makeTweetData(data: NSDictionary) -> Dictionary<String, String> {
        
        let body = getValue("text", datas: data)
        let name = getValue("name", datas: data)
        return ["test": "test"]
    }
    
    func getValue(valueKey: String, datas: NSDictionary) -> String{
        let allKey = datas.allKeys as Array<String>
        let result = allKey.filter{$0 == valueKey}.map{key in datas[key]}
        println("getValue\(result)")
        return result[0] as String
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableview: UITableView) -> Int { return 1 }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection: Int) -> Int {
        if let data = timelineData {
            return data.count
        }
        return 1
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
                //self.makeTweetData(dictionary)
                dispatch_async(dispatch_get_main_queue(), {
                    self.endIndicator()
                    cell.profileImageView.image = UIImage(data: data)
                    cell.setNeedsLayout()
                })
            })
            return cell
        }
        
        cell.tweetTextLabel.text = "Loading..."
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
}
