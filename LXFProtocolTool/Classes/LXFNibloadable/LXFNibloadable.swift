//
//  LXFNibloadable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2018/4/6.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public protocol LXFNibloadable {
    
}

public extension LXFNibloadable where Self : UIView {
    static func loadFromNib() -> Self {
        return Bundle(for: Self.self).loadNibNamed("\(self)", owner: nil, options: nil)?.first as! Self
    }
}
