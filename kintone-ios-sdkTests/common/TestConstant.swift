//
//  TestsConstants.swift
//  kintone-ios-sdkTests
//

import Foundation
public class TestConstant {
    class Connection {
        static let environment = ProcessInfo.processInfo.environment
        static let PROXY_IP = TestDataParser.getProxy().ip
        static let PROXY_PORT = TestDataParser.getProxy().port
        
        /**
         * the information will be detect from environment variables
         * static let DOMAIN = environment["DOMAIN"]!
         * static let ADMIN_USERNAME = environment["ADMIN_USERNAME"]!
         * static let ADMIN_PASSWORD = environment["ADMIN_PASSWORD"]!
         * */
        
        static let DOMAIN = TestDataParser.getDomain()
        static let CRED_ADMIN_USERNAME = TestDataParser.getAdministrator().username
        static let CRED_ADMIN_PASSWORD = TestDataParser.getAdministrator().password
        
        // permisstion on app for user
        static let CRED_USERNAME_WITHOUT_CREATE_APP_PERMISSION = "user12"
        static let CRED_PASSWORD_WITHOUT_CREATE_APP_PERMISSION = "user12"
        static let CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION = TestDataParser.getUsers()[1].username
        static let CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION = TestDataParser.getUsers()[1].password
        static let CRED_USERNAME_WITHOUT_APP_PERMISSION = TestDataParser.getUsers()[9].username
        static let CRED_PASSWORD_WITHOUT_APP_PERMISSION = TestDataParser.getUsers()[9].password
        static let CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION = TestDataParser.getUsers()[9].username
        static let CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION = TestDataParser.getUsers()[9].password
        static let CRED_USERNAME_WITHOUT_ADD_RECORDS_PERMISSION = TestDataParser.getUsers()[8].username
        static let CRED_PASSWORD_WITHOUT_ADD_RECORDS_PERMISSION = TestDataParser.getUsers()[8].password
        static let CRED_USERNAME_WITHOUT_EDIT_RECORDS_PERMISSION = TestDataParser.getUsers()[7].username
        static let CRED_PASSWORD_WITHOUT_EDIT_RECORDS_PERMISSION = TestDataParser.getUsers()[7].password
        static let CRED_USERNAME_WITHOUT_DELETE_RECORDS_PERMISSION = TestDataParser.getUsers()[6].username
        static let CRED_PASSWORD_WITHOUT_DELETE_RECORDS_PERMISSION = TestDataParser.getUsers()[6].password
        
        // permisstion on record for user
        static let CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION = TestDataParser.getUsers()[5].username
        static let CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION = TestDataParser.getUsers()[5].password
        static let CRED_USERNAME_WITHOUT_EDIT_RECORD_PEMISSION = TestDataParser.getUsers()[4].username
        static let CRED_PASSWORD_WITHOUT_EDIT_RECORD_PEMISSION = TestDataParser.getUsers()[4].password
        static let CRED_USERNAME_WITHOUT_DELETE_RECORD_PEMISSION = TestDataParser.getUsers()[3].username
        static let CRED_PASSWORD_WITHOUT_DELETE_RECORD_PEMISSION = TestDataParser.getUsers()[3].password
        
        // permisstion on fields for user
        static let CRED_USERNAME_WITHOUT_VIEW_FIELD_PEMISSION = TestDataParser.getUsers()[2].username
        static let CRED_PASSWORD_WITHOUT_VIEW_FIELD_PEMISSION = TestDataParser.getUsers()[2].password
        static let CRED_USERNAME_WITHOUT_EDIT_FIELD_PEMISSION = TestDataParser.getUsers()[1].username
        static let CRED_PASSWORD_WITHOUT_EDIT_FIELDPEMISSION = TestDataParser.getUsers()[1].password
        
        // inacive user
        static let CRED_USERNAME_INACTIVE = TestDataParser.getUsers()[10].username
        static let CRED_PASSWORD_INACTIVE = TestDataParser.getUsers()[10].password
    }
    
    class Common {
        static let MAX_VALUE = 2147483647
        static let PROMISE_TIMEOUT = 30.0
        static let INVALID_PROXY_IP = "HOST NOT FOUND"
        static let INVALID_PROXY_HOST_PORT = -999
        static let NONEXISTENT_ID = 999999999
        static let NEGATIVE_ID = -1
        static let ADMINISTRATOR_USER = "Administrator"
    }
    
    class InitData {
        static let DEPARTMENT_CODE = "department"
        static let DEPARTMENT_TYPE = "ORGANIZATION"
        static let GROUP_CODE = "group"
        static let GROUP_TYPE = "GROUP"
        
        // fields code from applications
        static let NUMBER_FIELD = "Number"
        static let NUMBER_PROHIBIT_DUPLICATE_FIELD  = "Number_Prohibit_Duplicate_Value"
        static let TEXT_FIELD = "Text"
        static let TEXT_UPDATE_KEY_FIELD = "Text_Update_Key"
        static let TEXT_AREA_FIELD = "Text_Area"
        static let DATE_FIELD = "Date"
        static let LINK_FIELD = "Link"
        static let ATTACHMENT_FIELD = "Attachment"
        static let TABLE_FIELD = "Table"
        
        // fields code from appWithUniqueFields
        static let NUMBER_PROHIBIT_DUPLICATE_2ND_FIELD = "Number_unique_2nd"
        static let TABLE_PROHIBIT_DUPLICATE_FIELD = "Table_unique"
        
        static let SPACE_ID = Int(TestDataParser.getNormalSpaceInfo().getSpaceId())
        static var SPACE_THREAD_ID = Int(TestDataParser.getNormalSpaceInfo().getThreadId())
        static let SPACE_APP_ID = Int(TestDataParser.getApps().appInSpace.appId)
        static let SPACE_APP_DESCRIPTION = TestDataParser.getApps().appInSpace.description

        static let GUEST_SPACE_ID = Int(TestDataParser.getGuestSpaceInfo().getSpaceId())
        static var GUEST_SPACE_THREAD_ID  = Int(TestDataParser.getGuestSpaceInfo().getThreadId())
        static let GUEST_SPACE_APP_ID = Int(TestDataParser.getApps().appInGuestSpace.appId)
        
        // the default app is appWithMultipleFields
        static let APP_ID = Int(TestDataParser.getApps().appWithMultipleFields.appId)
        
        static let APP_ID_HAS_MULTIPLE_FIELDS = Int(TestDataParser.getApps().appWithMultipleFields.appId)
        static let APP_ID_HAS_REQUIRED_FIELDS = Int(TestDataParser.getApps().appWithRequiredFields.appId)
        static let APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS = Int(TestDataParser.getApps().appWithUniqueFields.appId)
        static let APP_BLANK_ID = 7
        static let APP_DESCRIPTION = TestDataParser.getApps().appWithMultipleFields.description
        static let APP_NAME = TestDataParser.getApps().appWithMultipleFields.name
        
        static let APP_API_TOKEN = TestDataParser.getApps().appWithMultipleFields.apiToken.fullPermission
        static let SPACE_APP_API_TOKEN = TestDataParser.getApps().appInSpace.apiToken.fullPermission
        static let SPACE_APP_API_TOKEN_ONLY_VIEW_RECORD_PERMISSION = TestDataParser.getApps().appInSpace.apiToken.viewPermission
        static let SPACE_APP_API_TOKEN_WITHOUT_VIEW_RECORD_PERMISSION = TestDataParser.getApps().appInSpace.apiToken.noPermission
        
        static let GUEST_APP_API_TOKEN = TestDataParser.getApps().appInGuestSpace.apiToken.fullPermission
    }
}
