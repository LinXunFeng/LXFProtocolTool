//
//  LXFRefreshableTrailerController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2021/7/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift
import RxDataSources
import LXFProtocolTool
import ReusableKit
import Then

class LXFRefreshableTrailerController: UIViewController, View, Refreshable {
    var disposeBag: DisposeBag = DisposeBag()
    
    fileprivate struct Reusable {
        static let refreshableCell = ReusableCell<LXFRefreshableTrailerCell>()
    }
    
    fileprivate lazy var dataSource = self.dataSourceFactory()
    
    fileprivate lazy var listViewLayout: UICollectionViewFlowLayout = {
        $0.minimumInteritemSpacing = 0
        $0.minimumLineSpacing = 10
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: 100, height: 200)
        return $0
    }(UICollectionViewFlowLayout())
    
    fileprivate lazy var listView: UICollectionView = { [unowned self] in
        $0.backgroundColor = .white
        $0.register(Reusable.refreshableCell)
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: listViewLayout))
    
    init(
        reactor: LXFRefreshableTrailerReactor
    ) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
        self.title = "Refreshable"
    }
    
    deinit {
        print("deinit -- LXFRefreshableTrailerController")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(listView)
        listView.frame = CGRect(
            x: 0,
            y: Configs.Screen.navibarH,
            width: Configs.Screen.width,
            height: 200
        )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.reactor?.action.onNext(.fetchList(true))
//            self.reactor?.action.onNext(.beginRefresh)
        }
    }
    
    fileprivate func dataSourceFactory() -> RxCollectionViewSectionedReloadDataSource<LXFRefreshableSection> {
        return .init(configureCell: { (dataSource, collectionView, indexPath, sectionItem) -> LXFRefreshableTrailerCell in
            let cell = collectionView.dequeue(Reusable.refreshableCell, for: indexPath)
            switch sectionItem {
            case let .item(reactor):
                cell.reactor = reactor
            }
            return cell
        })
    }
    
    func bind(reactor: LXFRefreshableTrailerReactor) {
        
        // State
        reactor.state.map { $0.sections }
            .bind(to: listView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        self.rx.trailerRefresh(reactor, self.listView, trailerConfig: RefreshTrailerConfig.normal)
//        self.rx.trailerRefresh(reactor, self.listView, trailerConfig: RefreshTrailerConfig.diy)
        self.rx.trailerRefresh(reactor, self.listView)
            .map { .fetchList(false) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// 常用配置
struct RefreshTrailerConfig {
    
    static let normal = RefreshableTrailerConfig(
        idleTitle: "继续滑动",
        pullingTitle: "松开加载下一页",
        refreshingTitle: "加载中",
        stateFont: UIFont.systemFont(ofSize: 20),
        stateColor: .systemBlue,
        hideArrowView: true
    )
    
    static let diy = RefreshableTrailerConfig(type: .diy(type: LXFDIYTrailer.self))
}
