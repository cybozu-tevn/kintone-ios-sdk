//
//  ItemModel.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/28/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation

open class APIItem: NSObject, Codable {
    private var item: String!
    
    public func getItem() -> String {
        return item
    }
    
    public func setItem(_ item: String) {
        self.item = item
    }
    
    public init(_ item: String) {
        self.item = item
    }
}
