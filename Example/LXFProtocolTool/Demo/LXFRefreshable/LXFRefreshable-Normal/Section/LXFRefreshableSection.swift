//
//  LXFRefreshableSection.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/8/1.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import RxDataSources

enum LXFRefreshableSection {
    case list([LXFRefreshableSectionItem])
}

extension LXFRefreshableSection: SectionModelType {
    init(original: LXFRefreshableSection, items: [LXFRefreshableSectionItem]) {
        switch original {
        case .list: self = .list(items)
        }
    }
    
    var items: [LXFRefreshableSectionItem] {
        switch self {
        case .list(let items): return items
        }
    }
}

enum LXFRefreshableSectionItem {
    case item(LXFRefreshableCellReactor)
}
