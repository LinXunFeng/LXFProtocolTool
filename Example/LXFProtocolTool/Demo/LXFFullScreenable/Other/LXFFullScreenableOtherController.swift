//
//  LXFFullScreenableOtherController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2021/9/3.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import LXFProtocolTool

class LXFFullScreenableOtherController: UIViewController, FullScreenable {
    
    fileprivate let tipLabel = UILabel().then {
        $0.text = "可以跟随自由设备进行屏幕旋转，也可以点击按钮进行旋转"
        $0.numberOfLines = 0
    }
    
    fileprivate let rotateBtn = UIButton().then {
        $0.backgroundColor = .orange
        $0.setTitle("切换方向", for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 配置支持的方向
        self.lxf.setupFullScreenConfig(with: .init(
            supportInterfaceOrientation: .allButUpsideDown
        ))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 还原为默认配置
        self.lxf.setupFullScreenConfig(with: FullScreenableConfig.defaultConfig())
    }
    
    deinit {
        print("deinit -- LXFFullScreenableOtherController")
    }
    
    fileprivate func initUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.tipLabel)
        self.view.addSubview(self.rotateBtn)
        self.tipLabel.frame = CGRect(x: 10, y: 100, width: 355, height: 60)
        self.rotateBtn.frame = CGRect(x: 50, y: 180, width: 100, height: 50)
        
        self.rotateBtn.addTarget(self, action: #selector(rotateBtnClick), for: .touchUpInside)
    }

    @objc func rotateBtnClick() {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            self.lxf.enterFullScreen()
        } else {
            self.lxf.exitFullScreen()
        }
    }
}

