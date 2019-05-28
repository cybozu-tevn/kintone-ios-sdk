//
//  GetListAPIsRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/2/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

class GetApiTokenListRequest: NSObject, Codable {
    private var appId: Int
    
    public func getAppId() -> Int {
        return self.appId
    }
    
    public func setAppId(_ appId: Int) {
        self.appId = appId
    }
    
    public init(_ appId: Int) {
        self.appId = appId
    }
}
