//
//  Entity.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/3/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation
import kintone_ios_sdk

open class DevMemberEntity: NSObject, Codable {
    private var type: DevMemberType!
    private var code: String!
    
    public func getType() -> DevMemberType {
        return self.type
    }
    
    public func setType(_ type: DevMemberType) {
        self.type = type
    }
    
    public func getCode() -> String {
        return self.code
    }
    
    public func setCode(_ code: String) {
        self.code = code
    }
    
    public init(_ type: DevMemberType, _ code: String) {
        self.type = type
        self.code = code
    }
}
