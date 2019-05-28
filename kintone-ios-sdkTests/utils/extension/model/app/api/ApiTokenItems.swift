//
//  ItemsAPI.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/2/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class ApiTokenItems: NSObject, Codable {
    private var items: [ApiToken]!
    
    public func getItems() -> [ApiToken] {
        return self.items
    }
    
    public func setItems(_ items: [ApiToken]) {
        self.items = items
    }
    
    public init(_ items: [ApiToken]) {
        self.items = items
    }
}
