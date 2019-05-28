//
//  DevAuth.swift
//  kintone-ios-sdkTests
//
//  Created by Le Dai Vuong on 12/25/18.
//  Copyright © 2018 Cybozu. All rights reserved.
//

import Foundation
import kintone_ios_sdk
open class DevAuth: NSObject {
    
    private var basicAuth: DevCredential?
    private var passwordAuth: DevCredential?
    private var apiToken: String?
    
    /// set basic authentication
    ///
    /// - Parameters:
    ///   - username: Basic login name
    ///   - password: Basic login password
    /// - Returns: basic authentication
    open func setBasicAuth(_ username: String, _ password: String) -> DevAuth {
        self.basicAuth = DevCredential(username, password)
        return self
    }
    
    /// get basic authentication
    ///
    /// - Returns: basic authentication
    open func getBasicAuth() -> DevCredential? {
        return self.basicAuth
    }
    
    /// set password authentication
    ///
    /// - Parameters:
    ///   - username: login name
    ///   - password: login password
    /// - Returns: password authentication
    open func setPasswordAuth(_ username: String, _ password: String) -> DevAuth {
        self.passwordAuth = DevCredential(username, password)
        return self
    }
    
    /// get password authentication
    ///
    /// - Returns: password authentication
    open func getPasswordAuth() -> DevCredential? {
        return self.passwordAuth
    }
    
    /// set token authentication
    ///
    /// - Parameter apiToken: it was generated in each kintone app
    /// - Returns: token authentication
    open func setApiToken(_ apiToken: String) -> DevAuth {
        self.apiToken = apiToken
        return self
    }
    
    /// get token authentication
    ///
    /// - Returns: token authentication
    open func getApiToken() -> String? {
        return self.apiToken
    }
    
    /// return header credentials for user if tha value of specific Attributes has not empty
    ///
    /// - Returns: header credentials
    open func createHeaderCredentials() -> [DevHTTPHeader?] {
        var headers: [DevHTTPHeader?] = []
        
        if (self.passwordAuth != nil) {
            let passwordAuthString = (self.passwordAuth?.getUsername())! + ":" + (self.passwordAuth?.getPassword())!
            let passwordAuthData = passwordAuthString.data(using: .utf8)
            let httpHeader = DevHTTPHeader(AuthenticationConstants.HEADER_KEY_AUTH_PASSWORD, passwordAuthData?.base64EncodedString())
            headers.append(httpHeader)
        }
        
        if (self.apiToken != nil) {
            let httpHeader = DevHTTPHeader(AuthenticationConstants.HEADER_KEY_AUTH_APITOKEN, self.apiToken)
            headers.append(httpHeader)
        }
        
        if (self.basicAuth != nil) {
            let basicAuthString = (self.basicAuth?.getUsername())! + ":" + (self.basicAuth?.getPassword())!
            let basicAUthData = basicAuthString.data(using: .utf8)
            let httpHeader = DevHTTPHeader(AuthenticationConstants.HEADER_KEY_AUTH_BASIC, AuthenticationConstants.AUTH_BASIC_PREFIX + (basicAUthData?.base64EncodedString())!)
            headers.append(httpHeader)
        }
        return headers
    }
}
