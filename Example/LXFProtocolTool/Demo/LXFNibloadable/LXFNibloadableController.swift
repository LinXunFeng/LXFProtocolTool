//
//  LXFNibloadableController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/8/1.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class LXFNibloadableController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        // LXFNibloadable
        let vc = LXFXibTestView.loadFromNib()
        vc.frame = CGRect(x: 140, y: 180, width: 100, height: 100)
        self.view.addSubview(vc)
    }
}
