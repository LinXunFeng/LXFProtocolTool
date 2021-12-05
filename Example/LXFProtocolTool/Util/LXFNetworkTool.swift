//
//  LXFNetworkTool.swift
//  RxSwiftDemo
//
//  Created by 林洵锋 on 2017/9/7.
//  Copyright © 2017年 LXF. All rights reserved.
//

import Foundation
import Moya
import MoyaMapper
import Alamofire

enum LXFNetworkTool {
    
    enum LXFNetworkCategory: String {
        /// 游戏壁纸
        case game = "5"
        /// 美女模特
        case model = "6"
        /// 动漫卡通
        case cartoon = "26"
        /// 风景大片
        case scenery = "9"
        /// 萌宠动物
        case pet = "14"
    }
    case data(type: LXFNetworkCategory, size:Int, index:Int)
}

extension LXFNetworkTool: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    /// The target's base `URL`.
    var baseURL: URL {
        return URL(string: "http://wallpaper.apc.360.cn/")!
    }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String {
        return "index.php"
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method {
        return .get
    }
    
    /// The parameters to be encoded in the request.
    var parameters: [String: Any]? {
        return nil
    }
    
    /// The method used for parameter encoding.
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// Provides stub data for use in testing.
    var sampleData: Data {
        return "LinXunFeng".data(using: .utf8)!
    }
    
    /// The type of HTTP task to be performed.
    var task: Task {
        switch self {
        case .data(let type, let size, let index):
            return .requestParameters(
                parameters: [
                    "c": "WallPaperAndroid",
                    "a": "getAppsByCategory",
                    "cid": "\(type.rawValue)",
                    "start": "\(index)",
                    "count": "\(size)"
                ],
                encoding: URLEncoding.default
            )
        }
    }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool {
        return false
    }
}

struct NetParameter : ModelableParameterType {
    // 可以任意指定位置的值，如： "error>used"
    var successValue = "false"
    var statusCodeKey = "error"
    var tipStrKey = "errMsg"
    var modelKey = "results"
}

let lxfNetTool = MoyaProvider<LXFNetworkTool>(plugins: [MoyaMapperPlugin(NetParameter())])



// MARK:- 自定义网络结果参数
struct CustomNetParameter: ModelableParameterType {
    var successValue = "000"
    var statusCodeKey = "retCode"
    var tipStrKey = "retMsg"
    var modelKey = "retBody"
}
