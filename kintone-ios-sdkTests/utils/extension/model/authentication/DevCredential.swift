//
//  Credential.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/25/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation
open class DevCredential: NSObject {
    
    private var username: String
    private var password: String
    
    init(_ username: String, _ password: String) {
        self.username = username
        self.password = password
    }
    
    /// get the login name
    ///
    /// - Returns: the login name
    open func getUsername() -> String {
        return self.username
    }
    
    /// get the login password
    ///
    /// - Returns: the login password
    open func getPassword() -> String {
        return self.password
    }
    
}
