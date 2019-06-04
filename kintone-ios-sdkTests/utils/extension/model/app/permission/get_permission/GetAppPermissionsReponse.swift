//
//  GetAppPermissionsReponse.swift
//  kintone-ios-sdkTests
//

import Foundation

open class GetAppPermissionsResponse: NSObject, Codable {
    private var userRights: [AccessRightEntity]
    
    public func getRights() -> [AccessRightEntity] {
        return self.userRights
    }
    
    public func setRights(_ userRights: [AccessRightEntity]) {
        self.userRights = userRights
    }
    
    public init(_ userRights: [AccessRightEntity]) {
        self.userRights = userRights
    }
}
