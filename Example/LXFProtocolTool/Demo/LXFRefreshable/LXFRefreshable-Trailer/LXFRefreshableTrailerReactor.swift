//
//  LXFRefreshableTrailerReactor.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2021/7/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift
import LXFProtocolTool
import MoyaMapper

final class LXFRefreshableTrailerReactor: Reactor, RefreshControllable {
    
    deinit {
        print("deinit -- LXFRefreshableTrailerReactor")
    }
    
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
            return .just(.setRefreshStatus(.beginTrailerRefresh))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSections(sections):
            newState.sections = sections
        case let .setRefreshStatus(status):
            lxf.refreshStatus.accept(status)
        }
        return newState
    }
}

extension LXFRefreshableTrailerReactor {
    fileprivate func fetchList(_ reload: Bool) -> Observable<Mutation> {
        pageIndex = reload ? 1 : pageIndex+1
        
        let endHeaderRefresh = Observable.just(Mutation.setRefreshStatus(.endTrailerRefresh))
        
        let fetchList = lxfNetTool.rx.request(.data(type: .game, size: pageSize, index: pageIndex))
            .do(onSuccess: { resp in
                print("json -- \(resp.fetchJSONString())")
            })
            .flatMap {
                .just($0.mapArray(LXFRefreshableModel.self, modelKey: "data"))
            }
            .asObservable()
            .do(onNext: { [weak self] models in
                guard let `self` = self else { return }
                if models.count < self.pageSize {
                    self.lxf.refreshStatus.accept(.hiddenTrailer)
                } else {
                    self.lxf.refreshStatus.accept(.showTrailer)
                }
            })
            .flatMap { [weak self] models -> Observable<Mutation> in
                // 测试占位图使用
                // let items: [LXFRefreshableSectionItem] = []
                var items = models.map {
                    LXFRefreshableSectionItem.item(LXFRefreshableCellReactor(model: $0))
                }
                if !reload {
                    items = (self?.currentState.sections.first?.items ?? []) + items
                }
                
                let sections = [LXFRefreshableSection.list(items)]
                return .just(Mutation.setSections(sections))
            }
        
        return .concat([fetchList, endHeaderRefresh])
    }
}
