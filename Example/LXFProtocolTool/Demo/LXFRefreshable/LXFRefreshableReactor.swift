//
//  LXFRefreshableReactor.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/8/1.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift
import LXFProtocolTool
import MoyaMapper

final class LXFRefreshableReactor: Reactor, RefreshControllable {
    
    enum Action {
        case fetchList(Bool)
        case beginRefresh
    }
    
    enum Mutation {
        case setSections([LXFRefreshableSection])
        case setRefreshStatus(RefreshStatus)
    }
    
    struct State {
        var sections : [LXFRefreshableSection] = []
    }
    
    fileprivate var pageIndex = 1
    fileprivate var pageSize = 10
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchList(reload):
            return fetchList(reload)
        case .beginRefresh:
            return Observable.just(.setRefreshStatus(.beginHeaderRefresh))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSections(sections):
            newState.sections = sections
        case let .setRefreshStatus(status):
            lxf.refreshStatus.value = status
        }
        return newState
    }
}

extension LXFRefreshableReactor {
    fileprivate func fetchList(_ reload: Bool) -> Observable<Mutation> {
        pageIndex = reload ? 1 : pageIndex+1
        
        let endHeaderRefresh = Observable.just(Mutation.setRefreshStatus(.endHeaderRefresh))
        
        let fetchList = lxfNetTool.rx.request(.data(type: .welfare, size: pageSize, index: pageIndex))
            .do(onSuccess: { resp in
                print("json -- \(resp.fetchJSONString())")
            })
            .mapArray(LXFRefreshableModel.self)
            .asObservable()
            .do(onNext: { [weak self] models in
                guard let `self` = self else { return }
                if models.count < self.pageSize {
                    self.lxf.refreshStatus.value = .noMoreData
                } else {
                    self.lxf.refreshStatus.value = .resetNoMoreData
                }
            })
            .flatMap { [weak self] models -> Observable<Mutation> in
                var items = models.map {
                    LXFRefreshableSectionItem.item(LXFRefreshableCellReactor(model: $0))
                }
                
                if !reload {
                    items = (self?.currentState.sections.first?.items ?? []) + items
                }
                
                let sections = [LXFRefreshableSection.list(items)]
                return Observable.just(.setSections(sections))
            }
        
        return Observable.concat([fetchList, endHeaderRefresh])
    }
}
