//
//  LXFEmptyDemoController.swift
//  LXFProtocolTool_Example
//
//  Created by 林洵锋 on 2018/4/7.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import LXFProtocolTool

class LXFEmptyDemoController: UIViewController {

    // 数据
    fileprivate var tipStrArr = ["无法转换", "无法定位", "无法拨通", "无法屏幕分享"]
    
    // UI
    fileprivate var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
}

// MARK:- 事件处理
extension LXFEmptyDemoController {
    @objc fileprivate func switchEmpty() {
        let randomInt = Int(arc4random())%tipStrArr.count // 1~100 的随机数
        
        // 更新空白页数据
        lxf_updateEmptyDataSet(tableView) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            return [
                .tipImage:UIImage(named: "tipImg\(randomInt)")!,
                .tipStr:tipStrArr[randomInt]
            ]
        }
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
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
        }
        return cell!
    }
}

extension LXFEmptyDemoController: LXFEmptyDataSetable {
    fileprivate func initUI() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "switch", style: UIBarButtonItemStyle.plain, target: self, action: #selector(switchEmpty))
        
        // tableView
        let tableView = UITableView()
        self.tableView = tableView
        self.view.addSubview(tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        
        // 高定制
        lxf_EmptyDataSet(tableView) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            return [
                .tipStr:"哟哟哟",
                .verticalOffset:-150,
                .allowScroll: false
            ]
        }
        
        // 默认定制
//        lxf_EmptyDataSet(tableView)
        
        
        // 监听点击事件
        lxf_tapEmptyView(tableView) { (view) in
            print("点击了空白视图")
        }
    }
}
