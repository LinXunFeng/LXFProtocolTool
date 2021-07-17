//
//  LXFRefreshableCellReactor.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/8/1.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift

final class LXFRefreshableCellReactor: Reactor {
    typealias Action = NoAction
    
    struct State {
        var model : LXFRefreshableModel
        
        init(model: LXFRefreshableModel) {
            self.model = model
        }
    }
    
    var initialState: State
    
    init(model: LXFRefreshableModel) {
        initialState = State(model: model)
    }
}
