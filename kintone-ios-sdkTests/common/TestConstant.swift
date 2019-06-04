//
//  TestsConstants.swift
//  kintone-ios-sdkTests
//

import Foundation
public class TestConstant {
    class Connection {
        static let environment = ProcessInfo.processInfo.environment
        
        static let DOMAIN = environment["DOMAIN"]!
        static let ADMIN_USERNAME = environment["ADMIN_USERNAME"]!
        static let ADMIN_PASSWORD = environment["ADMIN_PASSWORD"]!
        
        // TODO: following test data will be get from data parsed from initial json data
        static let CRED_USERNAME_WITHOUT_VIEW_APP_PERMISSION = "user1"
        static let CRED_PASSWORD_WITHOUT_VIEW_APP_PERMISSION = "user1@123"
        static let CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION = "user2"
        static let CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION = "user2@123"
        static let CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION = "user3"
        static let CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION = "user3@123"
        static let CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION = "user4"
        static let CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION = "user4@123"
        
        static let CERT_NAME = "YOUR_CERT_NAME"
        static let CERT_PASSWORD = "YOUR_CERT_PASSWORD"
        static let CERT_EXTENSION = "YOUR_CERT_EXTENSION"

        static let PROXY_HOST = "10.224.136.41"
        static let PROXY_PORT = 3128

        static let GUEST_SPACE_ID = 8
    }
    
    class Common {
        static let APP_ID = 1
        static var SPACE_ID = 6
        static var THREAD_ID = 6
        static var GUEST_SPACE_ID  = 8
        static var GUEST_SPACE_THREAD_ID  = 10
        static let GUEST_SPACE_APP_ID = 3
        
        static let MAX_VALUE = 2147483647
        static let PROMISE_TIMEOUT = 30.0
        
        static let NONEXISTENT_ID = 999999999
    }
}
