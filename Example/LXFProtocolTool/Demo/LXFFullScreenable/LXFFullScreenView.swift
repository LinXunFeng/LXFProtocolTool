//
//  LXFFullScreenView.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/9/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import LXFProtocolTool

class LXFFullScreenView: UIButton, FullScreenable {
    convenience init(_ type: UIButton.ButtonType) {
        self.init(type: type)
        self.backgroundColor = .cyan
    }
}
