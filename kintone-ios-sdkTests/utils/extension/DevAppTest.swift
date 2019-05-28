///**
/**
 kintone-ios-sdkTests
 Created on 5/27/19
 */

import Foundation
import kintone_ios_sdk
import XCTest
@testable import Promises

class DevAppTest:XCTestCase{
    let appModule = App(TestCommonHandling.createConnection())
    
    func test_generateApiToken() {
        let appID = AppUtils.createApp(appModule: appModule, appName: "Test generate", spaceId: 1, threadId: 1)
        let value = AppUtils.generateToken(appModule, appID)
        let token: TokenEntity = TokenEntity.init(tokenString: value,
                                      viewRecord: true,
                                      addRecord: true,
                                      editRecord: true,
                                      deleteRecord: false,
                                      editApp: false)
        
        AppUtils.updateTokenPermission(appModule: appModule, appId: appID, token: token)
        
        AppUtils.deleteApp(appId: appID)
    }
}
