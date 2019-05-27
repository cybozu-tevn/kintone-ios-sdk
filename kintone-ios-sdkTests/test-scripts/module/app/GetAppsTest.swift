///**
/**
 kintone-ios-sdkTests
 Created on 5/10/19
 */

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsTest: QuickSpec {
    override func spec() {
        let app = App(TestCommonHandling.createConnection())
        let appName = "App Name"
        let amountOfApps = 5
        var appIds: [Int]?
        var offset: Int?
        
        describe("GetAppsTest") {
            
            beforeSuite {
                print("=== TEST PREPARATION ===")
                offset = (TestCommonHandling.awaitAsync(app.getApps()) as! Array<AppModel>).count
                appIds = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
            }
            
            afterSuite {
                print("=== TEST CLEANING UP ===")
                AppUtils.deleteApps(appIds: appIds!)
            }
            
            it("Success Case") {
                
                let getAppsRsp = TestCommonHandling.awaitAsync(app.getApps(offset, nil)) as! Array<AppModel>
                for (index, app) in getAppsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds![index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
        }
    }
}
