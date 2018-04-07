//
//  LXFEmptyDataSetable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2018/4/6.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

public enum LXFEmptyDataSetAttributeKeyType {
    /// 纵向偏移(-50)  CGFloat
    case verticalOffset
    /// 提示语(暂无数据)  String
    case tipStr
    /// 提示语的font(system15)  UIFont
    case tipFont
    /// 提示语颜色(D2D2D2)  UIColor
    case tipColor
    /// 提示图(LXFEmptyDataPic) UIImage
    case tipImage
    /// 允许滚动(true) Bool
    case allowScroll
}

extension UIScrollView {
    private struct AssociatedKeys {
        static var lxf_emptyAttributeDict:[LXFEmptyDataSetAttributeKeyType : Any]?
    }
    /// 属性字典
    var lxf_emptyAttributeDict: [LXFEmptyDataSetAttributeKeyType : Any]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.lxf_emptyAttributeDict) as? [LXFEmptyDataSetAttributeKeyType : Any]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lxf_emptyAttributeDict, newValue as [LXFEmptyDataSetAttributeKeyType : Any]?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

// MARK:- 空视图占位协议
public protocol LXFEmptyDataSetable {
    
}

// MARK:- UIViewController - 空视图占位协议
public extension LXFEmptyDataSetable where Self : UIViewController {
    func lxf_EmptyDataSet(_ scrollView: UIScrollView, attributeBlock: (()->([LXFEmptyDataSetAttributeKeyType : Any]))? = nil) {
        scrollView.lxf_emptyAttributeDict = attributeBlock != nil ? attributeBlock!() : nil
        scrollView.emptyDataSetDelegate = self
        scrollView.emptyDataSetSource = self
    }
}

// MARK:- UIView - 空视图占位协议
public extension LXFEmptyDataSetable where Self : UIView {
    func lxf_EmptyDataSet(_ scrollView: UIScrollView, attributeBlock: (()->([LXFEmptyDataSetAttributeKeyType : Any]))? = nil) {
        scrollView.lxf_emptyAttributeDict = attributeBlock != nil ? attributeBlock!() : nil
        scrollView.emptyDataSetDelegate = self
        scrollView.emptyDataSetSource = self
    }
}

extension NSObject : DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        
        guard let tipImg = scrollView.lxf_emptyAttributeDict?[.tipImage] as? UIImage else {
            return UIImage(named: "LXFEmptyDataPic")
        }
        return tipImg
    }
    
    public func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let defaultColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1.0) // 0xD2D2D2
        
        let tipText = (scrollView.lxf_emptyAttributeDict?[.tipStr] as? String) ?? "暂无数据"
        let tipFont = (scrollView.lxf_emptyAttributeDict?[.tipFont] as? UIFont) ?? UIFont.systemFont(ofSize: 15)
        let tipColor = (scrollView.lxf_emptyAttributeDict?[.tipColor] as? UIColor) ?? defaultColor
        
        let attrStr = NSAttributedString(string: tipText, attributes: [
            NSAttributedStringKey.font:tipFont,
            NSAttributedStringKey.foregroundColor:tipColor
            ])
        return attrStr
    }
    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        
        guard let offset = scrollView.lxf_emptyAttributeDict?[.verticalOffset] as? NSNumber else {
            return -50
        }
        return CGFloat(truncating: offset)
    }
    public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return (scrollView.lxf_emptyAttributeDict?[.allowScroll] as? Bool) ?? true
    }
}
