//
//  DevHTTPHeader.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/25/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation
open class DevHTTPHeader: NSObject {
    
    private var key: String?
    private var value: String?
    
    init(_ key: String?, _ value: String?) {
        self.key = key
        self.value = value
    }
    
    /// get key of the authentication
    ///
    /// - Returns: key of the authentication
    open func getKey() -> String? {
        return self.key
    }
    
    /// get value of the authentication
    ///
    /// - Returns: value of the authentication
    open func getValue() -> String? {
        return self.value
    }
}
