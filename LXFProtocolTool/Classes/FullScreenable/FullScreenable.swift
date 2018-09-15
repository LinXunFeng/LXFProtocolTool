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
    if UIApplication.shared.lxf.allowRotation {
        return UIInterfaceOrientationMask.landscape
    }
    return .portrait
}
 */

private var lxf_isFullKey = "lxf_isFullKey"
private var lxf_specifiedViewKey = "lxf_specifiedViewKey"
private var lxf_superViewKey = "lxf_superViewKey"
private var lxf_selfFrameKey = "lxf_selfFrameKey"
private var lxf_allowRotationKey = "lxf_allowRotationKey"
public typealias FullScreenableCompleteType = (_ isFullScreen: Bool)->Void

// MARK:- FullScreenable
public protocol FullScreenable: AssociatedObjectStore, LXFCompatible { }
public extension LXFNameSpace where Base: FullScreenable {
    var isFullScreen: Bool {
        get { return base.associatedObject(forKey: &lxf_isFullKey, default: false) }
        set { base.setAssociatedObject(newValue, forKey: &lxf_isFullKey) }
    }
    
    fileprivate weak var lxf_specifiedView : UIView? {
        get { return base.associatedObject(forKey: &lxf_specifiedViewKey) }
        set { base.setAssociatedObject(newValue, forKey: &lxf_specifiedViewKey) }
    }
    
    fileprivate weak var lxf_superView : UIView? {
        get { return base.associatedObject(forKey: &lxf_superViewKey) }
        set { base.setAssociatedObject(newValue, forKey: &lxf_superViewKey) }
    }
    
    fileprivate var lxf_selfFrame : CGRect? {
        get { return base.associatedObject(forKey: &lxf_selfFrameKey) }
        set { base.setAssociatedObject(newValue, forKey: &lxf_selfFrameKey) }
    }
    
    fileprivate func lxf_switchFullScreen(isEnter: Bool? = nil, specifiedView: UIView?, superView: UIView?, config: FullScreenableConfig? = nil, completed: FullScreenableCompleteType?) {
        let config = config == nil ? FullScreenableConfig() : config!
        let isEnter = isEnter == nil ? !isFullScreen : isEnter!
        
        // 开启/关闭屏幕旋转
        UIApplication.shared.lxf.allowRotation = isEnter
        
        // 强制横竖屏
        let orientation: UIInterfaceOrientation = isEnter ? config.enterFullScreenOrientation : .portrait
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        
        if isEnter { // 进入全屏
            if isFullScreen { return }
            // if specifiedView == nil { return }
            lxf_specifiedView = specifiedView
            lxf_superView = superView
            lxf_selfFrame = specifiedView?.frame
            
            specifiedView?.removeFromSuperview()
            if specifiedView != nil {
                UIApplication.shared.keyWindow?.addSubview(specifiedView!)
            }
            UIView.animate(withDuration: config.animateDuration, animations: {
                specifiedView?.frame = UIScreen.main.bounds
            }) { _ in
                guard let completed = completed else{ return }
                completed(isEnter)
            }
        } else { // 退出全屏
            if !isFullScreen { return }
            let specifiedView = self.lxf_specifiedView
            UIView.animate(withDuration: config.animateDuration, animations: {
                specifiedView?.frame = self.lxf_selfFrame ?? CGRect.zero
            }, completion: { _ in
                specifiedView?.removeFromSuperview()
                let superView = superView == nil ? self.lxf_superView : superView
                if specifiedView != nil {
                   superView?.addSubview(specifiedView!)
                }
                guard let completed = completed else{ return }
                completed(isEnter)
            })
        }
        isFullScreen = isEnter
    }
    
    func switchFullScreen(isEnter: Bool? = nil, specifiedView: UIView? = nil, superView: UIView? = nil, config: FullScreenableConfig? = nil, completed: FullScreenableCompleteType? = nil) {
        var specifiedView = specifiedView
        var superView = superView
        
        if let curView = base as? UIView {
            specifiedView = specifiedView == nil ? curView : specifiedView!
            superView = superView == nil ? curView.superview : superView!
        }
        
        lxf_switchFullScreen(
            isEnter: isEnter,
            specifiedView: specifiedView,
            superView: superView,
            config: config,
            completed: completed
        )
    }
}

public extension LXFNameSpace where  Base : UIViewController, Base: FullScreenable {
    
    func enterFullScreen(specifiedView: UIView, config: FullScreenableConfig? = nil, completed: FullScreenableCompleteType? = nil) {
        switchFullScreen(
            isEnter: true,
            specifiedView: specifiedView,
            superView: nil,
            config: config,
            completed: completed
        )
    }
    
    func exitFullScreen(superView: UIView, config: FullScreenableConfig? = nil, completed: FullScreenableCompleteType? = nil) {
        switchFullScreen(
            isEnter: false,
            specifiedView: nil,
            superView: superView,
            config: config,
            completed: completed
        )
    }
}

public extension LXFNameSpace where Base : UIView, Base : FullScreenable {
    func enterFullScreen(specifiedView: UIView? = nil, config: FullScreenableConfig? = nil, completed: FullScreenableCompleteType? = nil) {
        switchFullScreen(
            isEnter: true,
            specifiedView: specifiedView,
            superView: nil,
            config: config,
            completed: completed
        )
    }
    
    func exitFullScreen(superView: UIView? = nil, config: FullScreenableConfig? = nil, completed: FullScreenableCompleteType? = nil) {
        switchFullScreen(
            isEnter: false,
            specifiedView: nil,
            superView: superView,
            config: config,
            completed: completed
        )
    }
}

// MARK:- UIApplication
extension UIApplication: AssociatedObjectStore, LXFCompatible { }
extension LXFNameSpace where Base : UIApplication {
    /// 控制屏幕旋转
    public var allowRotation: Bool {
        get { return UIApplication.shared.associatedObject(forKey: &lxf_allowRotationKey, default: false) }
        set {  UIApplication.shared.setAssociatedObject(newValue, forKey: &lxf_allowRotationKey) }
    }
}

public struct FullScreenableConfig {
    var animateDuration = 0.25
    var enterFullScreenOrientation : UIInterfaceOrientation = .landscapeRight
}
