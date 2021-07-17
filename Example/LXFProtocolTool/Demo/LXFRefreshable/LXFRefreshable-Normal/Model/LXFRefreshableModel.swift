//
//  LXFRefreshableModel.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/8/1.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import SwiftyJSON
import MoyaMapper

struct LXFRefreshableModel: Modelable {
    
    var _id : String = ""
    var created : String = ""
    var desc : String = ""
    var publishedAt : String = ""
    var source : String = ""
    var type : String = ""
    var url : String = ""
    var used : String = ""
    var who : String = ""
    
    init() { }
    mutating func mapping(_ json: JSON) {
        self.created = json["createdAt"].stringValue
    }
}

