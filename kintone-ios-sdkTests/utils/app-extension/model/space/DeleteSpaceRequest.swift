//
//  DeleteSpaceRequest.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/7/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

class DeleteSpaceRequest: NSObject, Codable {
    private var id: Int!
    
    public func getId() -> Int {
        return self.id
    }
    
    public func setId(_ id: Int) {
        self.id = id
    }
    
    public init(_ id: Int) {
        self.id = id
    }
}
