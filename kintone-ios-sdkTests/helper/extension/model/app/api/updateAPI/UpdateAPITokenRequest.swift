//
//  UpdateAPITokenRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/2/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class UpdateAPITokenRequest: NSObject, Codable {
    private var appId: Int
    private var tokens: [Token]
    
    public func getAppId() -> Int {
        return self.appId
    }
    
    public func setAppId(_ appId: Int) {
        self.appId = appId
    }
    
    public func setTokens(_ tokens: [Token]) {
        self.tokens = tokens
    }
    
    public init(_ appId: Int, _ tokens: [Token]) {
        self.appId = appId
        self.tokens = tokens
    }
}
