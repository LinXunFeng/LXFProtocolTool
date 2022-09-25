//
//  LXFFullScreenableNestOtherController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2022/9/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class LXFFullScreenableNestOtherController: UIViewController {
    
    fileprivate let redView = UIView().then {
        $0.backgroundColor = .red
    }
    
    let contentView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.redView)
        
        self.contentView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.redView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }

}
