//
//  LXFEquatable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2021/9/3.
//  Copyright © 2021年 CocoaPods. All rights reserved.
//

import UIKit

public protocol LXFEquatable: Equatable, AssociatedObjectStore, LXFCompatible {
    var lxf_randomId: String { get set }
}

public extension LXFEquatable {
    /// 获取随机ID
    static func generateRandomId() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<20).map{ _ in letters.randomElement()! })
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.lxf_randomId == rhs.lxf_randomId
    }
}

public extension LXFNameSpace where Base: LXFEquatable {
    /// 随机ID
    var randomId: String {
        get {
            self.base.lxf_randomId
        }
    }
    
    /// 更新随机ID
    func updateRandomId() {
        self.base.lxf_randomId = Base.generateRandomId()
    }
}

public extension LXFEquatable where Self: AnyObject  {
    /// 随机ID
    var lxf_randomId: String {
        get {
            return associatedObject(forKey: &lxf_equatableRandomIdKey, default: Self.generateRandomId())
        }
        set {
            setAssociatedObject(newValue, forKey: &lxf_equatableRandomIdKey)
        }
    }
}

fileprivate var lxf_equatableRandomIdKey = "lxf_equatableRandomIdKey"
