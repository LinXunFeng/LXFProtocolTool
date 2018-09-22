//
//  LXFRefreshableController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/8/1.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift
import RxDataSources
import LXFProtocolTool
import ReusableKit
import Then

class LXFRefreshableController: UIViewController, View, Refreshable {
    var disposeBag: DisposeBag = DisposeBag()
    
    fileprivate struct Reusable {
        static let refreshableCell = ReusableCell<LXFRefreshableCell>()
    }
    fileprivate lazy var dataSource = self.dataSourceFactory()
    
    // UI
    fileprivate var tableView = UITableView(frame: .zero).then {
        $0.register(Reusable.refreshableCell)
        $0.rowHeight = 270
    }
    
    init(
        reactor: LXFRefreshableReactor
    ) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
        self.title = "Refreshable"
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = self.view.bounds
        self.view.addSubview(tableView)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.reactor?.action.onNext(.beginRefresh)
        }
    }
    
    fileprivate func dataSourceFactory() -> RxTableViewSectionedReloadDataSource<LXFRefreshableSection> {
        return .init(configureCell: { (dataSource, tableView, indexPath, sectionItem) -> LXFRefreshableCell in
            let cell = tableView.dequeue(Reusable.refreshableCell, for: indexPath)
            switch sectionItem {
            case let .item(reactor):
                cell.reactor = reactor
            }
            return cell
        })
    }
    
    func bind(reactor: LXFRefreshableReactor) {
        // View
//        lxf.initRefresh(reactor, tableView, headerAction: { // 默认配置
//            reactor.action.onNext(.fetchList(true))
//        }) {
//            reactor.action.onNext(.fetchList(false))
//        }.disposed(by: disposeBag)
        
    lxf.initRefresh(reactor, tableView, headerConfig: RefreshConfig.normalHeader, headerAction: { // 自定义配置
        reactor.action.onNext(.fetchList(true))
    }) {
        reactor.action.onNext(.fetchList(false))
    }.disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// 常用配置
struct RefreshConfig {
    
    static let normalHeader = RefreshableHeaderConfig(
        hideState: true,
        hideLastUpdatedTime: true
    )
    
    static let whiteHeader = RefreshableHeaderConfig(
        stateColor: .white,
        hideState: true,
        hideLastUpdatedTime: true,
        activityIndicatorViewStyle: .white
    )
}

