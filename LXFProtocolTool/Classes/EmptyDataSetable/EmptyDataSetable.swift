//
//  EmptyDataSetable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2018/4/6.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

public typealias EmptyViewTapBlock = ((UIView)->())
public typealias EmptyButtonTapBlock = ((UIButton)->())
public typealias EmptyNormalBlock = (()->Void)
fileprivate let defaultEmptyConfig = EmptyDataSetableConfigure.shared.emptyDataSetConfigure

public struct EmptyDataSetConfigure {
    /// 纵向偏移(0)  CGFloat
    public var verticalOffset : CGFloat
    /// 提示语(暂无数据)  String
    public var tipStr : String
    /// 提示语的font(system15)  UIFont
    public var tipFont : UIFont
    /// 提示语颜色  UIColor
    public var tipColor : UIColor
    /// 提示图 UIImage
    public var tipImage : UIImage?
    /// 允许滚动(true) Bool
    public var allowScroll : Bool
    /// 各元素之间的间距(11)
    public var spaceHeight : CGFloat
    /// 按钮标题
    public var buttonTitle : NSAttributedString
    /// 按钮图片
    public var buttonImageBlock : ((UIControl.State) -> UIImage?)?
    /// 按钮背景图片
    public var buttonBackgroundImageBlock : ((UIControl.State)-> UIImage?)?
    /// image动画
    public var imageAnimation : CAAnimation?
    /// imageTintColor
    public var imageTintColor : UIColor?
    /// customView
    public var customEmptyView : UIView?
    /// shouldFade(true)
    public var shouldFade : Bool
    /// shouldBeForcedToDisplay(false)
    public var shouldBeForcedToDisplay : Bool
    /// shouldDisplay(true)
    public var shouldDisplay : Bool
    /// shouldAllowTouch(true)
    public var shouldAllowTouch : Bool
    /// shouldAnimateImageView(false)
    public var shouldAnimateImageView : Bool
    
    public init(
        verticalOffset: CGFloat = 0,
        tipStr: String = "",
        tipFont: UIFont = .systemFont(ofSize: 15),
        tipColor: UIColor = .lightGray,
        tipImage: UIImage? = nil,
        allowScroll: Bool = true,
        spaceHeight: CGFloat = 11,
        buttonTitle : NSAttributedString = NSAttributedString(),
        buttonImageBlock : ((UIControl.State)-> UIImage?)? = nil,
        buttonBackgroundImageBlock : ((UIControl.State)-> UIImage?)? = nil,
        imageAnimation : CAAnimation? = nil, imageTintColor : UIColor? = nil,
        customEmptyView : UIView? = nil,
        shouldFade : Bool = true,
        shouldBeForcedToDisplay : Bool = false,
        shouldDisplay: Bool = true,
        shouldAllowTouch: Bool = true,
        shouldAnimateImageView : Bool = false
    ) {
        self.verticalOffset = verticalOffset
        self.tipStr = tipStr
        self.tipFont = tipFont
        self.tipColor = tipColor
        self.tipImage = tipImage
        self.allowScroll = allowScroll
        self.spaceHeight = spaceHeight
        self.buttonTitle = buttonTitle
        self.buttonImageBlock = buttonImageBlock
        self.buttonBackgroundImageBlock = buttonBackgroundImageBlock
        self.imageAnimation = imageAnimation
        self.imageTintColor = imageTintColor
        self.customEmptyView = customEmptyView
        self.shouldFade = shouldFade
        self.shouldBeForcedToDisplay = shouldBeForcedToDisplay
        self.shouldDisplay = shouldDisplay
        self.shouldAllowTouch = shouldAllowTouch
        self.shouldAnimateImageView = shouldAnimateImageView
    }
}

public class EmptyDataSetableConfigure: NSObject {
    static let shared = EmptyDataSetableConfigure()
    private override init() {
        emptyDataSetConfigure = EmptyDataSetConfigure()
        super.init()
    }
    
    var emptyDataSetConfigure: EmptyDataSetConfigure
    
    public static func setDefaultEmptyDataSetConfigure(_ configure: EmptyDataSetConfigure) {
        EmptyDataSetableConfigure.shared.emptyDataSetConfigure = configure
    }
}

extension UIScrollView: AssociatedObjectStore {
    /// 属性字典
    var emptyDataSetConfig: EmptyDataSetConfigure? {
        get { return associatedObject(forKey: &lxf_emptyDataSetConfigureKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_emptyDataSetConfigureKey) }
    }
    var emptyViewTapBlock : EmptyViewTapBlock? {
        get { return associatedObject(forKey: &lxf_emptyViewTapBlockKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_emptyViewTapBlockKey) }
    }
    var emptyButtonTapBlock : EmptyButtonTapBlock? {
        get { return associatedObject(forKey: &lxf_emptyButtonTapBlockKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_emptyButtonTapBlockKey) }
    }
    var emptyDataSetWillAppearBlock : EmptyNormalBlock? {
        get { return associatedObject(forKey: &lxf_emptyDataSetWillAppearKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_emptyDataSetWillAppearKey) }
    }
    var emptyDataSetDidAppearBlock : EmptyNormalBlock? {
        get { return associatedObject(forKey: &lxf_emptyDataSetDidAppearKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_emptyDataSetDidAppearKey) }
    }
    var emptyDataSetWillDisappearBlock : EmptyNormalBlock? {
        get { return associatedObject(forKey: &lxf_emptyDataSetWillDisappearKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_emptyDataSetWillDisappearKey) }
    }
    var emptyDataSetDidDisappearBlock : EmptyNormalBlock? {
        get { return associatedObject(forKey: &lxf_emptyDataSetDidDisappearKey) }
        set { setAssociatedObject(newValue, forKey: &lxf_emptyDataSetDidDisappearKey) }
    }
    
    internal func updateEmptyDataSet(_ config: EmptyDataSetConfigure?, base: NSObject? = nil) {
        self.emptyDataSetConfig = config
        if self.emptyDataSetDelegate == nil {
            self.emptyDataSetDelegate = base ?? self
        }
        if self.emptyDataSetSource == nil {
            self.emptyDataSetSource = base ?? self
        }
        self.reloadEmptyDataSet()
    }
}

// MARK:- 空视图占位协议
public protocol EmptyDataSetable: LXFCompatible { }

public extension LXFNameSpace where Base: NSObject {
    // MARK:- 更新数据
    public func updateEmptyDataSet(
        _ scrollView: UIScrollView,
        config: EmptyDataSetConfigure? = nil
    ) {
        scrollView.updateEmptyDataSet(config, base: base)
    }
    
    // MARK: 点击回调
    public func tapEmptyView(_ scrollView: UIScrollView, block: @escaping EmptyViewTapBlock) {
        scrollView.emptyViewTapBlock = block
    }
    public func tapEmptyButton(_ scrollView: UIScrollView, block: @escaping EmptyButtonTapBlock) {
        scrollView.emptyButtonTapBlock = block
    }
    
    // MARK: 生命周期回调
    public func emptyViewWillAppear(_ scrollView: UIScrollView, block: @escaping EmptyNormalBlock) {
        scrollView.emptyDataSetWillAppearBlock = block
    }
    public func emptyViewDidAppear(_ scrollView: UIScrollView, block: @escaping EmptyNormalBlock) {
        scrollView.emptyDataSetDidAppearBlock = block
    }
    public func emptyViewWillDisappear(_ scrollView: UIScrollView, block: @escaping EmptyNormalBlock) {
        scrollView.emptyDataSetWillDisappearBlock = block
    }
    public func emptyViewDidDisappear(_ scrollView: UIScrollView, block: @escaping EmptyNormalBlock) {
        scrollView.emptyDataSetDidDisappearBlock = block
    }
}

extension NSObject : DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    public func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        guard let tipImage = scrollView.emptyDataSetConfig?.tipImage else {
            return defaultEmptyConfig.tipImage
        }
        return tipImage
    }
    
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let curConfig = scrollView.emptyDataSetConfig
        
        let tipColor = curConfig?.tipColor != nil ? curConfig!.tipColor : defaultEmptyConfig.tipColor
        let tipText = curConfig?.tipStr != nil ? curConfig!.tipStr : defaultEmptyConfig.tipStr
        let tipFont = curConfig?.tipFont != nil ? curConfig!.tipFont : defaultEmptyConfig.tipFont
        
        let attrStr = NSAttributedString(string: tipText, attributes: [
            .font:tipFont,
            .foregroundColor:tipColor
            ])
        return attrStr
    }
    
    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        let curConfig = scrollView.emptyDataSetConfig
        
        let offset = curConfig?.verticalOffset != nil ? curConfig!.verticalOffset : defaultEmptyConfig.verticalOffset
        return offset
    }
    
    public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        let curConfig = scrollView.emptyDataSetConfig
        
        let allowScroll = curConfig?.allowScroll != nil ? curConfig!.allowScroll : defaultEmptyConfig.allowScroll
        return allowScroll
    }
    
    public func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        let curConfig = scrollView.emptyDataSetConfig
        
        let spaceHeight = curConfig?.spaceHeight != nil ? curConfig!.spaceHeight : defaultEmptyConfig.spaceHeight
        return spaceHeight
    }
    
    public func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        let curConfig = scrollView.emptyDataSetConfig
        
        let buttonTitle = curConfig?.buttonTitle != nil ? curConfig!.buttonTitle : defaultEmptyConfig.buttonTitle
        return buttonTitle
    }
    
    public func buttonImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        let curConfig = scrollView.emptyDataSetConfig
        let buttonImageBlock = curConfig?.buttonImageBlock != nil ? curConfig!.buttonImageBlock : defaultEmptyConfig.buttonImageBlock
        if buttonImageBlock == nil {
            return nil
        }
        guard let img = buttonImageBlock!(state) else {
            return nil
        }
        return img
    }
    
    public func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> UIImage? {
        let curConfig = scrollView.emptyDataSetConfig
        let buttonBackgroundImageBlock = curConfig?.buttonBackgroundImageBlock != nil ? curConfig!.buttonBackgroundImageBlock : defaultEmptyConfig.buttonBackgroundImageBlock
        if buttonBackgroundImageBlock == nil {
            return nil
        }
        guard let img = buttonBackgroundImageBlock!(state) else {
            return nil
        }
        return img
    }
    
    public func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        let curConfig = scrollView.emptyDataSetConfig
        let customEmptyView = curConfig?.customEmptyView != nil ? curConfig!.customEmptyView : defaultEmptyConfig.customEmptyView
        if customEmptyView == nil {
            return nil
        }
        return customEmptyView
    }
    
    public func imageTintColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        let curConfig = scrollView.emptyDataSetConfig
        let imageTintColor = curConfig?.imageTintColor != nil ? curConfig!.imageTintColor : defaultEmptyConfig.imageTintColor
        if imageTintColor == nil {
            return nil
        }
        return imageTintColor
    }
    
    public func imageAnimation(forEmptyDataSet scrollView: UIScrollView) -> CAAnimation? {
        let curConfig = scrollView.emptyDataSetConfig
        let imageAnimation = curConfig?.imageAnimation != nil ? curConfig!.imageAnimation : defaultEmptyConfig.imageAnimation
        if imageAnimation == nil {
            return nil
        }
        return imageAnimation
    }
    
    public func emptyDataSet(_ scrollView: UIScrollView, didTap view: UIView) {
        if scrollView.emptyViewTapBlock != nil {
            scrollView.emptyViewTapBlock!(view)
        }
    }
    
    public func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        if scrollView.emptyButtonTapBlock != nil {
            scrollView.emptyButtonTapBlock!(button)
        }
    }
    
    public func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        // 修复 emptyDataSetView 偏移问题(如:与MJRefresh结合使用时y会出现-54)
        guard let view = scrollView.value(forKey: "emptyDataSetView") as? UIView else { return }
        var frame = view.frame
        frame.origin = CGPoint.zero
        view.frame = frame
        if scrollView.emptyDataSetWillAppearBlock != nil {
            scrollView.emptyDataSetWillAppearBlock!()
        }
    }
    
    public func emptyDataSetDidAppear(_ scrollView: UIScrollView!) {
        if scrollView.emptyDataSetDidAppearBlock != nil {
            scrollView.emptyDataSetDidAppearBlock!()
        }
    }
    
    public func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {
        if scrollView.emptyDataSetWillDisappearBlock != nil {
            scrollView.emptyDataSetWillDisappearBlock!()
        }
    }
    
    public func emptyDataSetDidDisappear(_ scrollView: UIScrollView!) {
        if scrollView.emptyDataSetDidDisappearBlock != nil {
            scrollView.emptyDataSetDidDisappearBlock!()
        }
    }
}

fileprivate var lxf_emptyDataSetConfigureKey = "lxf_emptyDataSetConfigureKey"
fileprivate var lxf_emptyViewTapBlockKey = "lxf_emptyViewTapBlockKey"
fileprivate var lxf_emptyButtonTapBlockKey = "lxf_emptyButtonTapBlockKey"
fileprivate var lxf_emptyDataSetWillAppearKey = "lxf_emptyDataSetWillAppearKey"
fileprivate var lxf_emptyDataSetDidAppearKey = "lxf_emptyDataSetDidAppearKey"
fileprivate var lxf_emptyDataSetWillDisappearKey = "lxf_emptyDataSetWillDisappearKey"
fileprivate var lxf_emptyDataSetDidDisappearKey = "lxf_emptyDataSetDidDisappearKey"

