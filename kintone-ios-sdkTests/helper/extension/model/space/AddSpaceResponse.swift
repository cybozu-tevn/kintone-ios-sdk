//
//  AddSpaceResponse.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/4/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class AddSpaceResponse: NSObject, Codable {
    private var id: String!
    
    public func getId() -> Int {
        return Int(self.id)!
    }
    
    public func setId(_ id: String) {
        self.id = id
    }
    
    public init(_ id: String) {
        self.id = id
    }
}
