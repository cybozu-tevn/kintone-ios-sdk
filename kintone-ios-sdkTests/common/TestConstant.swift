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
        // User credentials with permissions for App
        static let CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION = "user2"
        static let CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION = "user2"
        static let CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION = "user10"
        static let CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION = "user10"
        static let CRED_USERNAME_WITHOUT_ADD_RECORDS_PEMISSION = "user9"
        static let CRED_PASSWORD_WITHOUT_ADD_RECORDS_PEMISSION = "user9"
        static let CRED_USERNAME_WITHOUT_EDIT_RECORDS_PEMISSION = "user8"
        static let CRED_PASSWORD_WITHOUT_EDIT_RECORDS_PEMISSION = "user8"
        static let CRED_USERNAME_WITHOUT_DELETE_RECORDS_PEMISSION = "user7"
        static let CRED_PASSWORD_WITHOUT_DELETE_RECORDS_PEMISSION = "user7"
        
        // User creditials with permissions for Record
        static let CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION = "user6"
        static let CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION = "user6"
        static let CRED_USERNAME_WITHOUT_EDIT_RECORD_PEMISSION = "user5"
        static let CRED_PASSWORD_WITHOUT_EDIT_RECORD_PEMISSION = "user5"
        static let CRED_USERNAME_WITHOUT_DELETE_RECORD_PEMISSION = "user4"
        static let CRED_PASSWORD_WITHOUT_DELETE_RECORD_PEMISSION = "user4"
        
        // User creditials with permissions for Field (Text field of initial app)
        static let CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION = "user3"
        static let CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION = "user3"
        static let CRED_USERNAME_WITHOUT_EDIT_FIELD_PEMISSION = "user2"
        static let CRED_PASSWORD_WITHOUT_EDIT_FIELD_PEMISSION = "user2"
        
        public static let GUEST_APP_API_TOKEN = "<GUEST_APP_API_TOKEN>"
        public static let APP_API_TOKEN = "oLVz20BWgdcHXEJPw16AL8epMuq4gOVq9sS369b6"
        public static let APP_API_TOKEN_WITHOUT_VIEW_RECORD_PERMISSION = "JRyO3WynbWZcqAWTNLzxJqGfS4mwLEVNUct20F1p"
        
        
        static let SPACE_ID = 3
        static let GUEST_SPACE_ID = 2
        static let GUEST_THREAD_ID = 2
        // end TODO
        
        static let CERT_NAME = "YOUR_CERT_NAME"
        static let CERT_PASSWORD = "YOUR_CERT_PASSWORD"
        static let CERT_EXTENSION = "YOUR_CERT_EXTENSION"
        
        static let PROXY_HOST = "10.224.136.41"
        static let PROXY_PORT = 3128
    }
    
    class Common {
        // TODO: following test data will be get from data parsed from initial json data
        static var SPACE_ID = 9
        static var THREAD_ID = 9
        static let APP_ID = 3
        static let APP_ID_HAS_MULTIPLE_FIELDS = 4
        static let APP_ID_HAS_REQUIRED_FIELDS = 5
        static let APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS = 6
        
        static var GUEST_SPACE_ID  = 2
        static var GUEST_SPACE_THREAD_ID  = 2
        static let GUEST_SPACE_APP_ID = 2
        // end TODO
        
        static let MAX_VALUE = 2147483647
        static let PROMISE_TIMEOUT = 30.0
        
        static let NONEXISTENT_ID = 999999999
    }
}
