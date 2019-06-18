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
                offset = (TestCommonHandling.awaitAsync(app.getApps()) as! [AppModel]).count
                appIds = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
            }
            
            afterSuite {
                print("=== TEST CLEANING UP ===")
                AppUtils.deleteApps(appIds: appIds!)
            }
            
            it("test_007_FailedWithApiToken") {
                let apiToken = AppUtils.generateApiToken(app, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appIds![0], token: tokenPermission)
                
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppsRsp = TestCommonHandling.awaitAsync(appModule.getApps()) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsRsp.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
            }
            
            it("test_008_015_SuccessWithLimit") {
                let limit = 3
                let getAppsRsp = TestCommonHandling.awaitAsync(app.getApps(offset, limit)) as! [AppModel]
                expect(getAppsRsp.count).to(equal(limit))
                for (index, app) in getAppsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds![index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("test_008_SuccessWithLimit_GuestSpaceApp") {
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                offset = (TestCommonHandling.awaitAsync(guestAppModule.getApps()) as! [AppModel]).count
                var guestAppIds: [Int]? = AppUtils.createApps(appModule: guestAppModule, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID, amount: amountOfApps)
                
                let limit = 3
                let getAppsRsp = TestCommonHandling.awaitAsync(guestAppModule.getApps(offset, limit)) as! [AppModel]
                expect(getAppsRsp.count).to(equal(limit))
                for (index, app) in getAppsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(guestAppIds![index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(equal(TestConstant.InitData.GUEST_SPACE_ID))
                    expect(app.getThreadId()).to(equal(TestConstant.InitData.GUEST_SPACE_THREAD_ID))
                }
                AppUtils.deleteApps(appIds: guestAppIds!)
            }
            
            it("test_009_SuccessWithOffset") {
                let offset = 2
                let getAppsRspWithOffset = TestCommonHandling.awaitAsync(app.getApps(offset, nil)) as! [AppModel]
                let getAppsRsp = TestCommonHandling.awaitAsync(app.getApps()) as! [AppModel]
                expect(getAppsRspWithOffset.count + offset).to(equal(getAppsRsp.count))
            }
            
            it("test_011_FailedWithLimitZero") {
                let limit = 0
                let getAppsRsp = TestCommonHandling.awaitAsync(app.getApps(nil, limit)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!)
            }
            
            it("test_012_FailedWithLimitGreaterThan100") {
                let limit = 101
                let getAppsRsp = TestCommonHandling.awaitAsync(app.getApps(nil, limit)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsRsp.getErrorResponse(), KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!)
            }
            
            it("test_013_FailedWithNegativeOffset") {
                let offset = -1
                let getAppsRsp = TestCommonHandling.awaitAsync(app.getApps(offset, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!)
            }
            
            it("test_016_FailedWithOffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsRsp = TestCommonHandling.awaitAsync(app.getApps(offset, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsRsp.getErrorResponse(), KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!)
            }
        }
    }
}
