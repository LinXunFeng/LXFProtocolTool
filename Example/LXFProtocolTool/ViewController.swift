//
//  ViewController.swift
//  LXFProtocolTool
//
//  Created by LinXunFeng on 04/06/2018.
//  Copyright (c) 2018 LinXunFeng. All rights reserved.
//

import UIKit
import LXFProtocolTool

enum LXFListOptionType: String {
    case nibloadable = "LXFNibloadable"
    case emptyDataSetable = "EmptyDataSetable"
    case refreshable = "Refreshable"
    case refreshableTrailer = "Refreshable-左滑"
    case refreshableMutiple = "Refreshable-多个列表"
    case fullScreenable = "FullScreenable"
    case fullScreenableViewAuto = "fullScreenableViewAuto"
    case fullScreenableMultiVc = "FullScreenable-multiVc"
}

class ViewController: UIViewController, FullScreenable {

    let dataArray: [LXFListOptionType] = [
        .nibloadable,
        .emptyDataSetable,
        .refreshable,
        .refreshableTrailer,
        .refreshableMutiple,
        .fullScreenable,
        .fullScreenableViewAuto,
        .fullScreenableMultiVc
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置默认占位图配置
        // EmptyDataSetableConfigure.setDefaultEmptyDataSetConfigure(EmptyConfig.normal)
        
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
        cell?.textLabel?.text = dataArray[indexPath.row].rawValue
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var vc: UIViewController?
        switch self.dataArray[indexPath.row] {
        case .nibloadable:
            vc = LXFNibloadableController()
        case .emptyDataSetable:
            vc = LXFEmptyDemoController()
        case .refreshable:
            vc = LXFRefreshableController(reactor: LXFRefreshableReactor())
        case .refreshableTrailer:
            vc = LXFRefreshableTrailerController(reactor: LXFRefreshableTrailerReactor())
        case .refreshableMutiple:
            vc = LXFRefreshRespectiveController(reactor: LXFRefreshRespectiveReactor())
        case .fullScreenable:
            vc = LXFFullScreenableController()
        case .fullScreenableViewAuto:
            vc = LXFFullScreenableViewAutoController()
        case .fullScreenableMultiVc:
            vc = LXFFullScreenableMultiVcController()
        }
        
        if vc == nil { return }
        vc?.title = dataArray[indexPath.row].rawValue
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
