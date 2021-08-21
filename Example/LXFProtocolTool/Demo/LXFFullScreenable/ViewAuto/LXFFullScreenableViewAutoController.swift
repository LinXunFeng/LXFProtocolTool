//
//  LXFFullScreenableViewAutoController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2021/8/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import LXFProtocolTool

class LXFFullScreenableViewAutoController: UIViewController, FullScreenable {
    
    fileprivate lazy var switchView: LXFFullSwitchView = {
        let v = LXFFullSwitchView(.custom)
        v.frame = CGRect(x: 50, y: 100, width: 200, height: 100)
        v.setTitle("switch full screen", for: .normal)
        v.setTitleColor(.black, for: .normal)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(switchView)
    }
    
    deinit {
        print("deinit -- LXFFullScreenableViewAutoController")
    }
}
