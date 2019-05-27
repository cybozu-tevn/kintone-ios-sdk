///**
/**
 kintone-ios-sdkTests
 Created on 5/10/19
 */

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsByIDsTest: QuickSpec {
    override func spec() {
        let app = App(TestCommonHandling.createConnection())
        let appName = "App Name"
        let amountOfApps = 5
        var appIds: [Int]?
        
        beforeSuite {
            print("=== TEST PREPARATION ===")
            appIds = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
        }
        
        afterSuite {
            print("=== TEST CLEANING UP ===")
            AppUtils.deleteApps(appIds: appIds!)
        }
        
        describe("GetAppsByIDsTest") {
            it("Success Case") {
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds)) as! Array<AppModel>
                
                expect(getAppsByIDsRsp.count).to(equal(appIds?.count))
                for (index, app) in getAppsByIDsRsp.enumerated() {
                    // print(app.getAppId()!)
                    expect(app.getAppId()).to(equal(appIds![index]))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
        }
    }
}
