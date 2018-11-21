//
//  RxEmptyDataSetable.swift
//  LXFProtocolTool
//
//  Created by 林洵锋 on 2018/10/22.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa

// MARK:- Rx
// MARK: UIScrollView
extension Reactive where Base: UIScrollView {
    public var emptyConfig: Binder<EmptyDataSetConfigure?> {
        return Binder(self.base) { (scrollView, config) in
            scrollView.updateEmptyDataSet(config)
        }
    }
}

// MARK: NSObject
public extension Reactive where Base: NSObject, Base: EmptyDataSetable {
    public enum TapType {
        case emptyView(_ view: UIView)
        case emptyButton(_ button: UIButton)
    }
    
    public func tapEmptyView(_ scrollView: UIScrollView) -> Observable<UIView> {
        return Observable<UIView>.create { observer -> Disposable in
            self.base.lxf.tapEmptyView(scrollView) { observer.onNext($0) }
            return Disposables.create { }
        }
    }
    
    public func tapEmptyButton(_ scrollView: UIScrollView) -> Observable<UIButton> {
        return Observable<UIButton>.create { observer -> Disposable in
            self.base.lxf.tapEmptyButton(scrollView) { observer.onNext($0) }
            return Disposables.create { }
        }
    }
    
    public func tap(_ scrollView: UIScrollView) -> Observable<TapType> {
        return Observable<TapType>.create { observer -> Disposable in
            self.base.lxf.tapEmptyView(scrollView) { observer.onNext(.emptyView($0)) }
            self.base.lxf.tapEmptyButton(scrollView) { observer.onNext(.emptyButton($0)) }
            return Disposables.create { }
        }
    }
    
    public func emptyViewWillAppear(_ scrollView: UIScrollView) -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            self.base.lxf.emptyViewWillAppear(scrollView) { observer.onNext(()) }
            return Disposables.create { }
        }
    }
    
    public func emptyViewDidAppear(_ scrollView: UIScrollView) -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            self.base.lxf.emptyViewDidAppear(scrollView) { observer.onNext(()) }
            return Disposables.create { }
        }
    }
    
    public func emptyViewWillDisappear(_ scrollView: UIScrollView) -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            self.base.lxf.emptyViewWillDisappear(scrollView) { observer.onNext(()) }
            return Disposables.create { }
        }
    }
    
    public func emptyViewDidDisappear(_ scrollView: UIScrollView) -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            self.base.lxf.emptyViewDidDisappear(scrollView) { observer.onNext(()) }
            return Disposables.create { }
        }
    }
}
