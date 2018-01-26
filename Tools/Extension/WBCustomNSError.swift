//
//  WBCustomNSError.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class WBCustomNSError: NSObject, CustomNSError {
    
    override init() {
        super.init()
    }
    
    static func access_token_nil_error() -> WBCustomNSError {
        return WBCustomNSError()
    }
    
    /// The domain of the error.
    public static var errorDomain: String {
        get{
            return "access_token为nil"
        }
    }
    
    /// The error code within the given domain.
//    public var errorCode: Int {
//        get{
//
//        }
//    }
    
    /// The user-info dictionary.
//    public var errorUserInfo: [String : Any] {
//        get{
//
//        }
//
//    }
    
}
