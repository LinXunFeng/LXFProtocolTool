//
//  Refreshable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2018/7/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//  具体使用方式可参考以下链接：
//  https://juejin.im/post/59ee1e215188255f5a473b89
//  https://github.com/LinXunFeng/LXFProtocolTool/wiki/Refreshable

import UIKit
import MJRefresh
import RxSwift
import RxRelay
import ObjectiveC

public typealias LXFRefreshHeader = MJRefreshHeader
public typealias LXFRefreshFooter = MJRefreshFooter
public typealias LXFRefreshTrailer = MJRefreshTrailer

public typealias RefreshBlock = () -> Void
public typealias RespectiveRefreshStatus = (RefreshStatus, Int)

public enum RefreshType {
    case header
    case footer
    case trailer
}

public enum RefreshStatus {
    case none
    case beginHeaderRefresh
    case endHeaderRefresh
    case beingFooterRefresh
    case endFooterRefresh
    case beginTrailerRefresh
    case endTrailerRefresh
    case noMoreData
    case resetNoMoreData
    case hiddenHeader
    case hiddenFooter
    case hiddenTrailer
    case showHeader
    case showFooter
    case showTrailer
}

fileprivate enum TagType: Int {
    case `default` = 0
    case indiscrimination = -1
}

/* ==================== OutputRefreshProtocol ==================== */
// viewModel 中 output使用

private var refreshStatusKey = "refreshStatusKey"
private var refreshStatusRespectivelyKey = "refreshStatusRespectivelyKey"

public protocol RefreshControllable: AnyObject, AssociatedObjectStore, LXFCompatible { }

public extension LXFNameSpace where Base: RefreshControllable {
    /// 告诉外界的 scrollView 当前的刷新状态
    var refreshStatus : BehaviorRelay<RefreshStatus> {
        return base.associatedObject(
            forKey: &refreshStatusKey,
            default: BehaviorRelay<RefreshStatus>(value: .none))
    }
    /// 同 refreshStatus，但可以针对不同 scrollView 做出控制
    var refreshStatusRespective : BehaviorRelay<RespectiveRefreshStatus> {
        return base.associatedObject(
            forKey: &refreshStatusRespectivelyKey,
            default: BehaviorRelay<RespectiveRefreshStatus>(value: (.none, TagType.default.rawValue)))
    }
    
    fileprivate func autoSetRefreshStatus(
        header: LXFRefreshHeader? = nil,
        footer: LXFRefreshFooter? = nil,
        trailer: LXFRefreshTrailer? = nil
    ) -> Disposable {
        return Observable.of (
                refreshStatusRespective.asObservable(),
                refreshStatus.asObservable()
                    .flatMap { Observable.just(($0, TagType.indiscrimination.rawValue)) }
            )
            .merge()
            .subscribe(onNext: { (status, tag) in
                var isHeader = true
                var isFooter = true
                var isTrailer = true
                if tag != TagType.indiscrimination.rawValue {
                    isHeader = tag == header?.tag ?? TagType.default.rawValue
                    isFooter = tag == footer?.tag ?? TagType.default.rawValue
                    isTrailer = tag == trailer?.tag ?? TagType.default.rawValue
                }
                switch status {
                case .beginHeaderRefresh:
                    if isHeader { header?.beginRefreshing() }
                case .endHeaderRefresh:
                    if isHeader { header?.endRefreshing() }
                case .beingFooterRefresh:
                    if isFooter { footer?.beginRefreshing() }
                case .endFooterRefresh:
                    if isFooter { footer?.endRefreshing() }
                case .beginTrailerRefresh:
                    if isTrailer { trailer?.beginRefreshing() }
                case .endTrailerRefresh:
                    if isTrailer { trailer?.endRefreshing() }
                case .noMoreData:
                    if isFooter { footer?.endRefreshingWithNoMoreData() }
                case .resetNoMoreData:
                    if isFooter { footer?.resetNoMoreData() }
                case .hiddenHeader:
                    if isHeader { header?.isHidden = true }
                case .hiddenFooter:
                    if isFooter { footer?.isHidden = true }
                case .hiddenTrailer:
                    if isTrailer { trailer?.isHidden = true }
                case .showHeader:
                    if isHeader { header?.isHidden = false }
                case .showFooter:
                    if isFooter { footer?.isHidden = false }
                case .showTrailer:
                    if isTrailer { trailer?.isHidden = false }
                case .none: break
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
    fileprivate var trailerConfig: RefreshableTrailerConfig?
    
    /// 获取默认下拉配置
    ///
    /// - Returns: RefreshableHeaderConfig
    fileprivate static func defaultHeaderConfig() -> RefreshableHeaderConfig? {
        return RefreshableConfigure.shared.headerConfig
    }
    
    /// 获取默认上拉配置
    ///
    /// - Returns: RefreshableFooterConfig
    fileprivate static func defaultFooterConfig() -> RefreshableFooterConfig? {
        return RefreshableConfigure.shared.footerConfig
    }
    
    /// 获取默认左拉配置
    ///
    /// - Returns: RefreshableTrailerConfig
    fileprivate static func defaultTrailerConfig() -> RefreshableTrailerConfig? {
        return RefreshableConfigure.shared.trailerConfig
    }
    
    /// 设置默认配置
    ///
    /// - Parameters:
    ///   - headerConfig: RefreshableHeaderConfig
    ///   - footerConfig: RefreshableFooterConfig
    ///   - trailerConfig: RefreshableTrailerConfig
    public static func setDefaultConfig(
        headerConfig: RefreshableHeaderConfig?,
        footerConfig: RefreshableFooterConfig? = nil,
        trailerConfig: RefreshableTrailerConfig? = nil
    ) {
        RefreshableConfigure.shared.headerConfig = headerConfig
        RefreshableConfigure.shared.footerConfig = footerConfig
        RefreshableConfigure.shared.trailerConfig = trailerConfig
    }
}

public protocol Refreshable: LXFCompatible { }

public extension Reactive where Base: Refreshable, Base: NSObjectProtocol {
    /// 下拉控件
    ///
    /// - Parameters:
    ///   - vm: 遵守 RefreshControllable 协议的对象
    ///   - scrollView: UIScrollView 及子类
    ///   - headerConfig: 下拉控件配置
    ///   - headerInitCompleteBlock: 下拉控件初始化完成回调
    /// - Returns: Observable<Void>
    func headerRefresh<T: RefreshControllable>(
        _ vm: T,
        _ scrollView: UIScrollView,
        headerConfig: RefreshableHeaderConfig? = nil,
        headerInitCompleteBlock: ((LXFRefreshHeader?) -> Void)? = nil
    ) -> Observable<Void> {
        
        return .create { [weak base = self.base] observer -> Disposable in
            let header = base?.lxf.initRefreshHeader(
                scrollView,
                config: headerConfig)
                { observer.onNext(())
            }
            headerInitCompleteBlock?(header)
            
            return vm.lxf.autoSetRefreshStatus(header: header)
        }
    }
    
    /// 上拉控件
    ///
    /// - Parameters:
    ///   - vm: 遵守 RefreshControllable 协议的对象
    ///   - scrollView: UIScrollView 及子类
    ///   - footerConfig: 上拉控件配置
    ///   - footerInitCompleteBlock: 上拉控件初始化完成回调
    /// - Returns: Observable<Void>
    func footerRefresh<T: RefreshControllable>(
        _ vm: T,
        _ scrollView: UIScrollView,
        footerConfig: RefreshableFooterConfig? = nil,
        footerInitCompleteBlock: ((LXFRefreshFooter?) -> Void)? = nil
    ) -> Observable<Void> {
        
        return .create { [weak base = self.base] observer -> Disposable in
            let footer = base?.lxf.initRefreshFooter(
                scrollView,
                config: footerConfig)
                { observer.onNext(())
            }
            footerInitCompleteBlock?(footer)
            
            return vm.lxf.autoSetRefreshStatus(footer: footer)
        }
    }
    
    /// 左拉控件
    ///
    /// - Parameters:
    ///   - vm: 遵守 RefreshControllable 协议的对象
    ///   - scrollView: UIScrollView 及子类
    ///   - trailerConfig: 左拉控件配置
    ///   - trailerInitCompleteBlock: 左拉控件初始化完成回调
    /// - Returns: Observable<Void>
    func trailerRefresh<T: RefreshControllable>(
        _ vm: T,
        _ scrollView: UIScrollView,
        trailerConfig: RefreshableTrailerConfig? = nil,
        trailerInitCompleteBlock: ((LXFRefreshTrailer?) -> Void)? = nil
    ) -> Observable<Void> {
        
        return .create { [weak base = self.base] observer -> Disposable in
            let trailer = base?.lxf.initRefreshTrailer(
                scrollView,
                config: trailerConfig)
                { observer.onNext(())
            }
            trailerInitCompleteBlock?(trailer)
            
            return vm.lxf.autoSetRefreshStatus(trailer: trailer)
        }
    }
    
    /// 上下拉控件
    ///
    /// - Parameters:
    ///   - vm: 遵守 RefreshControllable 协议的对象
    ///   - scrollView: UIScrollView 及子类
    ///   - headerConfig: 下拉控件配置
    ///   - footerConfig: 上拉控件配置
    ///   - headerInitCompleteBlock: 下拉控件初始化完成回调
    ///   - footerInitCompleteBlock: 上拉控件初始化完成回调
    /// - Returns: Observable<RefreshType>
    func refresh<T: RefreshControllable>(
        _ vm: T,
        _ scrollView: UIScrollView,
        headerConfig: RefreshableHeaderConfig? = nil,
        footerConfig: RefreshableFooterConfig? = nil,
        headerInitCompleteBlock: ((LXFRefreshHeader?) -> Void)? = nil,
        footerInitCompleteBlock: ((LXFRefreshFooter?) -> Void)? = nil
    ) -> Observable<RefreshType> {
        
        return Observable.create { [weak base = self.base] observer -> Disposable in
            let header = base?.lxf.initRefreshHeader(
                scrollView,
                config: headerConfig)
                { observer.onNext(.header)
            }
            headerInitCompleteBlock?(header)
            
            let footer = base?.lxf.initRefreshFooter(
                scrollView,
                config: footerConfig)
                { observer.onNext(.footer)
            }
            footerInitCompleteBlock?(footer)
            
            return vm.lxf.autoSetRefreshStatus(
                header: header,
                footer: footer
            )
        }
    }
}

// MARK: 创建刷新控件
public extension LXFNameSpace where Base: Refreshable {
    @available(iOS, deprecated: 0.5.1, message: "Use rx.headerRefresh | rx.footerRefresh | rx.refresh instead")
    func initRefresh<T: RefreshControllable>(
        _ vm: T,
        _ scrollView: UIScrollView,
        headerConfig: RefreshableHeaderConfig? = nil,
        footerConfig: RefreshableFooterConfig? = nil,
        headerAction: RefreshBlock? = nil,
        footerAction: RefreshBlock? = nil
    ) -> Disposable {
        let header = headerAction == nil ? nil : initRefreshHeader(scrollView, config: headerConfig, headerAction!)
        let footer = footerAction == nil ? nil : initRefreshFooter(scrollView, config: footerConfig, footerAction!)
        return vm.lxf.autoSetRefreshStatus(header: header, footer: footer)
    }
    
    fileprivate func initRefreshHeader(
        _ scrollView: UIScrollView,
        config: RefreshableHeaderConfig? = nil,
        _ action: @escaping () -> Void
    ) -> LXFRefreshHeader? {
        
        if config == nil {
            if let headerConfig = RefreshableConfigure.defaultHeaderConfig() {
                scrollView.mj_header = createRefreshHeader(scrollView, config: headerConfig, action)
            } else {
                scrollView.mj_header = MJRefreshNormalHeader(refreshingBlock: action)
            }
            scrollView.mj_header?.tag = scrollView.tag
            return scrollView.mj_header
        }
        scrollView.mj_header = createRefreshHeader(scrollView, config: config!, action)
        scrollView.mj_header?.tag = scrollView.tag
        return scrollView.mj_header
    }
    
    fileprivate func initRefreshFooter(
        _ scrollView: UIScrollView,
        config: RefreshableFooterConfig? = nil,
        _ action: @escaping RefreshBlock
    ) -> LXFRefreshFooter? {
        
        if config == nil {
            if let footerConfig = RefreshableConfigure.defaultFooterConfig() {
                scrollView.mj_footer = createRefreshFooter(scrollView, config: footerConfig, action)
            } else {
                scrollView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: action)
            }
            scrollView.mj_footer?.tag = scrollView.tag
            return scrollView.mj_footer
        }
        
        scrollView.mj_footer = createRefreshFooter(scrollView, config: config!, action)
        scrollView.mj_footer?.tag = scrollView.tag
        return scrollView.mj_footer
    }
    
    fileprivate func initRefreshTrailer(
        _ scrollView: UIScrollView,
        config: RefreshableTrailerConfig? = nil,
        _ action: @escaping RefreshBlock
    ) -> LXFRefreshTrailer? {
        
        if config == nil {
            if let trailerConfig = RefreshableConfigure.defaultTrailerConfig() {
                scrollView.mj_trailer = createRefreshTrailer(scrollView, config: trailerConfig, action)
            } else {
                scrollView.mj_trailer = MJRefreshNormalTrailer(refreshingBlock: action)
            }
            scrollView.mj_trailer?.tag = scrollView.tag
            return scrollView.mj_trailer
        }
        
        scrollView.mj_trailer = createRefreshTrailer(scrollView, config: config!, action)
        scrollView.mj_trailer?.tag = scrollView.tag
        return scrollView.mj_trailer
    }
    
    fileprivate func createRefreshHeader(
        _ scrollView: UIScrollView,
        config: RefreshableHeaderConfig,
        _ action: @escaping () -> Void
    ) -> LXFRefreshHeader? {
        
        var header: MJRefreshStateHeader?
        switch config.type {
        case .normal:
            let normalHeader = MJRefreshNormalHeader(refreshingBlock: action)
            normalHeader.loadingView?.style = config.activityIndicatorViewStyle
            header = normalHeader
        case .gif:
            let gifHeader = MJRefreshGifHeader { action() }
            if config.idleImages.count > 0 {
                gifHeader.setImages(config.idleImages, for: .idle)
            }
            if config.pullingImages.count > 0 {
                gifHeader.setImages(config.pullingImages, for: .pulling)
            }
            if config.refreshingImages.count > 0 {
                gifHeader.setImages(config.refreshingImages, for: .refreshing)
            }
            header = gifHeader
        case .diy(let HeaderType):
            return HeaderType.init{ action() }
        }
        
        // title
        if config.idleTitle != nil { header?.setTitle(config.idleTitle!, for: .idle) }
        if config.pullingTitle != nil { header?.setTitle(config.pullingTitle!, for: .pulling) }
        if config.refreshingTitle != nil { header?.setTitle(config.refreshingTitle!, for: .refreshing) }
        
        // font
        if config.stateFont != nil { header?.stateLabel?.font = config.stateFont! }
        if config.lastUpdatedTimeFont != nil { header?.lastUpdatedTimeLabel?.font = config.lastUpdatedTimeFont! }
        
        // textColor
        if config.stateColor != nil { header?.stateLabel?.textColor = config.stateColor! }
        if config.lastUpdatedTimeColor != nil { header?.lastUpdatedTimeLabel?.textColor = config.lastUpdatedTimeColor! }
        
        // hide
        header?.stateLabel?.isHidden = config.hideState
        header?.lastUpdatedTimeLabel?.isHidden = config.hideLastUpdatedTime
        
        // labelLeftInset
        if config.labelLeftInset != nil { header?.labelLeftInset = config.labelLeftInset! }
        
        return header
    }
    
    fileprivate func createRefreshFooter(
        _ scrollView: UIScrollView,
        config: RefreshableFooterConfig,
        _ action: @escaping () -> Void
    ) -> LXFRefreshFooter? {
        
        var autoFooter : MJRefreshAutoStateFooter?
        var backFooter : MJRefreshBackStateFooter?
        
        switch config.type {
        case .autoNormal:
            let autoNormalFooter = MJRefreshAutoNormalFooter(refreshingBlock: action)
            autoNormalFooter.loadingView?.style = config.activityIndicatorViewStyle
            autoFooter = autoNormalFooter
        case .autoGif:
            let autoGifFooter = MJRefreshAutoGifFooter(refreshingBlock: action)
            if config.images.count > 0 {
                autoGifFooter.setImages(config.images, for: MJRefreshState.refreshing)
            }
            autoFooter = autoGifFooter
        case .backNormal:
            let backNormalFooter = MJRefreshBackNormalFooter(refreshingBlock: action)
            backNormalFooter.loadingView?.style = config.activityIndicatorViewStyle
            backFooter = backNormalFooter
        case .backGif:
            let backGifFooter = MJRefreshBackGifFooter(refreshingBlock: action)
            if config.images.count > 0 {
                backGifFooter.setImages(config.images, for: MJRefreshState.refreshing)
            }
            backFooter = backGifFooter
        case .diy(let FooterType):
            return FooterType.init{ action() }
        }
        
        if autoFooter != nil {
            // title
            if config.idleTitle != nil { autoFooter?.setTitle(config.idleTitle!, for: .idle) }
            if config.refreshingTitle != nil { autoFooter?.setTitle(config.refreshingTitle!, for: .refreshing) }
            if config.norMoreDataTitle != nil { autoFooter?.setTitle(config.norMoreDataTitle!, for: .noMoreData) }
            
            // font
            if config.stateFont != nil { autoFooter?.stateLabel?.font = config.stateFont! }
            
            // textColor
            if config.stateColor != nil { autoFooter?.stateLabel?.textColor = config.stateColor! }
            
            // hide
            autoFooter?.stateLabel?.isHidden = config.hideState
            
            // labelLeftInset
            if config.labelLeftInset != nil { autoFooter?.labelLeftInset = config.labelLeftInset! }
            
            return autoFooter
        } else {
            // title
            if config.idleTitle != nil { backFooter?.setTitle(config.idleTitle!, for: .idle) }
            if config.refreshingTitle != nil { backFooter?.setTitle(config.refreshingTitle!, for: .refreshing) }
            if config.norMoreDataTitle != nil { backFooter?.setTitle(config.norMoreDataTitle!, for: .noMoreData) }
            
            // font
            if config.stateFont != nil { backFooter?.stateLabel?.font = config.stateFont! }
            
            // textColor
            if config.stateColor != nil { backFooter?.stateLabel?.textColor = config.stateColor! }
            
            // hide
            backFooter?.stateLabel?.isHidden = config.hideState
            
            // labelLeftInset
            if config.labelLeftInset != nil { backFooter?.labelLeftInset = config.labelLeftInset! }
            
            return backFooter
        }
    }
    
    fileprivate func createRefreshTrailer(
        _ scrollView: UIScrollView,
        config: RefreshableTrailerConfig,
        _ action: @escaping () -> Void
    ) -> LXFRefreshTrailer? {
        
        var trailer: MJRefreshStateTrailer?
        switch config.type {
        case .normal:
            let normalTrailer = MJRefreshNormalTrailer(refreshingBlock: action)
            normalTrailer.arrowView?.isHidden = config.hideArrowView
            if let arrowViewImage = config.arrowViewImage {
                normalTrailer.arrowView?.image = arrowViewImage
            }
            trailer = normalTrailer
        }
        
        trailer?.ignoredScrollViewContentInsetRight = config.ignoredScrollViewContentInsetRight
        
        // title
        if config.idleTitle != nil { trailer?.setTitle(config.idleTitle!, for: .idle) }
        if config.pullingTitle != nil { trailer?.setTitle(config.pullingTitle!, for: .pulling) }
        if config.refreshingTitle != nil { trailer?.setTitle(config.refreshingTitle!, for: .refreshing) }
        
        // font
        if let stateFont = config.stateFont {
            trailer?.stateLabel?.font = stateFont
        }
        
        // textColor
        if let stateColor = config.stateColor {
            trailer?.stateLabel?.textColor = stateColor
        }
        
        // hide
        trailer?.stateLabel?.isHidden = config.hideState
        
        return trailer
    }
}

// MARK:- RefreshableConfig
/* ================== RefreshableConfig ================== */
// Header & Footer「DIY」Configure

public enum RefreshHeaderType {
    case normal
    case gif
    case diy(type: MJRefreshHeader.Type)
}

public enum RefreshFooterType {
    case autoNormal
    case autoGif
    case backNormal
    case backGif
    case diy(type: MJRefreshFooter.Type)
}

public enum RefreshTrailerType {
    case normal
}

public struct RefreshableHeaderConfig {
    /// 当type为diy时，其它属性就不用再传递了
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
    /// 当type为diy时，其它属性就不用再传递了
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
    
    public init(
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

public struct RefreshableTrailerConfig {
    /// 类型
    var type : RefreshTrailerType
    
    /// 忽略多少scrollView的contentInset的right
    var ignoredScrollViewContentInsetRight: CGFloat = 0
    
    // 标题
    /// 标题（普通闲置状态）
    var idleTitle : String? = nil
    /// 标题（正在刷新中的状态）
    var refreshingTitle : String? = nil
    /// 标题（松开就可以进行刷新的状态）
    var pullingTitle : String? = nil
    
    // 状态
    /// 状态文字的字体
    var stateFont : UIFont? = nil
    /// 状态文字的颜色
    var stateColor : UIColor? = nil
    /// 是否隐藏状态
    var hideState = false
    
    // 箭头
    /// 箭头图标
    var arrowViewImage: UIImage?
    /// 是否隐藏箭头
    var hideArrowView = false
    
    public init(
        type: RefreshTrailerType = .normal,
        ignoredScrollViewContentInsetRight: CGFloat = 0,
        idleTitle: String? = nil,
        pullingTitle: String? = nil,
        refreshingTitle: String? = nil,
        stateFont: UIFont? = nil,
        stateColor: UIColor? = nil,
        hideState: Bool = false,
        arrowViewImage: UIImage? = nil,
        hideArrowView: Bool = false
    ) {
        self.type = type
        self.ignoredScrollViewContentInsetRight = ignoredScrollViewContentInsetRight
        self.idleTitle = idleTitle
        self.pullingTitle = pullingTitle
        self.refreshingTitle = refreshingTitle
        self.stateFont = stateFont
        self.stateColor = stateColor
        self.hideState = hideState
        self.arrowViewImage = arrowViewImage
        self.hideArrowView = hideArrowView
    }
}
