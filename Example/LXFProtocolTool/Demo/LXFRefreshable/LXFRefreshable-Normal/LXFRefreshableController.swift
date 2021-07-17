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

class LXFRefreshableController: UIViewController, View, Refreshable, EmptyDataSetable {
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
    
    deinit {
        print("deinit -- LXFRefreshableController")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(tableView)
        tableView.frame = CGRect(
            x: 0,
            y: Configs.Screen.navibarH,
            width: Configs.Screen.width,
            height: Configs.Screen.height - Configs.Screen.navibarH - Configs.Screen.bottomH
        )
        
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
        
        // 上拉下拉 分开设置
        /*
        // 自定义配置
        self.rx.headerRefresh(reactor, tableView, headerConfig: RefreshConfig.normalHeader)
            .map { .fetchList(true) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
         
        // 默认配置
        self.rx.footerRefresh(reactor, tableView)
            .map { .fetchList(false) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
 
        self.rx.headerRefresh(reactor, tableView)
            .subscribe(onNext: { _ in
                reactor.action.onNext(.fetchList(true))
            })
            .disposed(by: disposeBag)
         */
        
        // 上拉下拉 一块设置
//        self.rx.refresh(reactor, tableView)
//            .map { .fetchList($0 == .header) }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
        
        // DIY header footer
        self.rx.refresh(reactor, tableView, headerConfig: RefreshConfig.diyHeader, footerConfig: RefreshConfig.diyFooter)
            .map { .fetchList($0 == .header) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.tapEmptyView(tableView)
            .map { _ in .beginRefresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.sections }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.emptyConfig }
            .bind(to: tableView.rx.emptyConfig)
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
    
    static let diyHeader = RefreshableHeaderConfig(type: RefreshHeaderType.diy(type: LXFDIYHeader.self))
    
    static let diyFooter = RefreshableFooterConfig(type: RefreshFooterType.diy(type: LXFDIYAutoFooter.self))
}

