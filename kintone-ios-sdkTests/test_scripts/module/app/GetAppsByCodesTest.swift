//
// kintone-ios-sdkTests
// Created on 6/12/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsByCodesTest: QuickSpec {
    override func spec() {
        describe("GetAppsByCodeTest") {
            let app = App(TestCommonHandling.createConnection())
            let appName = "App Name"
            let amountOfApps = 5
            var appIds: [Int]?
            var appCodes = [String]()
            
            beforeSuite {
                print("=== TEST PREPARATION ===")
                appIds = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
                for appId in appIds! {
                    let appCodeForUpdate = DataRandomization.generateString(length: 4)
                    appCodes.append(appCodeForUpdate)
                    AppUtils.updateMiscSetting(appModule: app, code: appCodeForUpdate, id: appId, name: appName)
                }
            }
            
            afterSuite {
                print("=== TEST CLEANING UP ===")
                AppUtils.deleteApps(appIds: appIds!)
            }
            
            it("Test_030_FailedWithApiToken") {
                let apiToken = AppUtils.generateApiToken(app, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appIds![0], token: tokenPermission)
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppsByCodes = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByCodes.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
            }
            
            it("Test_031_SuccessWithCodes_GuestSpaceApp") {
                var guestSpaceAppCodes = [String]()
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                let guestAppIds: [Int]? = AppUtils.createApps(appModule: guestAppModule, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID, amount: amountOfApps)
                for appId in guestAppIds! {
                    let appCodeForUpdate = DataRandomization.generateString(length: 4)
                    guestSpaceAppCodes.append(appCodeForUpdate)
                    AppUtils.updateMiscSetting(appModule: guestAppModule, code: appCodeForUpdate, id: appId, name: appName)
                }
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(app.getAppsByCodes(guestSpaceAppCodes)) as! [AppModel]
                expect(getAppsByCodesRsp.count).to(equal(guestAppIds?.count))
                for app in getAppsByCodesRsp {
                    expect(app.getName()).to(contain(appName))
                }
            }
            
            it("Test_031_SuccessWithCodes") {
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(app.getAppsByCodes(appCodes)) as! [AppModel]
                expect(getAppsByCodesRsp.count).to(equal(appIds?.count))
                for app in getAppsByCodesRsp {
                    expect(app.getName()).to(contain(appName))
                }
            }
            
            it("Test_032_038_SuccessWithLimit") {
                let limit = 2
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(app.getAppsByCodes(appCodes, nil, limit)) as! [AppModel]
                expect(getAppsByCodesRsp.count).to(equal(limit))
                for app in getAppsByCodesRsp {
                    expect(app.getName()).to(equal(appName))
                }
            }
            
            it("Test_033_SuccessWithOffset") {
                let offset = 2
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(app.getAppsByCodes(appCodes, offset, nil)) as! [AppModel]
                expect(getAppsByCodesRsp.count).to(equal(appCodes.count - offset))
                for app in getAppsByCodesRsp {
                    expect(app.getName()).to(equal(appName))
                }
            }
            
            it("Test_034_GetAppsByCodes_FailedWithLimitZero") {
                let limit = 0
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(app.getAppsByCodes(appCodes, nil, limit)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByCodesRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!)
            }
            
            it("Test_035_FailedWithLimitGreaterThan100") {
                let limit = 101
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(app.getAppsByCodes(appCodes, nil, limit)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByCodesRsp.getErrorResponse(), KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!)
            }
            
            it("Test_036_FailedWithNegativeOffset") {
                let offset = -2
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(app.getAppsByCodes(appCodes, offset, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByCodesRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!)
            }
            
            // This case is used so much time, if you want to execute it, please un-rem
            fit("Test_037_Maximum100Apps") {
                let appIds100Apps = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: 100)
                var codes100Apps = [String]()
                var names100Apps = [String]()
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(app.getAppsByIDs(appIds100Apps)) as! [AppModel]
                for(index, eachApp) in getAppsByIDsRsp.enumerated() {
                    codes100Apps.append(DataRandomization.generateString(length: 4))
                    names100Apps.append(eachApp.getName()!)
                    AppUtils.updateMiscSetting(appModule: app, code: codes100Apps[index], id: eachApp.getAppId()!, name: eachApp.getName()!)
                }
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(app.getAppsByCodes(codes100Apps)) as! [AppModel]
                expect(getAppsByCodesRsp.count).to(equal(codes100Apps.count))
                for(index, eachApp) in getAppsByCodesRsp.enumerated() {
                    expect(eachApp.getName()).to(equal(names100Apps[index]))
                }
                
                AppUtils.deleteApps(appIds: appIds100Apps)
            }
            
            it("Test_039_FailedWithOffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsByCodes = TestCommonHandling.awaitAsync(app.getAppsByCodes(appCodes, offset, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByCodes.getErrorResponse(), KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!)
            }
        }
    }
}
