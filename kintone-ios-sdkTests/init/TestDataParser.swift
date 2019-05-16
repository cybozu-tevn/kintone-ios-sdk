///**
/**
 kintone-ios-sdkTests
 Created on 5/15/19
 */

import Foundation

internal class TestDataParser {
    static let jsonFileName = "config"
    static let kintoneTestData = TestCommonHandling.handleDoTryCatch{try JSONHandler(jsonFileName).parseJSON(KintoneTestData.self)} as! KintoneTestData
    
    static func getDomain() -> String {
        return kintoneTestData.domain
    }
    
    static func getProxy() -> proxy {
        return kintoneTestData.proxy
    }
    
    static func getUsers() -> [user] {
        return kintoneTestData.users
    }
    
    static func getGuestSpace() -> guestSpace {
        return kintoneTestData.guestSpace
    }
    
    static func getNormalSpace() -> normalSpace {
        return kintoneTestData.normalSpace
    }
    
    static func getApp() -> app {
        return kintoneTestData.app
    }
}

struct KintoneTestData: Decodable {
    var domain: String
    var proxy: proxy
    var administrators: user
    var users: [user]
    var guestSpace: guestSpace
    var normalSpace: normalSpace
    var app: app
}

struct proxy: Decodable {
    var host: String
    var ip: String
    var port: Int
}

struct user: Decodable {
    var username: String
    var password: String
}

struct guestSpace: Decodable {
    var id: String
    var threadID: String
    var app:app
    
    func getSpaceId() -> String {
        return id
    }
    
    func getThreadId() -> String {
        return threadID
    }
}

struct normalSpace: Decodable {
    var id: String
    var threadID: String
    var app:app
    
    func getSpaceId() -> String {
        return id
    }
    
    func getThreadId() -> String {
        return threadID
    }
}

struct app: Decodable {
    var id: String
    var apiToken: String
    var name: String
    var code: String
    var fieldCodes: [String]
    
    func getAppId() -> String {
        return id
    }
    
    func getApiToken() -> String {
        return apiToken
    }
    
    func getAppName() -> String {
        return name
    }
    
    func getAppCode() -> String {
        return code
    }
    
    func getFieldCodes() -> [String] {
        return fieldCodes
    }
}
