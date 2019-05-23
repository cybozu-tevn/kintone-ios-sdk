//
//  Entity.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/3/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation
import kintone_ios_sdk

open class Entity: NSObject, Codable {
    private var type: DevMemberSelectEntityType!
    private var code: String!
    
    public func getType() -> DevMemberSelectEntityType {
        return self.type
    }
    
    public func setType(_ type: DevMemberSelectEntityType) {
        self.type = type
    }
    
    public func getCode() -> String {
        return self.code
    }
    
    public func setCode(_ code: String) {
        self.code = code
    }
    
    public init(_ type: DevMemberSelectEntityType, _ code: String) {
        self.type = type
        self.code = code
    }
}
