//
//  WBCustomNSError.swift
//  WeiBo
//
//  Created by QDHL on 2018/1/26.
//  Copyright © 2018年 QDHL. All rights reserved.
//

import UIKit

class WBCustomNSError: NSObject, Error {
    
    var errorDescription = ""
    
    init(errorDescription: String) {
        self.errorDescription = errorDescription
        super.init()
    }
    
    override var description: String{
        return errorDescription
    }
}
