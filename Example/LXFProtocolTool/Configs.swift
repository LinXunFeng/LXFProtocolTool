//
//  Configs.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/11/21.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

struct Configs {
    struct Screen {
        static let width: CGFloat = UIScreen.main.bounds.width
        static let height: CGFloat = UIScreen.main.bounds.height
        /// 是否iPhoneX,iPhoneXS,iPhoneXS Max,是否iPhoneXR
        static let is_iphoneXSeries =
            (Screen.width == 375.0 && Screen.height == 812.0)
                ||
                (Screen.width == 414.0 && Screen.height == 896.0)
                ? true : false
        static let iPhoneXSeriesBottomH: CGFloat = 34
        static let tabBarH: CGFloat = Screen.is_iphoneXSeries ? 49.0 + Screen.iPhoneXSeriesBottomH : 49.0
        static let navibarH: CGFloat = Screen.is_iphoneXSeries ? 88.0 : 64.0
        static let statusbarH: CGFloat = topH + 20.0
        static let topH: CGFloat = Screen.is_iphoneXSeries ? 24 : 0
        static let bottomH: CGFloat = Screen.is_iphoneXSeries ? Screen.iPhoneXSeriesBottomH : 0
    }
}
