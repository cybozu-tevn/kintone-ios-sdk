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
        
        static let DOMAIN = TestDataParser.getDomain()
        static let CRED_ADMIN_USERNAME = TestDataParser.getAdministrator().username
        static let CRED_ADMIN_PASSWORD = TestDataParser.getAdministrator().password
        
        // User credentials with permissions on App
        static let users = TestDataParser.getUsers()
        static let CRED_USERNAME_WITHOUT_CREATE_APP_PERMISSION = users.clone[11].username
        static let CRED_PASSWORD_WITHOUT_CREATE_APP_PERMISSION = users.clone[11].password
        static let CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION = users.clone[1].username
        static let CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION = users.clone[1].password
        static let CRED_USERNAME_WITHOUT_APP_PERMISSION = users.clone[9].username
        static let CRED_PASSWORD_WITHOUT_APP_PERMISSION = users.clone[9].password
        static let CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION = users.clone[9].username
        static let CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION = users.clone[9].password
        static let CRED_USERNAME_WITHOUT_ADD_RECORDS_PERMISSION = users.clone[8].username
        static let CRED_PASSWORD_WITHOUT_ADD_RECORDS_PERMISSION = users.clone[8].password
        static let CRED_USERNAME_WITHOUT_EDIT_RECORDS_PERMISSION = users.clone[7].username
        static let CRED_PASSWORD_WITHOUT_EDIT_RECORDS_PERMISSION = users.clone[7].password
        static let CRED_USERNAME_WITHOUT_DELETE_RECORDS_PERMISSION = users.clone[6].username
        static let CRED_PASSWORD_WITHOUT_DELETE_RECORDS_PERMISSION = users.clone[6].password
        
        // User credentials with permissions on record
        static let CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION = users.clone[5].username
        static let CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION = users.clone[5].password
        static let CRED_USERNAME_WITHOUT_EDIT_RECORD_PERMISSION = users.clone[4].username
        static let CRED_PASSWORD_WITHOUT_EDIT_RECORD_PERMISSION = users.clone[4].password
        static let CRED_USERNAME_WITHOUT_DELETE_RECORD_PERMISSION = users.clone[3].username
        static let CRED_PASSWORD_WITHOUT_DELETE_RECORD_PERMISSION = users.clone[3].password
        
        // User credentials with permissions on field
        static let CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION = users.clone[2].username
        static let CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION = users.clone[2].password
        static let CRED_USERNAME_WITHOUT_EDIT_FIELD_PERMISSION = users.clone[1].username
        static let CRED_PASSWORD_WITHOUT_EDIT_FIELD_PERMISSION = users.clone[1].password
        
        // inacive user
        static let CRED_USERNAME_INACTIVE = users.clone[15].username
        static let CRED_PASSWORD_INACTIVE = users.clone[15].password
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
        static let USERS = TestDataParser.getUsers().clone
        static let ORGANIZATIONS = TestDataParser.getOrgInfo().organizations
        
        static let DEPARTMENT_CODE = ORGANIZATIONS[0].code
        static let DEPARTMENT_TYPE = "ORGANIZATION"
        static let GROUP_CODE = TestDataParser.getGroupInfo().code
        static let GROUP_TYPE = "GROUP"
        
        // process actions and status
        static let process = apps.appWithProcess.getProcess()
        static let ACTION_START = process.actions[0]
        static let ACTION_TEST = process.actions[1]
        static let ACTION_REVIEW = process.actions[2]
        static let ACTION_COMPLETE = process.actions[3]
        static let STATE_NOT_STATED = process.states[0]
        static let STATE_IN_PROGRESS = process.states[1]
        static let STATE_TESTING = process.states[2]
        static let STATE_REVIEWING = process.states[3]
        static let STATE_COMPLETED = process.states[4]
        
        // fields code from applications
        static let FIELD_CODES = apps.appWithMultipleFields.fieldCodes
        static let NUMBER_FIELD = FIELD_CODES[0] // "Number"
        static let NUMBER_PROHIBIT_DUPLICATE_FIELD = FIELD_CODES[1] // "Number_Prohibit_Duplicate_Value"
        static let TEXT_FIELD = FIELD_CODES[2] // "Text"
        static let TEXT_UPDATE_KEY_FIELD = FIELD_CODES[3] // "Text_Update_Key"
        static let TEXT_AREA_FIELD = FIELD_CODES[4] // "Text_Area"
        static let DATE_FIELD = FIELD_CODES[5] // "Date"
        static let LINK_FIELD = FIELD_CODES[6] // "Link"
        static let ATTACHMENT_FIELD = FIELD_CODES[7] // "Attachment"
        static let TABLE_FIELD = FIELD_CODES[8] // "Table"
        static let REQUIRE_FIELD = apps.appWithRequiredFields.fieldCodes[0]
        
        // fields code from appWithUniqueFields app
        static let NUMBER_PROHIBIT_DUPLICATE_2ND_FIELD = "Number_unique_2nd"
        static let TABLE_PROHIBIT_DUPLICATE_FIELD = "Table_unique"
        
        // Space and App info
        static let normalSpaces = TestDataParser.getNormalSpaceInfo()
        static let guestSpaces = TestDataParser.getGuestSpaceInfo()
        static let apps = TestDataParser.getApps()
        static let APPS_TEST_GET_APPS = [apps.appInSpace[0], apps.appWithMultipleFields, apps.appWithRequiredFields, apps.appWithUniqueFields, apps.appWithProcess]
        
        static let SPACE_ID = Int(normalSpaces[0].getSpaceId())
        static let SPACE_THREAD_ID = Int(normalSpaces[0].getThreadId())
        static let SPACE_APP_ID = Int(apps.appInSpace[0].appId)
        static let SPACE_APP_DESCRIPTION = apps.appInSpace[0].description
        
        static let SPACE_2_ID = Int(normalSpaces[1].getSpaceId())
        static let SPACE_2_APP_ID = Int(apps.appInSpace[1].appId)
        
        static let GUEST_SPACE_ID = Int(guestSpaces[0].getSpaceId())
        static let GUEST_SPACE_THREAD_ID  = Int(guestSpaces[0].getThreadId())
        static let GUEST_SPACE_APP_ID = Int(apps.appInGuestSpace[0].appId)
        
        // the default app is appWithMultipleFields app
        static let APP_ID = Int(apps.appWithMultipleFields.appId)
        static let APP_DESCRIPTION = apps.appWithMultipleFields.description
        static let APP_NAME = apps.appWithMultipleFields.name
        
        static let APP_ID_HAS_MULTIPLE_FIELDS = Int(apps.appWithMultipleFields.appId)
        static let APP_ID_HAS_REQUIRED_FIELDS = Int(apps.appWithRequiredFields.appId)
        static let APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS = Int(apps.appWithUniqueFields.appId)
        static let APP_BLANK_ID = Int(apps.appWithoutField.appId)
        static let APP_ID_HAS_PROCESS = Int(apps.appWithProcess.appId)
        
        static let APP_API_TOKEN = apps.appWithMultipleFields.apiToken.fullPermission
        static let APP_WITH_PROCESS_API_TOKEN = apps.appWithProcess.apiToken.fullPermission
        static let SPACE_APP_API_TOKEN = apps.appInSpace[0].apiToken.fullPermission
        static let SPACE_APP_API_TOKEN_ONLY_VIEW_RECORD_PERMISSION = apps.appInSpace[0].apiToken.viewPermission
        static let SPACE_APP_API_TOKEN_WITHOUT_VIEW_RECORD_PERMISSION = apps.appInSpace[0].apiToken.noPermission
        
        static let GUEST_APP_API_TOKEN = apps.appInGuestSpace[0].apiToken.fullPermission
    }
}
