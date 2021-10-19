//
//  LXFDIYTrailer.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2021/10/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import MJRefresh
import UIKit

class LXFDIYTrailer: MJRefreshTrailer {
    
    lazy var colorView: UIView = {
        let v = UIView()
        v.backgroundColor = .red
        return v
    }()
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                self.colorView.backgroundColor = .red
            case .pulling:
                self.colorView.backgroundColor = .green
            case .refreshing:
                self.colorView.backgroundColor = .yellow
            default:
                break
            }
        }
    }
    
    override func prepare() {
        super.prepare()
        
        self.addSubview(self.colorView)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
        // 设置宽度
        self.mj_w = 100
        self.colorView.frame = CGRect(x: 0, y: 0, width: 90, height: 50)
    }
}

