//
//  UpdateAppPermissionsRequest.swift
//  kintone-ios-sdkTests
//

import Foundation

class UpdateAppPermissionsRequest: NSObject, Codable {
    private var app: Int!
    private var userRights: [AccessRightEntity]
    
    public func getApp() -> Int {
        return self.app
    }
    
    public func setApp(_ app: Int) {
        self.app = app
    }
    
    public func getRights() -> [AccessRightEntity] {
        return self.userRights
    }
    
    public func setRights(_ userRights: [AccessRightEntity]) {
        self.userRights = userRights
    }
    
    public init(_ app: Int, _ userRights: [AccessRightEntity]) {
        self.app = app
        self.userRights = userRights
    }
}
