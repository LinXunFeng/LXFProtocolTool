//
//  Refreshable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2018/7/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//  具体使用方式可参考以下链接：
//  https://juejin.im/post/59ee1e215188255f5a473b89

import UIKit
import MJRefresh
import RxSwift
import ObjectiveC

typealias RefreshHeader = MJRefreshHeader
typealias RefreshFooter = MJRefreshFooter
public typealias RefreshBlock = () -> Void
public enum RefreshType {
    case header
    case footer
}

public enum RefreshStatus {
    case none
    case beginHeaderRefresh
    case endHeaderRefresh
    case beingFooterRefresh
    case endFooterRefresh
    case noMoreData
    case resetNoMoreData
    case hiddenHeader
    case hiddenFooter
    case showHeader
    case showFooter
}

/* ==================== OutputRefreshProtocol ==================== */
// viewModel 中 output使用

private var refreshStatusKey = "refreshStatusKey"

public protocol RefreshControllable: class, AssociatedObjectStore, LXFCompatible { }

public extension LXFNameSpace where Base: RefreshControllable {
    // 告诉外界的tableView当前的刷新状态
    var refreshStatus : Variable<RefreshStatus> {
        return base.associatedObject(
            forKey: &refreshStatusKey,
            default: Variable<RefreshStatus>(.none))
    }
    
    fileprivate func autoSetRefreshStatus(header: RefreshHeader?, footer: RefreshFooter?) -> Disposable {
        return  refreshStatus.asObservable()
            .subscribe(onNext: { (status) in
                switch status {
                case .beginHeaderRefresh:
                    header?.beginRefreshing()
                case .endHeaderRefresh:
                    header?.endRefreshing()
                case .beingFooterRefresh:
                    footer?.beginRefreshing()
                case .endFooterRefresh:
                    footer?.endRefreshing()
                case .noMoreData:
                    footer?.endRefreshingWithNoMoreData()
                case .resetNoMoreData:
                    footer?.resetNoMoreData()
                case .hiddenHeader:
                    header?.isHidden = true
                case .hiddenFooter:
                    footer?.isHidden = true
                case .showHeader:
                    header?.isHidden = false
                case .showFooter:
                    footer?.isHidden = false
                case .none:
                    break
                }
            })
    }
}

// MARK:- Refreshable
/* ================== Refreshable ================== */
// 需要使用 「刷新功能」 时使用

// MARK: 设置默认配置
public class RefreshableConfigure: NSObject {
    static let shared = RefreshableConfigure()
    private override init() { super.init() }
    
    fileprivate var headerConfig : RefreshableHeaderConfig?
    fileprivate var footerConfig: RefreshableFooterConfig?
    
    fileprivate static func defaultHeaderConfig() -> RefreshableHeaderConfig? {
        return RefreshableConfigure.shared.headerConfig
    }
    fileprivate static func defaultFooterConfig() -> RefreshableFooterConfig? {
        return RefreshableConfigure.shared.footerConfig
    }
    public static func setDefaultConfig(headerConfig: RefreshableHeaderConfig?, footerConfig: RefreshableFooterConfig? = nil) {
        RefreshableConfigure.shared.headerConfig = headerConfig
        RefreshableConfigure.shared.footerConfig = footerConfig
    }
}

public protocol Refreshable: LXFCompatible { }

public extension Reactive where Base : Refreshable {
    func headerRefresh<T: RefreshControllable>(_ vm: T, _ scrollView: UIScrollView, headerConfig: RefreshableHeaderConfig? = nil) -> Observable<Void> {
        return .create { observer -> Disposable in
            vm.lxf.autoSetRefreshStatus(
                header: self.base.lxf.initRefreshHeader(
                        scrollView,
                        config: headerConfig)
                        { observer.onNext(()) },
                footer: nil)
        }
    }
    
    func footerRefresh<T: RefreshControllable>(_ vm: T, _ scrollView: UIScrollView, footerConfig: RefreshableFooterConfig? = nil) -> Observable<Void> {
        return .create { observer -> Disposable in
            vm.lxf.autoSetRefreshStatus(
                header: nil,
                footer: self.base.lxf.initRefreshFooter(
                        scrollView,
                        config: footerConfig)
                        { observer.onNext(()) }
            )
        }
    }
    
    func refresh<T: RefreshControllable>(_ vm: T, _ scrollView: UIScrollView, headerConfig: RefreshableHeaderConfig? = nil, footerConfig: RefreshableFooterConfig? = nil) -> Observable<RefreshType> {
        return Observable.create { observer -> Disposable in
            vm.lxf.autoSetRefreshStatus(
                header: self.base.lxf.initRefreshHeader(
                        scrollView,
                        config: headerConfig)
                        { observer.onNext(.header) },
                footer: self.base.lxf.initRefreshFooter(
                        scrollView,
                        config: footerConfig)
                        { observer.onNext(.footer) }
            )
        }
    }
}

// MARK: 创建刷新控件
public extension LXFNameSpace where Base: Refreshable {
    @available(iOS, deprecated: 0.5.1, message: "Use rx.headerRefresh | rx.footerRefresh | rx.refresh instead")
    public func initRefresh<T: RefreshControllable>(_ vm: T, _ scrollView: UIScrollView, headerConfig: RefreshableHeaderConfig? = nil, footerConfig: RefreshableFooterConfig? = nil, headerAction: RefreshBlock? = nil, footerAction: RefreshBlock? = nil) -> Disposable {
        let header = headerAction == nil ? nil : initRefreshHeader(scrollView, config: headerConfig, headerAction!)
        let footer = footerAction == nil ? nil : initRefreshFooter(scrollView, config: footerConfig, footerAction!)
        return vm.lxf.autoSetRefreshStatus(header: header, footer: footer)
    }
    
    fileprivate func initRefreshHeader(_ scrollView: UIScrollView, config: RefreshableHeaderConfig? = nil, _ action: @escaping () -> Void) -> RefreshHeader {
        if config == nil {
            if let headerConfig = RefreshableConfigure.defaultHeaderConfig() {
                scrollView.mj_header = createRefreshHeader(scrollView, config: headerConfig, action)
            } else {
                scrollView.mj_header = MJRefreshNormalHeader(refreshingBlock: action)
            }
            return scrollView.mj_header
        }
        scrollView.mj_header = createRefreshHeader(scrollView, config: config!, action)
        return scrollView.mj_header
    }
    
    fileprivate func initRefreshFooter(_ scrollView: UIScrollView, config: RefreshableFooterConfig? = nil, _ action: @escaping RefreshBlock) -> RefreshFooter {
        if config == nil {
            if let footerConfig = RefreshableConfigure.defaultFooterConfig() {
                scrollView.mj_footer = createRefreshFooter(scrollView, config: footerConfig, action)
            } else {
                scrollView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: action)
            }
            return scrollView.mj_footer
        }
        
        scrollView.mj_footer = createRefreshFooter(scrollView, config: config!, action)
        return scrollView.mj_footer
    }
    
    fileprivate func createRefreshHeader(_ scrollView: UIScrollView, config: RefreshableHeaderConfig ,_ action: @escaping () -> Void) -> RefreshHeader? {
        var header: MJRefreshStateHeader?
        switch config.type {
        case .normal:
            let normalHeader = MJRefreshNormalHeader(refreshingBlock: action)
            normalHeader?.activityIndicatorViewStyle = config.activityIndicatorViewStyle
            header = normalHeader
        case .gif:
            let gifHeader = MJRefreshGifHeader { action() }
            if config.idleImages.count > 0 {
                gifHeader?.setImages(config.idleImages, for: .idle)
            }
            if config.pullingImages.count > 0 {
                gifHeader?.setImages(config.pullingImages, for: .pulling)
            }
            if config.refreshingImages.count > 0 {
                gifHeader?.setImages(config.refreshingImages, for: .refreshing)
            }
            header = gifHeader
        }
        
        // title
        if config.idleTitle != nil { header?.setTitle(config.idleTitle!, for: .idle) }
        if config.pullingTitle != nil { header?.setTitle(config.pullingTitle!, for: .pulling) }
        if config.refreshingTitle != nil { header?.setTitle(config.refreshingTitle!, for: .refreshing) }
        
        // font
        if config.stateFont != nil { header?.stateLabel.font = config.stateFont! }
        if config.lastUpdatedTimeFont != nil { header?.lastUpdatedTimeLabel.font = config.lastUpdatedTimeFont! }
        
        // textColor
        if config.stateColor != nil { header?.stateLabel.textColor = config.stateColor! }
        if config.lastUpdatedTimeColor != nil { header?.lastUpdatedTimeLabel.textColor = config.lastUpdatedTimeColor! }
        
        // hide
        header?.stateLabel.isHidden = config.hideState
        header?.lastUpdatedTimeLabel.isHidden = config.hideLastUpdatedTime
        
        // labelLeftInset
        if config.labelLeftInset != nil { header?.labelLeftInset = config.labelLeftInset! }
        
        return header
    }
    
    fileprivate func createRefreshFooter(_ scrollView: UIScrollView, config: RefreshableFooterConfig ,_ action: @escaping () -> Void) -> RefreshFooter? {
        var autoFooter : MJRefreshAutoStateFooter?
        var backFooter : MJRefreshBackStateFooter?
        
        switch config.type {
        case .autoNormal:
            let autoNormalFooter = MJRefreshAutoNormalFooter(refreshingBlock: action)
            autoNormalFooter?.activityIndicatorViewStyle = config.activityIndicatorViewStyle
            autoFooter = autoNormalFooter
        case .autoGif:
            let autoGifFooter = MJRefreshAutoGifFooter(refreshingBlock: action)
            if config.images.count > 0 {
                autoGifFooter?.setImages(config.images, for: MJRefreshState.refreshing)
            }
            autoFooter = autoGifFooter
        case .backNormal:
            let backNormalFooter = MJRefreshBackNormalFooter(refreshingBlock: action)
            backNormalFooter?.activityIndicatorViewStyle = config.activityIndicatorViewStyle
            backFooter = backNormalFooter
        case .backGif:
            let backGifFooter = MJRefreshBackGifFooter(refreshingBlock: action)
            if config.images.count > 0 {
                backGifFooter?.setImages(config.images, for: MJRefreshState.refreshing)
            }
            backFooter = backGifFooter
        }
        
        if autoFooter != nil {
            // title
            if config.idleTitle != nil { autoFooter?.setTitle(config.idleTitle!, for: .idle) }
            if config.refreshingTitle != nil { autoFooter?.setTitle(config.refreshingTitle!, for: .refreshing) }
            if config.norMoreDataTitle != nil { autoFooter?.setTitle(config.norMoreDataTitle!, for: .noMoreData) }
            
            // font
            if config.stateFont != nil { autoFooter?.stateLabel.font = config.stateFont! }
            
            // textColor
            if config.stateColor != nil { autoFooter?.stateLabel.textColor = config.stateColor! }
            
            // hide
            autoFooter?.stateLabel.isHidden = config.hideState
            
            // labelLeftInset
            if config.labelLeftInset != nil { autoFooter?.labelLeftInset = config.labelLeftInset! }
            
            return autoFooter
        } else {
            // title
            if config.idleTitle != nil { backFooter?.setTitle(config.idleTitle!, for: .idle) }
            if config.refreshingTitle != nil { backFooter?.setTitle(config.refreshingTitle!, for: .refreshing) }
            if config.norMoreDataTitle != nil { backFooter?.setTitle(config.norMoreDataTitle!, for: .noMoreData) }
            
            // font
            if config.stateFont != nil { backFooter?.stateLabel.font = config.stateFont! }
            
            // textColor
            if config.stateColor != nil { backFooter?.stateLabel.textColor = config.stateColor! }
            
            // hide
            backFooter?.stateLabel.isHidden = config.hideState
            
            // labelLeftInset
            if config.labelLeftInset != nil { backFooter?.labelLeftInset = config.labelLeftInset! }
            
            return backFooter
        }
    }
}

// MARK:- RefreshableConfig
/* ================== RefreshableConfig ================== */
// Header & Footer「DIY」Configure

public enum RefreshHeaderType {
    case normal
    case gif
}

public enum RefreshFooterType {
    case autoNormal
    case autoGif
    case backNormal
    case backGif
}

public struct RefreshableHeaderConfig {
    var type : RefreshHeaderType = .normal
    
    // title
    var idleTitle : String? = nil // Pull down to refresh
    var pullingTitle : String? = nil // Release to refresh
    var refreshingTitle : String? = nil // Loading ...
    
    // font
    var stateFont : UIFont? = nil
    var lastUpdatedTimeFont : UIFont? = nil
    
    // textColor
    var stateColor : UIColor? = nil
    var lastUpdatedTimeColor : UIColor? = nil
    
    // hide
    var hideState = false
    var hideLastUpdatedTime = false
    
    /** 文字距离圈圈、箭头的距离 */
    var labelLeftInset: CGFloat?
    
    // normal type
    var activityIndicatorViewStyle: UIActivityIndicatorView.Style = .gray
    
    // gif type images
    var idleImages: [UIImage] = []
    var pullingImages: [UIImage] = []
    var refreshingImages: [UIImage] = []
    
    public init(
        type: RefreshHeaderType = .normal,
        idleTitle: String? = nil,
        pullingTitle: String? = nil,
        refreshingTitle: String? = nil,
        stateFont: UIFont? = nil,
        lastUpdatedTimeFont: UIFont? = nil,
        stateColor: UIColor? = nil,
        lastUpdatedTimeColor: UIColor? = nil,
        hideState: Bool = false,
        hideLastUpdatedTime: Bool = false,
        labelLeftInset: CGFloat? = nil,
        activityIndicatorViewStyle: UIActivityIndicatorView.Style = .gray,
        idleImages: [UIImage] = [],
        pullingImages: [UIImage] = [],
        refreshingImages: [UIImage] = []
    ) {
        self.type = type
        self.idleTitle = idleTitle
        self.pullingTitle = pullingTitle
        self.refreshingTitle = refreshingTitle
        self.stateFont = stateFont
        self.lastUpdatedTimeFont = lastUpdatedTimeFont
        self.stateColor = stateColor
        self.lastUpdatedTimeColor = lastUpdatedTimeColor
        self.hideState = hideState
        self.hideLastUpdatedTime = hideLastUpdatedTime
        self.labelLeftInset = labelLeftInset
        self.activityIndicatorViewStyle = activityIndicatorViewStyle
        self.idleImages = idleImages
        self.pullingImages = pullingImages
        self.refreshingImages = refreshingImages
    }
}

public struct RefreshableFooterConfig {
    var type : RefreshFooterType = .autoNormal
    
    // title
    var idleTitle : String? = nil // Click or drag up to refresh
    var refreshingTitle : String? = nil // Loading more ...
    var norMoreDataTitle : String? = nil // No more data
    
    // font
    var stateFont : UIFont? = nil
    
    // textColor
    var stateColor : UIColor? = nil
    
    // hide
    var hideState = false
    
    /** 文字距离圈圈、箭头的距离 */
    var labelLeftInset: CGFloat?
    
    // normal type
    var activityIndicatorViewStyle: UIActivityIndicatorView.Style = .gray
    
    // gif type images
    var images: [UIImage] = []
    
    init(
        type: RefreshFooterType = .autoNormal,
        idleTitle: String? = nil,
        refreshingTitle: String? = nil,
        norMoreDataTitle: String? = nil,
        stateFont: UIFont? = nil,
        stateColor: UIColor? = nil,
        hideState: Bool = false,
        labelLeftInset: CGFloat? = nil,
        activityIndicatorViewStyle: UIActivityIndicatorView.Style = .gray,
        images: [UIImage] = []
    ) {
        self.type = type
        self.idleTitle = idleTitle
        self.refreshingTitle = refreshingTitle
        self.norMoreDataTitle = norMoreDataTitle
        self.stateFont = stateFont
        self.stateColor = stateColor
        self.hideState = hideState
        self.labelLeftInset = labelLeftInset
        self.activityIndicatorViewStyle = activityIndicatorViewStyle
        self.images = images
    }
}

