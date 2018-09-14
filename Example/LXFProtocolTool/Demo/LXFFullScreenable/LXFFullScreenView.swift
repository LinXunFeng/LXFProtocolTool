//
//  LXFFullScreenView.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/9/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import LXFProtocolTool

class LXFFullScreenView: UIButton, FullScreenable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .cyan
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
