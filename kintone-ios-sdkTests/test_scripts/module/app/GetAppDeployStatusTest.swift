//
// kintone-ios-sdkTests
// Created on 5/10/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppDeployStatusTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appName = DataRandomization.generateString(length: 8)
        let amountOfApps = 5
        var appIds: [Int]?
        
        describe("GetAppDeployStatus") {
            it("AddTestData_BeforeSuiteWorkaround") {
                appIds = AppUtils.createApps(appModule: appModule, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
            }
            
            it("Test_079_Success") {
                // Get the deploy status of multiple apps first, then get the deploy status of every single app to compare
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds!)) as! GetAppDeployStatusResponse
                
                let appsDeployStatus = getAppDeployStatusRsp.getApps()!
                for (index, appDeployStatus) in appsDeployStatus.enumerated() {
                    let appId = appDeployStatus.getApp()!
                    let getAppRsp = TestCommonHandling.awaitAsync(appModule.getApp(appId)) as! AppModel
                    
                    expect(getAppRsp.getName()).to(equal("\(appName)\(index)"))
                    expect(appDeployStatus.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
                }
            }
            
            it("Test_079_Success_GuestSpace") {
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                let guestAppIds: [Int]? = AppUtils.createApps(appModule: guestAppModule, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID, amount: amountOfApps)
                
                let getAppDeployeStatusRsp = TestCommonHandling.awaitAsync(guestAppModule.getAppDeployStatus(guestAppIds!)) as! GetAppDeployStatusResponse
                
                let guestAppsDeployStatus = getAppDeployeStatusRsp.getApps()!
                for (index, appDeployStatus) in guestAppsDeployStatus.enumerated() {
                    let appId = appDeployStatus.getApp()!
                    let getAppRsp = TestCommonHandling.awaitAsync(guestAppModule.getApp(appId)) as! AppModel
                    
                    expect(getAppRsp.getName()).to(equal("\(appName)\(index)"))
                    expect(appDeployStatus.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
                }
                
                AppUtils.deleteApps(appIds: guestAppIds!)
            }
            
            // This case takes a lot of time to be run, so it need to be commented out for running on demand
            //            fit("Test_080_Success_Maximum300Apps") {
            //                let appIds = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: 300)
            //
            //                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(appIds)) as! GetAppDeployStatusResponse
            //
            //                expect(getAppDeployStatusRsp.getApps()?.count).to(equal(appIds.count))
            //                for appDeployStt in getAppDeployStatusRsp.getApps()! {
            //                    expect(appDeployStt.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
            //                    let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(appDeployStt.getApp()!)) as! AppModel
            //                    expect(getAppRsp.getName()).to(contain(appName))
            //                }
            //
            //                AppUtils.deleteApps(appIds: appIds)
            //            }
            
            it("Test_081_Error_ApiToken") {
                let apiToken = AppUtils.generateApiToken(appModule, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appIds![0], token: tokenPermission)
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds!)) as! KintoneAPIException
                
                let actualError = getAppDeployStatusRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_082_Error_WithoutAppId") {
                let apiToken = AppUtils.generateApiToken(appModule, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appIds![0], token: tokenPermission)
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus([])) as! KintoneAPIException
                
                let actualError = getAppDeployStatusRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.MISSING_APPS_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_083_Error_NonExistentAppId") {
                // Get the deploy status of an app which is not existent -> it will return an error
                // Then get actualCode, actualMessage of that error to compare to expectedCode, expectedMessage which are defined in KintoneErrorMessage
                let nonExistentAppIds = [TestConstant.Common.NONEXISTENT_ID]
                
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(nonExistentAppIds)) as! KintoneAPIException
                
                let actualError = getAppDeployStatusRsp.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_084_Error_DuplicatedAppId") {
                let duplicateAppIds = [appIds![0], appIds![0]]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(duplicateAppIds)) as! KintoneAPIException
                
                let actualError = getAppDeployStatusRsp.getErrorResponse()!
                var expectedError = KintoneErrorParser.DUPLICATE_APP_ID_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(1))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_085_Error_NegativeAppId") {
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus([-100])) as! KintoneAPIException
                
                let actualError = getAppDeployStatusRsp.getErrorResponse()!
                var expectedError = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_086_Error_ZeroAppId") {
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus([0])) as! KintoneAPIException
                
                let actualError = getAppDeployStatusRsp.getErrorResponse()!
                var expectedError = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_087_Error_MoreThan300AppIds") {
                let appIds = [Int](repeating: 1, count: 301)
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds)) as! KintoneAPIException
                
                let actualError = getAppDeployStatusRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.MORE_THAN_300_APP_IDS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_088_Error_WithoutPermission") {
                let appModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds!)) as! KintoneAPIException
                
                let actualError = getAppDeployStatusRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                AppUtils.deleteApps(appIds: appIds!)
            }
        }
    }
}
