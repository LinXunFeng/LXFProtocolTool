//
//  LXFNibloadable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2018/4/6.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public protocol LXFNibloadable {
    static var lxf_nibIdentifier: String { get }
}

extension LXFNibloadable {
    static var lxf_nib: UINib {
        return UINib(nibName: lxf_nibIdentifier, bundle: nil)
    }
}

extension LXFNibloadable where Self: UIView {
    public static func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        guard let view = UINib(nibName: lxf_nibIdentifier, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Couldn't find nib file for \(String(describing: Self.self))")
        }
        return view
        // return Bundle(for: Self.self).loadNibNamed("\(self)", owner: nil, options: nil)?.first as! Self
    }
}

extension LXFNibloadable where Self: UIViewController {
    public static func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        return Self(nibName: lxf_nibIdentifier, bundle: bundle)
    }
}

extension LXFNibloadable where Self: UITableView {
    public static func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        guard let tableView = UINib(nibName: lxf_nibIdentifier, bundle: bundle).instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Couldn't find nib file for \(String(describing: Self.self))")
        }
        return tableView
    }
}

extension LXFNibloadable where Self: UITableViewController {
    public static func loadFromNib(_ bundle: Bundle? = nil) -> Self {
        return Self(nibName: lxf_nibIdentifier, bundle: bundle)
    }
}


// MARK:- 相应的类遵守协议
extension UIView: LXFNibloadable {
    public static var lxf_nibIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController: LXFNibloadable {
    public static var lxf_nibIdentifier: String {
        return String(describing: self)
    }
}


// MARK:- 复用相关 TableView && UICollectionView
// MARK: TableView
extension UITableView {
    public func registerCell<T: UITableViewCell>(_ type: T.Type) {
        // T.lxf_nib == type.lxf_nib
        register(T.lxf_nib, forCellReuseIdentifier: String(describing: T.self))
    }
    
    public func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type) {
        register(type.lxf_nib, forCellReuseIdentifier: String(describing: T.self))
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: T.self)) as? T else {
            fatalError("Couldn't find nib file for \(String(describing: T.self))")
        }
        return cell
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Couldn't find nib file for \(String(describing: T.self))")
        }
        return cell
    }
    
    public func dequeueResuableHeaderFooterView<T: UITableViewHeaderFooterView>(type: T.Type) -> T {
        guard let headerFooterView = self.dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T
            else { fatalError("Couldn't find nib file for \(String(describing: T.self))") }
        return headerFooterView
    }
}


// MARK: UICollectionView
extension UICollectionView {
    public func registerCell<T: UICollectionViewCell>(type: T.Type) {
        register(T.lxf_nib, forCellWithReuseIdentifier: String(describing: T.self))
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell>(type: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Couldn't find nib file for \(String(describing: T.self))")
        }
        return cell
    }
    
}
