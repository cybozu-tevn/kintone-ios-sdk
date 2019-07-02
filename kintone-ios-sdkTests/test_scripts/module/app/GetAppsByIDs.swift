//
// kintone-ios-sdkTests
// Created on 5/10/19
//

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
        
        describe("GetAppsByIDsTest") {
            
            beforeSuite {
                print("=== TEST PREPARATION ===")
                appIds = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
            }
            
            afterSuite {
                print("=== TEST CLEANING UP ===")
                AppUtils.deleteApps(appIds: appIds!)
            }
            
            it("test_018_FailedWithApiToken") {
                let apiToken = AppUtils.generateApiToken(app, appIds![0])
                let tokenPermission  = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appIds![0], token: tokenPermission)
                
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByIDsRsp.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
            }
            
            it("test_019_Success") {
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds)) as! [AppModel]
                expect(getAppsByIDsRsp.count).to(equal(appIds?.count))
                for (index, app) in getAppsByIDsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds![index]))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("test_019_Success_GuestSpaceApp") {
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                let guestAppIds: [Int]? = AppUtils.createApps(appModule: guestAppModule, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID, amount: amountOfApps)
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(guestAppModule.getAppsByIDs(guestAppIds)) as! [AppModel]
                
                expect(getAppsByIDsRsp.count).to(equal(guestAppIds?.count))
                for (index, app) in getAppsByIDsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(guestAppIds![index]))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(equal(TestConstant.InitData.GUEST_SPACE_ID))
                    expect(app.getThreadId()).to(equal(TestConstant.InitData.GUEST_SPACE_ID))
                }
            }
            
            it("test_020_027_SusscessWithLimit") {
                let limit = 2
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds, nil, limit)) as! [AppModel]
                expect(getAppsByIDsRsp.count).to(equal(limit))
                for(index, app) in getAppsByIDsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds![index]))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("test_021_SuccessWithOffset") {
                let offset = 2
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds, offset, nil)) as! [AppModel]
                expect(getAppsByIDsRsp.count).to(equal(appIds!.count - offset))
                for(index, app) in getAppsByIDsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds![index+offset]))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("test_023_FailedWithLimitZero") {
                let limit = 0
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds, nil, limit)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByIDsRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!)
            }
            
            it("test_024_FailedWithLimitGreaterThan100") {
                let limit = 101
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds, nil, limit)) as!KintoneAPIException
                TestCommonHandling.compareError(getAppsByIDsRsp.getErrorResponse(), KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!)
            }
            
            it("test_025_FailedWithNegativeOffset") {
                let offset = -1
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds, offset, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByIDsRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!)
            }
            
            it("test_028_FailedWithOffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds, offset, nil)) as!KintoneAPIException
                TestCommonHandling.compareError(getAppsByIDsRsp.getErrorResponse(), KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!)
            }
        }
    }
}
