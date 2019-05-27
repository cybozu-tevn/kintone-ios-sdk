//
//  GetAppPermissionsReponse.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/3/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class GetAppPermissionsResponse: NSObject, Codable {
    private var userRights: [UserRightEntity]
    
    public func getRights() -> [UserRightEntity] {
        return self.userRights
    }
    
    public func setRights(_ userRights: [UserRightEntity]) {
        self.userRights = userRights
    }
    
    public init(_ userRights: [UserRightEntity]) {
        self.userRights = userRights
    }
}
