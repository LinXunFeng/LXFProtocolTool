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
        let v = UIButton(type: .custom)
        v.backgroundColor = .red
        v.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
//        v.setTitle("click red view", for: .normal)
        v.setTitle("enter full screen", for: .normal)
        return v
    }()
    
    fileprivate lazy var cyanView: LXFFullScreenView = {
        let v = LXFFullScreenView(.custom)
        v.frame = CGRect(x: 50, y: 250, width: 200, height: 100)
        v.setTitle("exit full screen", for: .normal)
        v.setTitleColor(.black, for: .normal)
        return v
    }()
    
    fileprivate lazy var diyConfig: FullScreenableConfig = {
        return FullScreenableConfig(
            animateDuration: 1,
            enterFullScreenOrientation: .landscapeLeft
        )
    }()
    
    fileprivate lazy var autoFullScreenConfig: FullScreenableConfig = {
        return FullScreenableConfig(
            supportInterfaceOrientation: .allButUpsideDown
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(redView)
        self.view.addSubview(cyanView)
        
        redView.addTarget(self, action: #selector(redViewClick), for: .touchUpInside)
        
        cyanView.addTarget(self, action: #selector(cyanViewClick), for: .touchUpInside)
        
        // 自动旋转下，controller和view最好不要混用屏幕旋转，如果非要如此，请传递config
        // 传递config的目的是为了退出全屏时恢复supportInterfaceOrientation
//        lxf.autoFullScreen(specifiedView: redView, superView: view)
        lxf.autoFullScreen(specifiedView: redView, superView: view, config:autoFullScreenConfig)
    }
    
    deinit {
        print("deinit -- LXFFullScreenableController")
    }
}

// MARK:- Events
extension LXFFullScreenableController {
    @objc func redViewClick() {
//        lxf.switchFullScreen()
        lxf.enterFullScreen(specifiedView: cyanView)
//        cyanView.lxf.enterFullScreen()
        
//        cyanView.lxf.enterFullScreen(config: diyConfig)
        
    }
    @objc func cyanViewClick() {
        lxf.exitFullScreen(superView: self.view)
//        cyanView.lxf.exitFullScreen()
        
//        cyanView.lxf.exitFullScreen(config: diyConfig)
    }
}
