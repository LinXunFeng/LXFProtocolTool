//
//  ViewController.swift
//  LXFProtocolTool
//
//  Created by LinXunFeng on 04/06/2018.
//  Copyright (c) 2018 LinXunFeng. All rights reserved.
//

import UIKit
import LXFProtocolTool

class ViewController: UIViewController, FullScreenable {

    let dataArray = [
        "LXFNibloadable",
        "EmptyDataSetable",
        "Refreshable",
        "Refreshable-mutiple",
        "FullScreenable"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
}

// MARK:- 初始化UI
extension ViewController {
    fileprivate func initUI() {
        self.title = "LXFProtocolTool"
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cellID"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
        }
        cell?.textLabel?.text = dataArray[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var vc: UIViewController?
        if indexPath.row == 0 {
            vc = LXFNibloadableController()
        } else if indexPath.row == 1 {
            vc = LXFEmptyDemoController()
        } else if indexPath.row == 2 {
            vc = LXFRefreshableController(reactor: LXFRefreshableReactor())
        } else if indexPath.row == 3 {
            vc = LXFRefreshRespectiveController(reactor: LXFRefreshRespectiveReactor())
        } else if indexPath.row == 4 {
            vc = LXFFullScreenableController()
        }
        
        if vc == nil { return }
        vc?.title = dataArray[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
