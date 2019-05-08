//
//  UpdateAppPermissionsResponse.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/3/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class UpdateAppPermissionsResponse: NSObject, Codable {
    private var revision: String!
    
    public func getRevision() -> String {
        return self.revision
    }
    
    public func setRevision(_ revision: String) {
        self.revision = revision
    }
    
    public init(_ revision: String) {
        self.revision = revision
    }
}
