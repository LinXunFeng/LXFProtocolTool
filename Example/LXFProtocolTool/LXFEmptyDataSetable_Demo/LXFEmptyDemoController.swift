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

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
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
        let tableView = UITableView()
        self.view.addSubview(tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        tableView.dataSource = self
        tableView.frame = self.view.bounds
        
        self.lxf_EmptyDataSet(tableView) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
            return [
                .tipStr:"哟哟哟",
                .verticalOffset:-150,
                .allowScroll: false
            ]
        }
//        self.lxf_EmptyDataSet(tableView)
    }
}
