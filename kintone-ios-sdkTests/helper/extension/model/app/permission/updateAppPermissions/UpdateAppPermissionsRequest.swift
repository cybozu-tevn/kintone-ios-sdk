//
//  UpdateAppPermissionsRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/3/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

class UpdateAppPermissionsRequest: NSObject, Codable {
    private var app: Int!
    private var rights: [Right]
    
    public func getApp() -> Int {
        return self.app
    }
    
    public func setApp(_ app: Int) {
        self.app = app
    }
    
    public func getRights() -> [Right] {
        return self.rights
    }
    
    public func setRights(_ rights: [Right]) {
        self.rights = rights
    }
    
    public init(_ app: Int, _ rights: [Right]) {
        self.app = app
        self.rights = rights
    }
}
