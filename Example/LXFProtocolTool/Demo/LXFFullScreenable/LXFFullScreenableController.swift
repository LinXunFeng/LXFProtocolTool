//
//  LXFFullScreenableController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/9/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import LXFProtocolTool

class LXFFullScreenableController: UIViewController, FullScreenable {
    // MARK:- UI
    fileprivate lazy var redView: UIButton = {
        let v = UIButton()
        v.backgroundColor = .red
        v.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
        return v
    }()
    
    fileprivate lazy var cyanView: LXFFullScreenView = {
        let v = LXFFullScreenView()
        v.frame = CGRect(x: 50, y: 250, width: 200, height: 100)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(redView)
        self.view.addSubview(cyanView)
        
        redView.addTarget(self, action: #selector(redViewClick), for: .touchUpInside)
        
        cyanView.addTarget(self, action: #selector(cyanViewClick), for: .touchUpInside)
    }
}

// MARK:- Events
extension LXFFullScreenableController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lxf.switchFullScreen(isEnter: true, specifiedView: redView, superView: self.view)
    }
    
    @objc func redViewClick() {
        lxf.switchFullScreen(isEnter: !self.lxf.isFullScreen, specifiedView: redView, superView: self.view)
    }
    @objc func cyanViewClick() {
        cyanView.lxf.switchFullScreen(isEnter: !cyanView.lxf.isFullScreen)
    }
}
