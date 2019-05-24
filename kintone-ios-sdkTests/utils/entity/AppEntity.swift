///**
/**
 kintone-ios-sdkTests
 Created on 5/21/19
*/

import Foundation
import kintone_ios_sdk

struct AppEntity {
    var appId: Int
    var code: String
    var name: String
    var description: String
    var spaceId: Int
    var threadId: Int
    var creator: Member
    var modifier: Member
    
    init() {
        name = DataRandomization.randomString(length: 5, refix: "App name")
    }
}
