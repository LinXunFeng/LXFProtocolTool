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
    case fullScreenableViewAuto = "fullScreenable-子视图全屏"
    case fullScreenableMultiVc = "FullScreenable-多个控制器"
    case fullScreenableNest = "FullScreenable-嵌套"
    case fullScreenableOther = "FullScreenable-其它功能"
    case equatable = "LXFEquatable"
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
        .fullScreenableMultiVc,
        .fullScreenableNest,
        .fullScreenableOther,
        .equatable
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
        
        // 适配iOS15导航栏
        if #available(iOS 15.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = .white // 背景色
            navBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.black // 字体颜色
            ]
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
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
        case .fullScreenableNest:
            vc = LXFFullScreenableNestController()
        case .fullScreenableOther:
            vc = LXFFullScreenableOtherController()
        case .equatable:
            vc = LXFEquatableViewController()
        }
        
        if vc == nil { return }
        vc?.title = dataArray[indexPath.row].rawValue
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
