//
//  LXFFullScreenableNestController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2021/8/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import LXFProtocolTool

class LXFFullScreenableNestController: UIViewController, FullScreenable {
    
    fileprivate let contentView = UIView().then {
        $0.backgroundColor = .orange
    }
    fileprivate let otherVc = LXFFullScreenableOtherController()

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        
        // 在嵌套多层的情况下，需要指定退出全屏时目标容器的frame，否则会很突兀
//        lxf.autoFullScreen(specifiedView: self.otherVc.view, superView: contentView)
        lxf.autoFullScreen(
            specifiedView: self.otherVc.view,
            superView: contentView,
            exitFullScreenToFrame: contentView.frame
        )
        
        
        // 前提: autoFullScreen在任意地方被执行一次后
        // 在当前控制器下添加了子控制器时，旋转控制权就会变得很混乱，这时候需要声明谁拥有全屏旋转控制权
        
        // 步骤:
        // 1. 在当前控制器的viewWillAppear指定哪个控制器(简称: vcA)拥有控制权，
        // 2. 且在viewWillDisappear中注销vcA的控制权
    }
    
    deinit {
        print("deinit -- LXFFullScreenableNestController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 指定当前控制器拥有控制权
        lxf.becomeFullScreenMaster()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 注销当前控制器的控制权
        lxf.resignFullScreenMaster()
    }
    
    fileprivate func initUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(contentView)
        contentView.addSubview(otherVc.view)
        contentView.frame = CGRect(x: 50, y: 80, width: 100, height: 100)
        otherVc.view.frame = contentView.bounds
    }

}

