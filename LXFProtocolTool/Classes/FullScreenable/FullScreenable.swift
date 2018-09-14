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
    if UIApplication.shared.allowRotation { // 允许旋转时所支持的方向
        return UIInterfaceOrientationMask.landscape
    }
    return .portrait
}
 */

public protocol FullScreenable: AssociatedObjectStore, LXFCompatible { }

private var lxf_isFullKey = "lxf_isFullKey"
private var lxf_superViewKey = "lxf_superViewKey"
private var lxf_selfFrameKey = "lxf_selfFrameKey"
private var lxf_allowRotationKey = "lxf_allowRotationKey"

public extension LXFNameSpace where Base: FullScreenable {
    var isFullScreen: Bool {
        return base.associatedObject(forKey: &lxf_isFullKey, default: false)
    }
    fileprivate var animateDuration: Double {
        return 0.25
    }
    
    fileprivate weak var lxf_superView : UIView? {
        return base.associatedObject(forKey: &lxf_superViewKey)
    }
    
    fileprivate var lxf_selfFrame : CGRect? {
        return base.associatedObject(forKey: &lxf_selfFrameKey)
    }
    
    fileprivate func lxf_switchFullScreen(isEnter: Bool, specifiedView: UIView, superView: UIView?, completed: ((_ isFullScreen: Bool)->())?) {
        // 开启/关闭屏幕旋转
        UIApplication.shared.allowRotation = isEnter
        
        UIView.animate(withDuration: animateDuration, animations: {
            // 强制横竖屏
            let orientation = isEnter ? UIInterfaceOrientation.landscapeRight : UIInterfaceOrientation.portrait
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        })
        
        if isEnter { // 进入全屏
            if isFullScreen { return }
            base.setAssociatedObject(superView, forKey: &lxf_superViewKey)
            base.setAssociatedObject(specifiedView.frame, forKey: &lxf_selfFrameKey)
            specifiedView.removeFromSuperview()
            UIApplication.shared.keyWindow?.addSubview(specifiedView)
            superView?.layoutIfNeeded()
            
            UIView.animate(withDuration: animateDuration, animations: {
                specifiedView.frame = UIScreen.main.bounds
            }) { _ in
                guard let completed = completed else{ return }
                completed(isEnter)
            }
        } else { // 退出全屏
            if !isFullScreen { return }
            UIView.animate(withDuration: animateDuration, animations: {
            }, completion: { _ in
                specifiedView.removeFromSuperview()
                specifiedView.frame = self.lxf_selfFrame ?? CGRect.zero
                self.lxf_superView?.addSubview(specifiedView)
                
                guard let completed = completed else{ return }
                completed(isEnter)
            })
        }
        base.setAssociatedObject(isEnter, forKey: &lxf_isFullKey)
    }
    
    func switchFullScreen(isEnter: Bool, specifiedView: UIView, superView: UIView, completed: ((_ isFullScreen: Bool)->())? = nil) {
        
        lxf_switchFullScreen(
            isEnter: isEnter,
            specifiedView: specifiedView,
            superView: superView,
            completed: completed
        )
    }
}

public extension LXFNameSpace where Base : UIView, Base : FullScreenable {
    func switchFullScreen(isEnter: Bool, specifiedView: UIView? = nil, superView: UIView? = nil, completed: ((_ isFullScreen: Bool)->())? = nil) {
        
        let contentView = specifiedView == nil ? base.self : specifiedView!
        let superView = superView == nil ? contentView.superview : superView!
        
        lxf_switchFullScreen(
            isEnter: isEnter,
            specifiedView: contentView,
            superView: superView,
            completed: completed
        )
    }
}

extension UIApplication: AssociatedObjectStore {
    /// 控制屏幕旋转
    public var allowRotation: Bool {
        get {
            return UIApplication.shared.associatedObject(forKey: &lxf_allowRotationKey, default: false)
        } set {
            UIApplication.shared.setAssociatedObject(newValue, forKey: &lxf_allowRotationKey)
        }
    }
}
