//
//  TwitterDataController.swift
//  Swifter
//
//  Created by yuichiro_t on 2014/07/21.
//  Copyright (c) 2014年 加藤　佑一朗. All rights reserved.
//

import UIKit
import Social
import Accounts

class TwitterDataController: NSObject {
    
    var vc: UIViewController?
    
    func makeRequest(datas: RequestDataModel, method: SLRequestMethod) -> SLRequest {
        let accountStore = ACAccountStore()
        let account = accountStore.accountWithIdentifier(datas.identifier)
        
        let url = NSURL(string: datas.url)
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: method, URL: url,
                                                                        parameters: datas.params)
        request.account = account
        return request
    }
    
    func sendRequest(userinfo: (request: SLRequest, vc: UIViewController), fSuccess:((some: AnyObject) -> Void)?, fComplete: () -> Void) {
        
        self.vc = userinfo.vc
        
        userinfo.request.performRequestWithHandler({ responseData, urlResponse, error in
            
            if !responseData {
                self.errorHandler("通信エラー！", meesage: "時間を置いてもう一度お試しください", completion: fComplete)
                return
            }
            
            let status = urlResponse.statusCode
            var error: NSError?
            
            if status < 200 || status >= 300 {
                self.errorHandler("\(status)リクエストエラー！", meesage: "通信に失敗しました", completion: fComplete)
                return
            }
            
            let jsonData = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments,
                                                                    error: &error) as? NSArray

            switch jsonData {
                case nil: NSLog("JSON Error: \(error?.localizedDescription)")
                case let data: if let function = fSuccess { function(some: data!) }
            }
        })
    }
    
    func showAlert(title: String, message: String, handler: () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler:{ action in handler() })
        
        alertController.addAction(cancelAction)
        self.vc!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func startIndicator() {
        let application: UIApplication = UIApplication.sharedApplication()
        application.networkActivityIndicatorVisible = true
    }
    
    func endIndicator() {
        let application = UIApplication.sharedApplication()
        application.networkActivityIndicatorVisible = false
    }
    
    func errorHandler(title: String, meesage: String, completion: (() -> Void)?) {
        dispatch_async(dispatch_get_main_queue(), {
            self.showAlert(title, message: meesage, handler: completion.getOrElse({}))
        })
    }
}
