//
//  LXFFullScreenableOtherController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2020/10/30.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class LXFFullScreenableOtherController: UIViewController {
    
    fileprivate let redView = UIView().then {
        $0.backgroundColor = .red
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black.withAlphaComponent(0.2)

        self.view.addSubview(redView)
        self.redView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }

}
