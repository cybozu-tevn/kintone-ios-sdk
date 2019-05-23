//
//  GetAppPermissionsRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/3/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

class GetAppPermissionsRequest: NSObject, Codable {
    private var app: Int!
    
    public func getApp() -> Int {
        return self.app
    }
    
    public func setApp(_ app: Int) {
        self.app = app
    }
    
    public init(_ app: Int) {
        self.app = app
    }
}
