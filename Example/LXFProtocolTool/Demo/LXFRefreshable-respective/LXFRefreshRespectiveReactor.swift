//
//  LXFRefreshRespectiveReactor.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/11/6.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift
import LXFProtocolTool
import MoyaMapper

final class LXFRefreshRespectiveReactor: Reactor, RefreshControllable {
    enum ListIndex: Int {
        case first = 1
        case second
    }
    
    enum Action {
        case fetchList(isReload: Bool, listIndex: ListIndex)
        case beginRefresh(ListIndex)
    }
    
    enum Mutation {
        case setSections([LXFRefreshableSection], listIndex: ListIndex)
        case setRefreshStatus(status: RefreshStatus, listIndex: ListIndex)
    }
    
    struct State {
        var sections1 : [LXFRefreshableSection] = []
        var sections2 : [LXFRefreshableSection] = []
    }
    
    fileprivate var pageIndex1 = 1
    fileprivate var pageSize1 = 10
    fileprivate var pageIndex2 = 1
    fileprivate var pageSize2 = 10
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchList(isReload, listIndex):
            return fetchList(isReload, listIndex)
        case let .beginRefresh(listIndex):
            return Observable.just(.setRefreshStatus(
                status: .beginHeaderRefresh,
                listIndex: listIndex
            ))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSections(sections, listIndex):
            switch listIndex {
            case .first: newState.sections1 = sections
            case .second: newState.sections2 = sections
            }
        case let .setRefreshStatus(status, listIndex):
            switch listIndex {
            case .first: lxf.refreshStatusRespective.value = (status, ListIndex.first.rawValue)
            case .second: lxf.refreshStatusRespective.value = (status, ListIndex.second.rawValue)
            }
        }
        return newState
    }
}

extension LXFRefreshRespectiveReactor {
    fileprivate func fetchList(_ reload: Bool, _ listIndex: ListIndex) -> Observable<Mutation> {
        var pageIndex = 0
        var pageSize = 0
        var sections: [LXFRefreshableSection] = []
        
        switch listIndex {
        case .first:
            pageIndex1 = reload ? 1 : pageIndex1 + 1
            pageIndex = pageIndex1
            pageSize = pageSize1
            sections = currentState.sections1
        case .second:
            pageIndex2 = reload ? 1 : pageIndex2 + 1
            pageIndex = pageIndex2
            pageSize = pageSize2
            sections = currentState.sections2
        }
        
        let endHeaderRefresh = Observable.just(Mutation.setRefreshStatus(status: .endHeaderRefresh, listIndex: listIndex))
        
        let fetchList = lxfNetTool.rx.request(.data(type: .welfare, size: pageSize, index: pageIndex))
            .do(onSuccess: { resp in
                print("json -- \(resp.fetchJSONString())")
            })
            .mapArray(LXFRefreshableModel.self)
            .asObservable()
            .do(onNext: { [weak self] models in
                guard let `self` = self else { return }
                if models.count < pageSize {
                    self.lxf.refreshStatus.value = .noMoreData
                } else {
                    self.lxf.refreshStatus.value = .resetNoMoreData
                }
            })
            .flatMap { models -> Observable<Mutation> in
                var items = models.map {
                    LXFRefreshableSectionItem.item(LXFRefreshableCellReactor(model: $0))
                }
                
                if !reload {
                    items = (sections.first?.items ?? []) + items
                }
                
                let sections = [LXFRefreshableSection.list(items)]
                return Observable.just(.setSections(sections, listIndex: listIndex))
        }
        
        return Observable.concat([fetchList, endHeaderRefresh])
    }
}
