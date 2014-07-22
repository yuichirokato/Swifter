//
//  Extensions.swift
//  Swifter
//
//  Created by yuichiro_t on 2014/07/21.
//  Copyright (c) 2014年 加藤　佑一朗. All rights reserved.
//

import UIKit

extension Optional {
    func getOrElse(some: T) -> T {
        switch self {
            case nil: return some
            case let something: return something!
        }
    }
}

class Extensions: NSObject {}
