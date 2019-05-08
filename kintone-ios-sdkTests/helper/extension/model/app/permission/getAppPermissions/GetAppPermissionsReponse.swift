//
//  GetAppPermissionsReponse.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/3/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class GetAppPermissionsResponse: NSObject, Codable {
    private var rights: [Right]
    
    public func getRights() -> [Right] {
        return self.rights
    }
    
    public func setRights(_ rights: [Right]) {
        self.rights = rights
    }
    
    public init(_ rights: [Right]) {
        self.rights = rights
    }
}
