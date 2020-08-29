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
    enum TapType {
        case emptyView(_ view: UIView)
        case emptyButton(_ button: UIButton)
    }
    
    func tapEmptyView(_ scrollView: UIScrollView) -> Observable<UIView> {
        return Observable<UIView>.create { observer -> Disposable in
            self.base.lxf.tapEmptyView(scrollView) { observer.onNext($0) }
            return Disposables.create { }
        }
    }
    
    func tapEmptyButton(_ scrollView: UIScrollView) -> Observable<UIButton> {
        return Observable<UIButton>.create { observer -> Disposable in
            self.base.lxf.tapEmptyButton(scrollView) { observer.onNext($0) }
            return Disposables.create { }
        }
    }
    
    func tap(_ scrollView: UIScrollView) -> Observable<TapType> {
        return Observable<TapType>.create { observer -> Disposable in
            self.base.lxf.tapEmptyView(scrollView) { observer.onNext(.emptyView($0)) }
            self.base.lxf.tapEmptyButton(scrollView) { observer.onNext(.emptyButton($0)) }
            return Disposables.create { }
        }
    }
    
    func emptyViewWillAppear(_ scrollView: UIScrollView) -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            self.base.lxf.emptyViewWillAppear(scrollView) { observer.onNext(()) }
            return Disposables.create { }
        }
    }
    
    func emptyViewDidAppear(_ scrollView: UIScrollView) -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            self.base.lxf.emptyViewDidAppear(scrollView) { observer.onNext(()) }
            return Disposables.create { }
        }
    }
    
    func emptyViewWillDisappear(_ scrollView: UIScrollView) -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            self.base.lxf.emptyViewWillDisappear(scrollView) { observer.onNext(()) }
            return Disposables.create { }
        }
    }
    
    func emptyViewDidDisappear(_ scrollView: UIScrollView) -> Observable<Void> {
        return Observable<Void>.create { observer -> Disposable in
            self.base.lxf.emptyViewDidDisappear(scrollView) { observer.onNext(()) }
            return Disposables.create { }
        }
    }
}
