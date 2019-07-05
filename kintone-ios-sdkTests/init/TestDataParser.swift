//
// kintone-ios-sdkTests
// Created on 5/15/19
//

internal class TestDataParser: Codable {
    static let jsonFileName = "InitializationData"
    static let kintoneTestData = TestCommonHandling.handleDoTryCatch {try JSONHandler(jsonFileName).parseJSON(KintoneTestData.self)} as! KintoneTestData
    
    static func getDomain() -> String {
        return kintoneTestData.domain
    }
    
    static func getProxy() -> proxy {
        return kintoneTestData.proxy
    }
    
    static func getAdministrator() -> administrator {
        return kintoneTestData.administrators
    }
    
    static func getUsers() -> users {
        return kintoneTestData.users
    }
    
    static func getGuestSpaceInfo() -> [space] {
        return kintoneTestData.guestSpaceInfo
    }
    
    static func getNormalSpaceInfo() -> [space] {
        return kintoneTestData.normalSpaceInfo
    }
    
    static func getApps() -> apps {
        return kintoneTestData.apps
    }
}

struct KintoneTestData: Decodable {
    var domain: String
    var proxy: proxy
    var administrators: administrator
    var users: users
    var guestSpaceInfo: [space]
    var normalSpaceInfo: [space]
    var apps: apps
}

struct proxy: Decodable {
    var host: String
    var ip: String
    var port: Int
}

struct administrator: Decodable {
    var username: String
    var password: String
}

struct users: Decodable {
    var amount: Int
    var clone: [user]
}

struct user: Decodable {
    var username: String
    var password: String
    var code: String
    var id: String
}

struct userInfo: Decodable {
    var code: String
    var name: String
}

struct space: Decodable {
    var id: String
    var spaceName: String
    var threadId: String
    var appId: String
    
    func getSpaceId() -> String {
        return id
    }
    
    func getThreadId() -> String {
        return threadId
    }
    
    func getAppOfSpaceId() -> String {
        return appId
    }
}

struct apps: Decodable {
    var appInSpace: [app]
    var appInGuestSpace: [app]
    var appWithMultipleFields: app
    var appWithRequiredFields: app
    var appWithUniqueFields: app
    var appWithoutField: app
    var appWithProcess: app
}

struct app: Decodable {
    var appId: String
    var code: String
    var name: String
    var description: String
    var createdAt: String
    var creator: userInfo
    var modifiedAt: String
    var modifier: userInfo
    var spaceId: String
    var threadId: String
    var fieldCodes: [String]
    var apiToken: apiToken
    var userAppPermissions: userAppPermission
    var userRecordPermissions: userRecordPermission
    var userFieldPermissions: userFieldPermission
    var process: process
    
    func getCreator() -> userInfo {
        return self.creator
    }
    
    func getModifier() -> userInfo {
        return self.modifier
    }
    
    func getFieldCodes() -> [String] {
        return fieldCodes
    }
    
    func getApiToken() -> apiToken {
        return apiToken
    }
    
    func getUserAppPermissions() -> userAppPermission {
        return self.userAppPermissions
    }
    
    func getUserRecordPermissions() -> userRecordPermission {
        return self.userRecordPermissions
    }
    
    func getUserFieldPermissions() -> userFieldPermission {
        return self.userFieldPermissions
    }
    
    func getProcess() -> process {
        return self.process
    }
}

struct apiToken: Decodable {
    var fullPermission: String
    var viewPermission: String
    var noPermission: String
}

struct appPermissions: Decodable {
    var appEditable: Bool
    var recordViewable: Bool
    var recordAddable: Bool
    var recordEditable: Bool
    var recordDeletable: Bool
    var recordImportable: Bool
    var recordExportable: Bool
}

struct userAppPermission: Decodable {
    var userNotHaveAppManagementRight: String
    var userNotHavePermission: String
    var userNotHaveViewRecordsRight: String
    var userNotHaveAddRecordsRight: String
    var userNotHaveEditRecordsRight: String
    var userNotHaveDeleteRecordsRight: String
}

struct userRecordPermission: Decodable {
    var userNotHavePermission: String
    var userNotHaveViewRight: String
    var userNotHaveEditRight: String
    var userNotHaveDeleteRight: String
}

struct userFieldPermission: Decodable {
    var userNotHaveViewRightOnTextField: String
    var userNotHaveEditRightOnTextField: String
}

struct process: Decodable {
    var actions: [String]
    var states: [String]
}
