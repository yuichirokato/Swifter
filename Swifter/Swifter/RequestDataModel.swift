//
//  RequestDataModel.swift
//  Swifter
//
//  Created by yuichiro_t on 2014/07/22.
//  Copyright (c) 2014年 加藤　佑一朗. All rights reserved.
//

import UIKit
import Social

// Swiftでのcase class

class RequestDataModel: SwiftCase {
    
    let identifier: String
    let url: String
    let params: NSDictionary

    
    init(identifier: String, url: String, params: NSDictionary) {
        self.identifier = identifier
        self.url = url
        self.params = params
        
        super.init(identifier, url, params) //superクラスのイニシャライザにパラメータリストを渡す
    }
    
}
