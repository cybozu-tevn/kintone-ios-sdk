//
// kintone-ios-sdkTests
// Created on 8/22/19
// 

import Foundation

class UpdateRecordPermissionsRequest: NSObject, Codable {
    private var app: Int!
    private var rights: [RecordRightEntity]
    
    public func getApp() -> Int {
        return self.app
    }
    
    public func setApp(_ app: Int) {
        self.app = app
    }
    
    public func getRights() -> [RecordRightEntity] {
        return self.rights
    }
    
    public func setRights(_ rights: [RecordRightEntity]) {
        self.rights = rights
    }
    
    public init(_ app: Int, _ rights: [RecordRightEntity]) {
        self.app = app
        self.rights = rights
    }
}
