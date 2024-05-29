//
//  FullScreenable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2018/9/12.
//  Copyright © 2018年 LinXunFeng. All rights reserved.
//

/*
 *  使用说明：
 *  specifiedView所指向的view只能通过frame设置位置和大小，不要使用snapkit。(subView则随意)
 *
 *  请在 AppDelegate 中实现以下方法
 *
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return UIApplication.shared.lxf.currentVcOrientationMask
}
 */

private var lxf_isFullKey = "lxf_isFullKey"
private var lxf_specifiedViewKey = "lxf_specifiedViewKey"
private var lxf_superViewKey = "lxf_superViewKey"
private var lxf_selfFrameKey = "lxf_selfFrameKey"
private var lxf_defaultFullScreenableConfigKey = "lxf_defaultFullScreenableConfigKey"
private var lxf_vcFullScreenableConfigKey = "lxf_vcFullScreenableConfigKey"
private var lxf_appCurFullScreenableConfigKey = "lxf_appCurFullScreenableConfigKey"
private var lxf_appCurFullScreenMasterConfigKey = "lxf_appCurFullScreenMasterConfigKey"
private var lxf_orientationChangeBlockKey = "lxf_orientationChangeBlockKey"
private var lxf_isRegisteAutoFullScreenKey = "lxf_isRegisteAutoFullScreenKey"
private var lxf_disableAutoFullScreenKey = "lxf_disableAutoFullScreenKey"

public typealias FullScreenableCompleteType = (_ isFullScreen: Bool)->Void
typealias LXFNormalBlockType = ()->Void

public let lxf_defaultAnimateDuration: Double = 0.25

/// 设置屏幕方向的方式
enum FullScreenableSetOrientationType {
    /// 通过 UIWindowScene（iOS16及以上时使用）
    case iOS16RequestGeometryUpdate
    /// 通过 UIDevice（iOS16以下使用）
    case uiDeviceSetValue
}

// MARK:- FullScreenable
public protocol FullScreenable: AnyObject, AssociatedObjectStore, LXFCompatible {}
extension FullScreenable {
    var isFullScreen: Bool {
        get { return associatedObject(forKey: &lxf_isFullKey, default: false) }
        set { setAssociatedObject(newValue, forKey: &lxf_isFullKey) }
    }
    
    fileprivate var lxf_specifiedView : UIView? {
        get { return associatedObject(forKey: &lxf_specifiedViewKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_specifiedViewKey) }
    }
    
    fileprivate var lxf_superView : UIView? {
        get { return associatedObject(forKey: &lxf_superViewKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_superViewKey) }
    }
    
    fileprivate var lxf_selfFrame : CGRect? {
        get { return associatedObject(forKey: &lxf_selfFrameKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_selfFrameKey) }
    }
    
    fileprivate func lxf_switchFullScreen(
        isEnter: Bool? = nil,
        specifiedView: UIView?,
        superView: UIView?,
        exitFullScreenToFrame : CGRect?,
        config: FullScreenableConfig? = nil,
        isAutoTrigger: Bool = false,
        completed: FullScreenableCompleteType?
    ) {
        let curVc = superView?.viewController()
        let isEnter = isEnter == nil ? !isFullScreen : isEnter!
        
        var _config: FullScreenableConfig
        if config == nil {
            var defaultConfig = FullScreenableConfig.defaultConfig()
            defaultConfig.supportInterfaceOrientation = isEnter ? .landscape : .portrait
            _config = defaultConfig
        } else {
            _config = config!
        }
        
        UIApplication.shared.lxf.currentFullScreenConfig = _config
        
        DispatchQueue.main.async {
            // isCurPortrait：在自动触发旋转屏幕的情况下，防止陷入旋转通知循环
            let curOrientation = UIDevice.current.orientation
            let isCurPortrait = curOrientation == .portrait || curOrientation == .portraitUpsideDown
            let _isEnter = isAutoTrigger ? !isCurPortrait && isEnter : isEnter
            
            UIView.animate(withDuration: _config.animateDuration) {
                // 强制横竖屏
                let orientation: UIInterfaceOrientation = _isEnter ? _config.enterFullScreenOrientation : .portrait
                if LXFSetOrientationType() == .uiDeviceSetValue {
                    // 防止 设备已经竖放导致无法退出全屏 或 设备已经横屏导致无法进入全屏
                    // 通过 UIDevice 强制横竖屏的方式才需要
                    UIApplication.shared.lxf.rotate(
                        with: UIApplication.shared.statusBarOrientation,
                        viewController: curVc
                    )
                }
                UIApplication.shared.lxf.rotate(
                    with: orientation,
                    viewController: curVc
                )
            }
        
            if _isEnter { // 进入全屏
                if self.isFullScreen { return }
                self.lxf_specifiedView = specifiedView
                self.lxf_superView = superView ?? specifiedView?.superview
                self.lxf_selfFrame = specifiedView?.frame
                
                specifiedView?.removeFromSuperview()
                if let _specifiedView = self.lxf_specifiedView,
                   let _superView = self.lxf_superView,
                   let keyWindow = LXFCurrentWindow() {
                    keyWindow.addSubview(_specifiedView)
                    // 先将 specifiedView 调整为 keyWindow 下的 frame
                    _specifiedView.frame = _superView.convert(_specifiedView.frame, to: keyWindow)
                }
                UIView.animate(withDuration: _config.animateDuration, animations: {
                    specifiedView?.frame = self.screenBounds(isFullScreen: _isEnter)
                }) { _ in
                    guard let completed = completed else{ return }
                    completed(isEnter)
                }
            } else { // 退出全屏
                if !self.isFullScreen { return }
                let specifiedView = self.lxf_specifiedView
                UIView.animate(withDuration: _config.animateDuration, animations: {
                    specifiedView?.frame = exitFullScreenToFrame ?? self.lxf_selfFrame ?? .zero
                }, completion: { _ in
                    specifiedView?.removeFromSuperview()
                    let superView = superView == nil ? self.lxf_superView : superView
                    if specifiedView != nil {
                        superView?.addSubview(specifiedView!)
                        specifiedView?.frame = self.lxf_selfFrame ?? .zero
                    }
                    guard let completed = completed else{ return }
                    completed(isEnter)
                })
            }
            self.isFullScreen = _isEnter
        }
    }
    
    /// 获取屏幕尺寸
    public func screenBounds(isFullScreen: Bool) -> CGRect {
        // iOS16开始，强制屏幕方向与之前的不一样，导致宽高不会自动变化，所以这里需要手动调整
        var bounds = UIScreen.main.bounds
        if (!isFullScreen) { // 竖屏下，不用做任何调整
            return bounds
        }
        var boundsSize = bounds.size
        if (isFullScreen && boundsSize.width < boundsSize.height) {
            // 横屏且宽依旧小于高，则需要手动调整
            let boundsOriginWidth = boundsSize.width
            boundsSize.width = boundsSize.height
            boundsSize.height = boundsOriginWidth
        }
        bounds.size = boundsSize
        return bounds
    }
}

public extension LXFNameSpace where Base: FullScreenable {
    
    func switchFullScreen(
        isEnter: Bool? = nil,
        specifiedView: UIView? = nil,
        superView: UIView? = nil,
        exitFullScreenToFrame: CGRect? = nil,
        config: FullScreenableConfig? = nil,
        completed: FullScreenableCompleteType? = nil
    ) {
        var specifiedView = specifiedView
        var superView = superView
        
        if let curView = base as? UIView {
            if !base.isFullScreen { // 进入全屏时才需要自动填写视图
                specifiedView = specifiedView == nil ? curView : specifiedView!
                superView = superView == nil ? curView.superview : superView!
            }
        }
        
        base.lxf_switchFullScreen(
            isEnter: isEnter,
            specifiedView: specifiedView,
            superView: superView,
            exitFullScreenToFrame: exitFullScreenToFrame,
            config: config,
            completed: completed
        )
    }
}

extension FullScreenable {
    public func initAutoFullScreen() {
        DispatchQueue.once(token: "FullScreenable_lxf_SwizzledViewWillAppear") {
            LXFSwizzleMethod(
                originalCls: UIViewController.self,
                originalSelector: #selector(UIViewController.viewWillAppear(_:)),
                swizzledCls: UIViewController.self,
                swizzledSelector: #selector(UIViewController.lxf_fullScreenable_viewWillAppear(_:)))
            
            LXFSwizzleMethod(
                originalCls: UIViewController.self,
                originalSelector: #selector(UIViewController.viewWillDisappear(_:)),
                swizzledCls: UIViewController.self,
                swizzledSelector: #selector(UIViewController.lxf_fullScreenable_viewWillDisappear(_:)))
        }
    }
}

extension UIViewController: AssociatedObjectStore {
    var lxf_fullScreenableConfig: FullScreenableConfig {
        get { return associatedObject(forKey: &lxf_vcFullScreenableConfigKey, default: FullScreenableConfig.defaultConfig())}
        set { setAssociatedObject(newValue, forKey: &lxf_vcFullScreenableConfigKey) }
    }
    
    var lxf_orientationChangeBlock : (()->Void)? {
        get { return associatedObject(forKey: &lxf_orientationChangeBlockKey)}
        set { setAssociatedObject(newValue, forKey: &lxf_orientationChangeBlockKey, ploicy: .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
    
    var lxf_isRegisteAutoFullScreen : Bool {
        get { return associatedObject(forKey: &lxf_isRegisteAutoFullScreenKey, default: false)}
        set { setAssociatedObject(newValue, forKey: &lxf_isRegisteAutoFullScreenKey) }
    }
    var lxf_disableAutoFullScreen : Bool {
        get { return associatedObject(forKey: &lxf_disableAutoFullScreenKey, default: false)}
        set { setAssociatedObject(newValue, forKey: &lxf_disableAutoFullScreenKey) }
    }
    
    @objc func lxf_fullScreenable_viewWillAppear(_ animated: Bool) {
        if LXFCanControlFullScreen(self) {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(lxf_orientationChangeNotification),
                name: UIDevice.orientationDidChangeNotification,
                object: nil)
            applyCurrentFullScreenableConfig()
        }
        self.lxf_fullScreenable_viewWillAppear(animated)
    }
    
    @objc func lxf_fullScreenable_viewWillDisappear(_ animated: Bool) {
        if LXFCanControlFullScreen(self) {
            NotificationCenter.default.removeObserver(
                self,
                name: UIDevice.orientationDidChangeNotification,
                object: nil)
        }
        self.lxf_fullScreenable_viewWillDisappear(animated)
    }
    
    @objc func lxf_orientationChangeNotification() {
        if !LXFCanControlFullScreen(self) { return }
        
        if lxf_disableAutoFullScreen { return }
        guard let block = lxf_orientationChangeBlock else { return }
        block()
    }
    
    fileprivate func handleConfig(_ config: FullScreenableConfig? = nil) {
        if !LXFCanControlFullScreen(self) { return }
        
        if config != nil {
            lxf_fullScreenableConfig = config!
        } else {
            lxf_fullScreenableConfig.animateDuration = lxf_defaultAnimateDuration
            lxf_fullScreenableConfig.supportInterfaceOrientation = .allButUpsideDown
        }
    }
    
    /// 应用当前控制器的控制配置
    fileprivate func applyCurrentFullScreenableConfig() {
        UIApplication.shared.lxf.currentFullScreenConfig = lxf_fullScreenableConfig
    }
}

public extension LXFNameSpace where Base : UIViewController, Base: FullScreenable {
    /// 设置全屏控制的主人
    func becomeFullScreenMaster(_ master: UIViewController? = nil) {
        UIApplication.shared.lxf.currentFullScreenMaster = master ?? self.base
        // 应用当前全屏控制主人的配置
        base.applyCurrentFullScreenableConfig()
    }
    
    /// 移除指定全屏控制的主人(如果与当前指定的不是同一个对象，则不处理)
    func resignFullScreenMaster(_ master: UIViewController? = nil) {
        if UIApplication.shared.lxf.currentFullScreenMaster != master ?? self.base { return }
        resignCurrentFullScreenMaster()
    }
    
    /// 移除当前全屏控制的主人
    func resignCurrentFullScreenMaster() {
        UIApplication.shared.lxf.currentFullScreenMaster = nil
    }
    
    /// 初始化全屏控制参数
    func setupFullScreenConfig(with config: FullScreenableConfig) {
        self.base.handleConfig(config)
        self.base.applyCurrentFullScreenableConfig()
    }
    
    func enterFullScreen(
        specifiedView: UIView? = nil,
        config: FullScreenableConfig? = nil,
        completed: FullScreenableCompleteType? = nil
    ) {
        if !LXFCanControlFullScreen(self.base) { return }
        
        var _config = config ?? self.base.lxf_fullScreenableConfig
        _config.supportInterfaceOrientation = .landscape
        
        UIApplication.shared.lxf.currentFullScreenConfig.supportInterfaceOrientation = .landscape
        self.base.lxf_disableAutoFullScreen = true
        switchFullScreen(
            isEnter: true,
            specifiedView: specifiedView,
            superView: nil,
            config: _config,
            completed: completed
        )
    }
    
    func exitFullScreen(
        superView: UIView? = nil,
        exitFullScreenToFrame: CGRect? = nil,
        config: FullScreenableConfig? = nil,
        completed: FullScreenableCompleteType? = nil
    ) {
        if !LXFCanControlFullScreen(self.base) { return }
        
        var _config = config ?? self.base.lxf_fullScreenableConfig
        _config.supportInterfaceOrientation = .portrait
        
        if self.base.lxf_isRegisteAutoFullScreen {
            if let block = self.base.lxf_orientationChangeBlock { block() }
        } else {
            UIApplication.shared.lxf.setCurrentFullScreenConfig(isEnter: false, config: _config)
        }
        switchFullScreen(
            isEnter: false,
            specifiedView: nil,
            superView: superView,
            exitFullScreenToFrame: exitFullScreenToFrame,
            config: _config,
            completed: completed
        )
        self.base.lxf_disableAutoFullScreen = false
    }
    
    func autoFullScreen(
        specifiedView: UIView? = nil,
        superView: UIView? = nil,
        exitFullScreenToFrame: CGRect? = nil,
        config: FullScreenableConfig? = nil
    ) {
        if !LXFCanControlFullScreen(self.base) { return }
        
        self.base.initAutoFullScreen()
        self.base.lxf_isRegisteAutoFullScreen = true
        self.base.handleConfig(config)
        
        weak var base = self.base
        self.base.lxf_orientationChangeBlock = {
            base?.lxf_isRegisteAutoFullScreen = true
            base?.handleConfig(config)
            if base?.lxf_disableAutoFullScreen ?? false { return }
            let orient = UIDevice.current.orientation
            switch orient {
            case .portrait : // 屏幕正常竖向
                var _config = config ?? UIApplication.shared.lxf.currentFullScreenConfig
                _config.enterFullScreenOrientation = .portrait
                base?.lxf_switchFullScreen(
                    isEnter: false,
                    specifiedView: specifiedView,
                    superView: superView,
                    exitFullScreenToFrame: exitFullScreenToFrame,
                    config: _config,
                    isAutoTrigger: true,
                    completed: nil)
                break
            case .landscapeLeft: // 屏幕左旋转
                var _config = config ?? UIApplication.shared.lxf.currentFullScreenConfig
                _config.enterFullScreenOrientation = .landscapeRight
                base?.lxf_switchFullScreen(
                    isEnter: true,
                    specifiedView: specifiedView,
                    superView: superView,
                    exitFullScreenToFrame: exitFullScreenToFrame,
                    config: _config,
                    isAutoTrigger: true,
                    completed: nil)
                break
            case .landscapeRight: // 屏幕右旋转
                var _config = config ?? UIApplication.shared.lxf.currentFullScreenConfig
                _config.enterFullScreenOrientation = .landscapeLeft
                base?.lxf_switchFullScreen(
                    isEnter: true,
                    specifiedView: specifiedView,
                    superView: superView,
                    exitFullScreenToFrame: exitFullScreenToFrame,
                    config: _config,
                    isAutoTrigger: true,
                    completed: nil)
                break
            default:
                break
            }
        }
    }
}

public extension LXFNameSpace where Base : UIView, Base : FullScreenable {
    func enterFullScreen(
        specifiedView: UIView? = nil,
        config: FullScreenableConfig? = nil,
        completed: FullScreenableCompleteType? = nil
    ) {
        let curVc = base.viewController()
        if !LXFCanControlFullScreen(curVc) { return }
        
        UIApplication.shared.lxf.currentFullScreenConfig.supportInterfaceOrientation = .landscape
        curVc?.lxf_disableAutoFullScreen = true
        switchFullScreen(
            isEnter: true,
            specifiedView: specifiedView,
            superView: nil,
            config: config,
            completed: completed
        )
    }
    
    func exitFullScreen(
        superView: UIView? = nil,
        config: FullScreenableConfig? = nil,
        completed: FullScreenableCompleteType? = nil
    ) {
        let curVc = base.lxf_superView?.viewController()
        if !LXFCanControlFullScreen(curVc) { return }
        
        let isRegisteAutoFullScreen = curVc?.lxf_isRegisteAutoFullScreen ?? false
        if isRegisteAutoFullScreen {
            if let block = curVc?.lxf_orientationChangeBlock { block() }
        } else {
            UIApplication.shared.lxf.setCurrentFullScreenConfig(isEnter: false, config: base.viewController()?.lxf_fullScreenableConfig)
        }
        switchFullScreen(
            isEnter: false,
            specifiedView: nil,
            superView: superView,
            config: config,
            completed: completed
        )
        curVc?.lxf_disableAutoFullScreen = false
    }
}

// MARK:- UIApplication
extension UIApplication: AssociatedObjectStore, LXFCompatible { }
extension LXFNameSpace where Base : UIApplication {
    /// 当前全屏配置
    fileprivate var currentFullScreenConfig : FullScreenableConfig {
        get { return UIApplication.shared.associatedObject(forKey: &lxf_appCurFullScreenableConfigKey, default: FullScreenableConfig.defaultConfig()) }
        set { UIApplication.shared.setAssociatedObject(newValue, forKey: &lxf_appCurFullScreenableConfigKey) }
    }
    
    /// 当前控制器所支持的所有方向
    public var currentVcOrientationMask: UIInterfaceOrientationMask {
        return currentFullScreenConfig.supportInterfaceOrientation
    }
    
    /// 触发屏幕旋转
    /// 注：外部请不要直接使用
    public func rotate(
        with orientation: UIInterfaceOrientation,
        viewController: UIViewController? = nil
    ) {
        switch LXFSetOrientationType() {
        case .iOS16RequestGeometryUpdate: // 适配 iOS 16.0
            if #available(iOS 16.0, *) {
                let interfaceOrientations: UIInterfaceOrientationMask
                switch orientation {
                case .portrait, .portraitUpsideDown:
                    interfaceOrientations = .portrait
                case .landscapeLeft:
                    interfaceOrientations = .landscapeLeft
                case .landscapeRight:
                    interfaceOrientations = .landscapeRight
                default: interfaceOrientations = .portrait
                }
                
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let perference = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: interfaceOrientations)
                
                windowScene?.requestGeometryUpdate(perference) { error in
                    // 强制旋转屏幕失败
                    // print("error -- \(error)")
                }
                viewController?.setNeedsUpdateOfHomeIndicatorAutoHidden()
                // 使屏幕界面和设备方向同步（iOS16的适配方式依旧需要该方法同步）
                UIViewController.attemptRotationToDeviceOrientation()
            }
        case .uiDeviceSetValue: // 旧方式
            var deviceOrientation: UIDeviceOrientation = .unknown
            switch orientation {
            case .portrait: deviceOrientation = .portrait
            case .portraitUpsideDown: deviceOrientation = .portraitUpsideDown
            case .landscapeLeft: deviceOrientation = .landscapeRight
            case .landscapeRight: deviceOrientation = .landscapeLeft
            default: deviceOrientation = .unknown
            }
            UIDevice.current.setValue(deviceOrientation.rawValue, forKey: "orientation")
            // 使屏幕界面和设备方向同步
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    /// 设置当前全屏配置
    public func setCurrentFullScreenConfig(isEnter: Bool, config: FullScreenableConfig?) {
        if config != nil { base.lxf.currentFullScreenConfig = config! }
        else { base.lxf.currentFullScreenConfig.supportInterfaceOrientation = isEnter ? .landscape : .portrait }
    }
    
    /// 是否可以控制全屏旋转
    fileprivate func canControlFullScreen(_ curAccessor: UIViewController?) -> Bool {
        guard let master = self.currentFullScreenMaster else {
            return true
        }
        if master.isEqual(NSNull()) {
            return true
        }
        return master == curAccessor
    }
    
    /// 当前拥有控制主权的对象
    fileprivate var currentFullScreenMaster : UIViewController? {
        get {
            let wrapper: LXFWeakWrapper? = UIApplication.shared.associatedObject(forKey: &lxf_appCurFullScreenMasterConfigKey)
            return wrapper?.obj as? UIViewController
        }
        set {
            let wrapper = LXFWeakWrapper()
            wrapper.obj = newValue
            UIApplication.shared.setAssociatedObject(wrapper, forKey: &lxf_appCurFullScreenMasterConfigKey)
        }
    }
}

public struct FullScreenableConfig {
    /// 全屏动画时间
    public var animateDuration: Double
    /// 进入全屏的初始方向
    public var enterFullScreenOrientation : UIInterfaceOrientation
    /// 全屏支持的所有方向
    public var supportInterfaceOrientation : UIInterfaceOrientationMask
    
    public init(
        animateDuration: Double = lxf_defaultAnimateDuration,
        enterFullScreenOrientation : UIInterfaceOrientation = .landscapeRight,
        supportInterfaceOrientation : UIInterfaceOrientationMask = .portrait
    ) {
        self.animateDuration = animateDuration
        self.enterFullScreenOrientation = enterFullScreenOrientation
        self.supportInterfaceOrientation = supportInterfaceOrientation
    }
    
    public static func setDefaultConfig(_ config: FullScreenableConfig) {
        UIApplication.shared.setAssociatedObject(
            config,
            forKey: &lxf_defaultFullScreenableConfigKey)
    }
    
    public static func defaultConfig() -> FullScreenableConfig {
        return UIApplication.shared.associatedObject(
            forKey: &lxf_defaultFullScreenableConfigKey,
            default: FullScreenableConfig())
    }
}

// MARK:- Extension
// MARK: DispatchQueue
extension DispatchQueue {
    private static var _onceTracker = [String]()
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if _onceTracker.contains(token) { return }
        _onceTracker.append(token)
        block()
    }
}

// MARK: UIView
extension UIView {
    fileprivate func viewController()->UIViewController? {
        var nextResponder: UIResponder? = self
        if self.isKind(of: UIButton.classForCoder()) {
            nextResponder = self.superview
        }
        repeat {
            nextResponder = nextResponder?.next
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
        } while nextResponder != nil
        return nil
    }
}

// MARK:- Private Method
// MARK: Rumtime
fileprivate func LXFSwizzleMethod(originalCls: AnyClass?, originalSelector: Selector, swizzledCls: AnyClass?, swizzledSelector: Selector) {
    guard let originalMethod = class_getInstanceMethod(originalCls, originalSelector) else { return }
    guard let swizzledMethod = class_getInstanceMethod(swizzledCls, swizzledSelector) else { return }
    
    let didAddMethod = class_addMethod(originalCls,
                                       originalSelector,
                                       method_getImplementation(swizzledMethod),
                                       method_getTypeEncoding(swizzledMethod))
    if didAddMethod {
        class_replaceMethod(originalCls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

// MARK: Other
fileprivate func LXFCanControlFullScreen(_ curAccessor: UIViewController?) -> Bool {
    return UIApplication.shared.lxf.canControlFullScreen(curAccessor)
}

/// 获取设置屏幕方向的方式
fileprivate func LXFSetOrientationType() -> FullScreenableSetOrientationType {
    if #available(iOS 16.0, *) {
        return .iOS16RequestGeometryUpdate
    }
    return .uiDeviceSetValue
}

/// 获取 keyWindow
fileprivate func LXFCurrentWindow() -> UIWindow? {
    if let window = UIApplication.shared.delegate?.window {
        return window
    }
    if #available(iOS 13.0, *) {
        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first {
            return window
        }
    }
    return UIApplication.shared.keyWindow
}
