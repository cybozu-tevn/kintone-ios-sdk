//
//  UpdateAPITokenRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/2/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class UpdateApiTokenRequest: NSObject, Codable {
    private var appId: Int
    private var tokens: [TokenEntity]
    
    public func getAppId() -> Int {
        return self.appId
    }
    
    public func setAppId(_ appId: Int) {
        self.appId = appId
    }
    
    public func setTokens(_ tokens: [TokenEntity]) {
        self.tokens = tokens
    }
    
    public init(_ appId: Int, _ tokens: [TokenEntity]) {
        self.appId = appId
        self.tokens = tokens
    }
}
