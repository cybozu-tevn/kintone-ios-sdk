//
//  ItemsAPI.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 1/2/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Foundation

open class ItemsAPI: NSObject, Codable {
    private var items: [ItemAPI]!
    
    public func getItems() -> [ItemAPI] {
        return self.items
    }
    
    public func setItems(_ items: [ItemAPI]) {
        self.items = items
    }
    
    public init(_ items: [ItemAPI]) {
        self.items = items
    }
}
