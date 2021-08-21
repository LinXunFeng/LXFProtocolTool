//
//  LXFFullSwitchView.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2019/8/16.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import LXFProtocolTool

class LXFFullSwitchView: UIButton, FullScreenable {
    convenience init(_ type: UIButton.ButtonType) {
        self.init(type: type)
        self.backgroundColor = .orange
        
        self.addTarget(self, action: #selector(switchFullScreen), for: .touchUpInside)
    }

    
    @objc fileprivate func switchFullScreen() {
        self.lxf.switchFullScreen()
    }
}
