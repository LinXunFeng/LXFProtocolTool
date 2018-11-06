//
//  LXFRefreshMultipleController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/11/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift
import RxDataSources
import LXFProtocolTool
import ReusableKit
import Then

class LXFRefreshMultipleController: UIViewController, View, Refreshable {
    var disposeBag: DisposeBag = DisposeBag()

    fileprivate struct Reusable {
        static let refreshableCell = ReusableCell<LXFRefreshableCell>()
    }
    fileprivate lazy var dataSource1 = self.dataSourceFactory()
    fileprivate lazy var dataSource2 = self.dataSourceFactory()
    
    // UI
    fileprivate var tableView1 = UITableView(frame: .zero).then {
        $0.register(Reusable.refreshableCell)
        $0.rowHeight = 270
        $0.tag = LXFRefreshMultipleReactor.ListIndex.first.rawValue
    }
    fileprivate var tableView2 = UITableView(frame: .zero).then {
        $0.register(Reusable.refreshableCell)
        $0.rowHeight = 270
        $0.tag = LXFRefreshMultipleReactor.ListIndex.second.rawValue
    }
    
    init(
        reactor: LXFRefreshMultipleReactor
    ) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
        self.title = "MutipleRefreshable"
    }
    
    deinit {
        print("deinit -- LXFRefreshMutipleController")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        let viewW = self.view.bounds.size.width
        let viewH = self.view.bounds.size.height
        tableView1.frame = CGRect(x: 0, y: 0, width: viewW, height: viewH * 0.5 - 1)
        tableView2.frame = CGRect(x: 0, y: viewH * 0.5, width: viewW, height: viewH * 0.5)
        self.view.addSubview(tableView1)
        self.view.addSubview(tableView2)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.reactor?.action.onNext(.beginRefresh(.first))
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
    
    func bind(reactor: LXFRefreshMultipleReactor) {
        // View
        self.rx.refresh(reactor, tableView1)
            .map { .fetchList(isReload: $0 == .header, listIndex: .first) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.refresh(reactor, tableView2)
            .map { .fetchList(isReload: $0 == .header, listIndex: .second) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.sections1 }
            .bind(to: tableView1.rx.items(dataSource: dataSource1))
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.sections2 }
            .bind(to: tableView2.rx.items(dataSource: dataSource2))
            .disposed(by: disposeBag)
    }
}
