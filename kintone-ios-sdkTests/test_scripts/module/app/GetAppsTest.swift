//
// kintone-ios-sdkTests
// Created on 5/10/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appName = DataRandomization.generateString(prefix: "App-GetApps", length: 5)
        let amountOfApps = 5
        var appIds: [Int] = []
        var offset: Int = 0
        
        describe("GetApps") {
            it("AddTestData_BeforeSuiteWorkaround") {
                var totalApps: Int = 0
                repeat {
                    totalApps = (TestCommonHandling.awaitAsync(appModule.getApps(offset)) as! [AppModel]).count
                    offset += totalApps
                } while (totalApps == 100)
                
                appIds = AppUtils.createApps(appModule: appModule, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
            }
            
            it("Test_007_Error_ApiToken") {
                let apiToken = AppUtils.generateApiToken(appModule, appIds[0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appIds[0], token: tokenPermission)
                
                let appModuleApiToken = App(TestCommonHandling.createConnection(apiToken))
                let getAppsRsp = TestCommonHandling.awaitAsync(appModuleApiToken.getApps()) as! KintoneAPIException
                
                let actualError = getAppsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_008_015_Success_Limit") {
                let limit = 3
                let getAppsRsp = TestCommonHandling.awaitAsync(appModule.getApps(offset, limit)) as! [AppModel]

                expect(getAppsRsp.count).to(equal(limit))
                for (index, app) in getAppsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("Test_008_Success_Limit_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceThreadId = TestConstant.InitData.GUEST_SPACE_THREAD_ID
                let guestSpaceAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, guestSpaceId))
                var offsetGuestSpace: Int = 0
                var totalApps: Int = 0
                repeat {
                    totalApps = (TestCommonHandling.awaitAsync(guestSpaceAppModule.getApps(offsetGuestSpace)) as! [AppModel]).count
                    offsetGuestSpace += totalApps
                } while (totalApps == 100)

                var guestSpaceAppIds = AppUtils.createApps(appModule: guestSpaceAppModule, appName: appName, spaceId: guestSpaceId, threadId: guestSpaceThreadId, amount: amountOfApps)
                
                let limit = 3
                let getAppsRsp = TestCommonHandling.awaitAsync(guestSpaceAppModule.getApps(offsetGuestSpace, limit)) as! [AppModel]
                
                expect(getAppsRsp.count).to(equal(limit))
                for (index, app) in getAppsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(guestSpaceAppIds[index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(equal(guestSpaceId))
                    expect(app.getThreadId()).to(equal(guestSpaceThreadId))
                }
                
                AppUtils.deleteApps(appIds: guestSpaceAppIds)
            }
            
            it("Test_009_Success_Offset") {
                offset = 0
                let numberApps = 88
                var totalApps: Int = 0
                repeat {
                    totalApps = (TestCommonHandling.awaitAsync(appModule.getApps(offset)) as! [AppModel]).count
                    offset += totalApps
                } while (totalApps == 100)
                
                offset = offset - numberApps
                let getAppsRspWithOffset = TestCommonHandling.awaitAsync(appModule.getApps(offset, nil)) as! [AppModel]
                
                expect(getAppsRspWithOffset.count).to(equal(numberApps))
            }
            
            it("Test_011_Error_LimitZero") {
                let limit = 0
                let getAppsRsp = TestCommonHandling.awaitAsync(appModule.getApps(nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_012_Error_LimitGreaterThan100") {
                let limit = 101
                let getAppsRsp = TestCommonHandling.awaitAsync(appModule.getApps(nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_013_Error_NegativeOffset") {
                let offset = -1
                let getAppsRsp = TestCommonHandling.awaitAsync(appModule.getApps(offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_016_Error_OffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsRsp = TestCommonHandling.awaitAsync(appModule.getApps(offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                AppUtils.deleteApps(appIds: appIds)
            }
        }
    }
}
