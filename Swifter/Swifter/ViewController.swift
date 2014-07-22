//
//  ViewController.swift
//  Swifter
//
//  Created by 加藤　佑一朗 on 2014/06/11.
//  Copyright (c) 2014年 加藤　佑一朗. All rights reserved.
//

import UIKit
import Accounts
import Social

class ViewController: UIViewController {
    
    @IBOutlet var profile_image : UIImageView
    @IBOutlet var lbl_username : UILabel
    
    var identifier: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let accountStore: ACAccountStore = ACAccountStore()
        let twitterType: ACAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        getAccountData(accountStore, twitterType: twitterType)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc: TimelineTableViewController = segue.destinationViewController as TimelineTableViewController
        vc.identifier = self.identifier
    }

    func makeRequest(account: ACAccount) -> SLRequest {
        let url = NSURL(string: "https://api.twitter.com/1.1/users/show.json")
        
        let params = ["screen_name": account.username]
        
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET,
            URL: url, parameters: params)
        
        request.account = account
        return request
    }
    
    func sendRequest(account: ACAccount) {
        let request = makeRequest(account)
        request.performRequestWithHandler({responseData, urlResponse, error in
            if responseData {
                let status = urlResponse.statusCode
                var error: NSError? = NSError()
                if status >= 200 && status < 300 {
                    let options = NSJSONReadingOptions.AllowFragments
                    let jsonData: NSDictionary = NSJSONSerialization.JSONObjectWithData(responseData, options: options,
                        error: &error) as NSDictionary
                    let image = self.getProfileImage(jsonData["profile_image_url"] as String)
                    dispatch_async(dispatch_get_main_queue(),{ self.profile_image.image = image })
                }
            }
        })
    }
    
    func getProfileImage(profile_url: String) -> UIImage {
        let url = NSURL(string: profile_url)
        let data = NSData(contentsOfURL: url)
        return UIImage(data: data)
    }
    
    func getAccountData(accountStore: ACAccountStore, twitterType: ACAccountType) {
        
        func setLabelText(message: String) {
            dispatch_async(dispatch_get_main_queue(), {self.lbl_username.text = message})
        }
        
        func setAccount(accounts: [AnyObject]) {
            let account = accounts[0] as ACAccount
            self.sendRequest(account)
            self.identifier = account.identifier
            setLabelText(account.username)
        }
        
        accountStore.requestAccessToAccountsWithType(twitterType, options:nil, completion:{ granted, error in
            if granted {
                let twitterAccounts: [AnyObject]? = accountStore.accountsWithAccountType(twitterType)
                switch twitterAccounts {
                    case let account : setAccount(account!)
                    default : setLabelText("アカウントが見つかりません")
                }
                return
            }
            println(error.localizedDescription)
            setLabelText("認証エラー")
        })
    }
}

