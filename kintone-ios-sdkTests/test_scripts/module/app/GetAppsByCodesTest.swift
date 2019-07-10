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
        let appModule = App(TestCommonHandling.createConnection())
        let amountOfApps = 5
        var appIds: [Int]!
        var appCodes = [String]()
        var appNames = [String]()
        
        describe("GetAppsByCode") {
            it("AddTestData_BeforeSuiteWorkaround") {
                // Prepare Apps
                let appNamePrefix = DataRandomization.generateString(prefix: "App-GetAppsByCode", length: 5)
                appIds = AppUtils.createApps(appModule: appModule, appName: appNamePrefix, spaceId: nil, threadId: nil, amount: amountOfApps)
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds)) as! [AppModel]
                
                // Set App code for Apps
                for (index, app) in getAppsByIDsRsp.enumerated() {
                    let appCode = DataRandomization.generateString(length: 4)
                    let appName = app.getName()!
                    appCodes.append(appCode)
                    appNames.append(appName)
                    AppUtils.updateMiscSetting(appModule: appModule, code: appCode, id: appIds[index], name: appName)
                }
            }
            
            it("Test_030_Error_ApiToken") {
                let apiToken = AppUtils.generateApiToken(appModule, appIds[0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appIds[0], token: tokenPermission)
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes)) as! KintoneAPIException
                
                let actualError = getAppsByCodesRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_031_Success_WithCodes_GuestSpace") {
                // Prepare Apps for guest space
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID
                let guestSpaceAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, guestSpaceId!))
                
                let guestAppNamePrefix = DataRandomization.generateString(prefix: "App-GetAppsByCodes Guest space", length: 5)
                let guestSpaceAppIds = AppUtils.createApps(appModule: guestSpaceAppModule, appName: guestAppNamePrefix, spaceId: guestSpaceId, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID, amount: amountOfApps)
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(guestSpaceAppModule.getAppsByIDs(guestSpaceAppIds)) as! [AppModel]
                
                // Set App code for Apps
                var guestSpaceAppNames = [String]()
                var guestSpaceAppCodes = [String]()
                for (index, app) in getAppsByIDsRsp.enumerated() {
                    let appCode = DataRandomization.generateString(length: 4)
                    let appName = app.getName()!
                    guestSpaceAppCodes.append(appCode)
                    guestSpaceAppNames.append(appName)
                    AppUtils.updateMiscSetting(appModule: guestSpaceAppModule, code: appCode, id: guestSpaceAppIds[index], name: appName)
                }
                
                // Verify getting Apps by App code
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(guestSpaceAppModule.getAppsByCodes(guestSpaceAppCodes)) as! [AppModel]
                
                expect(getAppsByCodesRsp.count).to(equal(guestSpaceAppIds.count))
                for (index, app) in getAppsByCodesRsp.enumerated() {
                    expect(app.getAppId()).to(equal(guestSpaceAppIds[index]))
                    expect(app.getName()).to(equal(guestSpaceAppNames[index]))
                    expect(app.getCode()).to(equal(guestSpaceAppCodes[index]))
                }
                
                AppUtils.deleteApps(appIds: guestSpaceAppIds)
            }
            
            it("Test_031_Success_WithCodes") {
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes)) as! [AppModel]
                
                expect(getAppsByCodesRsp.count).to(equal(appIds.count))
                for (index, app) in getAppsByCodesRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal(appNames[index]))
                    expect(app.getCode()).to(equal(appCodes[index]))
                }
            }
            
            it("Test_032_038_Success_Limit") {
                let limit = 2
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes, nil, limit)) as! [AppModel]
                
                expect(getAppsByCodesRsp.count).to(equal(limit))
                for (index, app) in getAppsByCodesRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal(appNames[index]))
                    expect(app.getCode()).to(equal(appCodes[index]))
                }
            }
            
            it("Test_033_Success_Offset") {
                let offset = 2
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes, offset, nil)) as! [AppModel]
                
                expect(getAppsByCodesRsp.count).to(equal(appCodes.count - offset))
                for (index, app) in getAppsByCodesRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index + offset]))
                    expect(app.getName()).to(equal(appNames[index + offset]))
                    expect(app.getCode()).to(equal(appCodes[index + offset]))
                }
            }
            
            it("Test_034_Error_LimitZero") {
                let limit = 0
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes, nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsByCodesRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_035_Error_LimitGreaterThan100") {
                let limit = 101
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes, nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsByCodesRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_036_Error_NegativeOffset") {
                let offset = -2
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes, offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsByCodesRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            //            // This test is commented out because it takes so much time for executing
            //            it("Test_037_Success_Maximum100Apps") {
            //                // Prepare Apps
            //                let appNamePrefix = DataRandomization.generateString(prefix: "AppName", length: 5)
            //                let appIds100 = AppUtils.createApps(appModule: appModule, appName: appNamePrefix, spaceId: nil, threadId: nil, amount: 100)
            //                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds)) as! [AppModel]
            //
            //                // Set App code for Apps
            //                var appCodes100 = [String]()
            //                var appNames100 = [String]()
            //                for (index, app) in getAppsByIDsRsp.enumerated() {
            //                    let appCode = DataRandomization.generateString(length: 4)
            //                    let appName = app.getName()!
            //                    appCodes100.append(appCode)
            //                    appCodes100.append(appName)
            //                    AppUtils.updateMiscSetting(appModule: appModule, code: appCode, id: appIds100[index], name: appName)
            //                }
            //
            //                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes100)) as! [AppModel]
            //
            //                expect(getAppsByCodesRsp.count).to(equal(appIds100.count))
            //                for(index, app) in getAppsByCodesRsp.enumerated() {
            //                    expect(app.getAppId()).to(equal(appIds100[index]))
            //                    expect(app.getName()).to(equal(appNames100[index]))
            //                }
            //
            //                AppUtils.deleteApps(appIds: appIds100)
            //            }
            
            it("Test_039_Error_OffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsByCodesRsp = TestCommonHandling.awaitAsync(appModule.getAppsByCodes(appCodes, offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsByCodesRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                AppUtils.deleteApps(appIds: appIds)
            }
        }
    }
}
