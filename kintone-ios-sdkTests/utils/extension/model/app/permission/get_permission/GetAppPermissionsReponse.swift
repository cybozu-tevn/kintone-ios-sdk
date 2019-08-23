//
//  GetAppPermissionsReponse.swift
//  kintone-ios-sdkTests
//

import Foundation

open class GetAppPermissionsResponse: NSObject, Codable {
    private var rights: [AccessRightEntity]
    
    public func getRights() -> [AccessRightEntity] {
        return self.rights
    }
    
    public func setRights(_ userRights: [AccessRightEntity]) {
        self.rights = userRights
    }
    
    public init(_ userRights: [AccessRightEntity]) {
        self.rights = userRights
    }
}
