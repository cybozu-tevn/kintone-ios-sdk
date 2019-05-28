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
    private var userRights: [UserRightEntity]
    
    public func getApp() -> Int {
        return self.app
    }
    
    public func setApp(_ app: Int) {
        self.app = app
    }
    
    public func getRights() -> [UserRightEntity] {
        return self.userRights
    }
    
    public func setRights(_ userRights: [UserRightEntity]) {
        self.userRights = userRights
    }
    
    public init(_ app: Int, _ userRights: [UserRightEntity]) {
        self.app = app
        self.userRights = userRights
    }
}
