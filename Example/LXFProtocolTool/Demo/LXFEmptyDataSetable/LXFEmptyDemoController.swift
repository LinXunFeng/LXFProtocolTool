//
//  LXFEmptyDemoController.swift
//  LXFProtocolTool_Example
//
//  Created by 林洵锋 on 2018/4/7.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import LXFProtocolTool
import RxSwift

class LXFEmptyDemoController: UIViewController, EmptyDataSetable {

    var disposeBag = DisposeBag()
    
    // 数据
    fileprivate var tipStrArr = ["无法转换", "无法定位", "无法拨通", "无法屏幕分享"]
    
    // UI
    fileprivate var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    deinit {
        print("deinit --- LXFEmptyDemoController")
    }
}

// MARK:- 事件处理
extension LXFEmptyDemoController {
    @objc fileprivate func switchEmpty() {
        let randomInt = Int(arc4random())%tipStrArr.count // 1~100 的随机数
        
        // 更新空白页数据
        var config = EmptyConfig.normal
        config.tipStr = tipStrArr[randomInt]
        config.tipImage = UIImage(named: "tipImg\(randomInt)")
        self.lxf.updateEmptyDataSet(tableView, config: config)
    }
}

// MARK:- UITableViewDataSource
extension LXFEmptyDemoController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = "cellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        }
        return cell!
    }
}

extension LXFEmptyDemoController {
    fileprivate func initUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "switch", style: .plain, target: self, action: #selector(switchEmpty))
        
        // tableView
        let tableView = UITableView(frame: .zero)
        self.tableView = tableView
        self.view.addSubview(tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        
        // 定制
        self.lxf.updateEmptyDataSet(tableView, config: EmptyConfig.noData)

        // 监听点击事件
//        self.lxf.tapEmptyView(tableView) { view in
//            print("点击了空白视图")
//        }
//        self.lxf.emptyViewDidAppear(tableView) {
//            print("emptyViewDidAppear")
//        }
        
//        tableView.rx.emptyConfig
        
        self.rx.tapEmptyView(tableView)
            .subscribe(onNext: { _ in
                print("点击了空白视图")
            }).disposed(by: disposeBag)
        
        self.rx.emptyViewDidAppear(tableView)
            .subscribe(onNext: { _ in
                print("emptyViewDidAppear")
            })
            .disposed(by: disposeBag)
    }
}


// 常用配置
struct EmptyConfig {
    static let normal = EmptyDataSetConfigure(tipFont: UIFont.systemFont(ofSize: 14), tipColor: UIColor.gray, tipImage: UIImage(named: "LXFEmptyDataPic")!, spaceHeight: 15)
    static let noData = { () -> EmptyDataSetConfigure in
        var config = EmptyConfig.normal
        config.tipStr = "暂无数据"
        return config
    }()
    static let loadFaile = { () -> EmptyDataSetConfigure in
        var config = EmptyConfig.normal
        config.tipStr = "呃，页面加载失败"
        config.buttonImageBlock = { _ in
            return UIImage(named: "reloadData")
        }
        return config
    }()
}
