//
//  LXFDIYAutoFooter.swift
//  LXFProtocolTool_Example
//
//  Created by 林洵锋 on 2019/4/13.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import MJRefresh

class LXFDIYAutoFooter: MJRefreshAutoFooter {
    
    fileprivate let label = UILabel().then {
        $0.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .center
    }
    
    fileprivate lazy var loading: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .gray)
    }()
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                self.loading.stopAnimating()
                self.label.text = "赶紧上拉吖"
            case .noMoreData:
                self.loading.stopAnimating()
                self.label.text = "木有数据了"
            case .refreshing:
                self.loading.startAnimating()
                self.label.text = "加载数据中"
            default:
                break
            }
        }
    }
    
    override var pullingPercent: CGFloat {
        didSet {
            let red = 1.0 - pullingPercent * 0.5
            let green = 0.5 - 0.5 * pullingPercent
            let blue = 0.5 * pullingPercent
            self.label.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
    
    // 在这里做一些初始化配置（比如添加子控件）
    override func prepare() {
        super.prepare()
        
        self.mj_h = 50
        
        self.addSubview(self.label)
        self.addSubview(self.loading)
    }
    
    // 设置子控件的位置和尺寸
    override func placeSubviews() {
        super.placeSubviews()
        
        self.label.frame = self.bounds;
        self.loading.center = CGPoint(x: 30, y: self.mj_h * 0.5)
    }
    
}
