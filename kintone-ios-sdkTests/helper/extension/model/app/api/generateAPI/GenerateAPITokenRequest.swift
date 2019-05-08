//
//  GenerateTokenRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/28/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation

class GenerateAPITokenRequest: NSObject, Codable {
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
