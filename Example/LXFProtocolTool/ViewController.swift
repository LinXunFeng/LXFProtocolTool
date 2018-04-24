//
//  ViewController.swift
//  LXFProtocolTool
//
//  Created by LinXunFeng on 04/06/2018.
//  Copyright (c) 2018 LinXunFeng. All rights reserved.
//

import UIKit
import LXFProtocolTool

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
}

// MARK:- 事件处理
extension ViewController {
    @objc fileprivate func trans2emptyVc() {
        let vc = LXFEmptyDemoController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK:- 初始化UI
extension ViewController {
    fileprivate func initUI() {
        // LXFNibloadable
        let vc = LXFXibTestView.loadFromNib()
        vc.frame = CGRect(x: 140, y: 80, width: 100, height: 100)
        self.view.addSubview(vc)
        
        // LXFEmptyDataSetable
        let emptyBtn = UIButton(type: .custom)
        emptyBtn.addTarget(self, action: #selector(trans2emptyVc), for: UIControlEvents.touchUpInside)
        emptyBtn.setTitle("emptyTest - 点我", for: UIControlState.normal)
        emptyBtn.setTitleColor(UIColor.red, for: UIControlState.normal)
        emptyBtn.frame = CGRect(x: 80, y: 200, width: 200, height: 30)
        self.view.addSubview(emptyBtn)

    }
}

