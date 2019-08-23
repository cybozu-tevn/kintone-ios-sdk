//
//  UpdateAppPermissionsRequest.swift
//  kintone-ios-sdkTests
//

import Foundation

class UpdateAppPermissionsRequest: NSObject, Codable {
    private var app: Int!
    private var rights: [AccessRightEntity]
    
    public func getApp() -> Int {
        return self.app
    }
    
    public func setApp(_ app: Int) {
        self.app = app
    }
    
    public func getRights() -> [AccessRightEntity] {
        return self.rights
    }
    
    public func setRights(_ rights: [AccessRightEntity]) {
        self.rights = rights
    }
    
    public init(_ app: Int, _ rights: [AccessRightEntity]) {
        self.app = app
        self.rights = rights
    }
}
