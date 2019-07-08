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
            beforeSuite {
                print("=== TEST PREPARATION ===")
                appIds = AppUtils.createApps(appModule: appModule, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
            }
            
            afterSuite {
                print("=== TEST CLEANING UP ===")
                AppUtils.deleteApps(appIds: appIds!)
            }
            
            it("Test_079_Success") {
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
                
                let actualCode = getAppDeployStatusRsp.getErrorResponse()?.getCode()
                let actualMessage = getAppDeployStatusRsp.getErrorResponse()?.getMessage()
                let expectedCode = KintoneErrorParser.API_TOKEN_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.API_TOKEN_ERROR()?.getMessage()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
            }
            
            it("Test_082_Error_WithoutAppId") {
                let apiToken = AppUtils.generateApiToken(appModule, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appIds![0], token: tokenPermission)
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus([])) as! KintoneAPIException
                
                let actualCode = getAppDeployStatusRsp.getErrorResponse()?.getCode()
                let actualMessage = getAppDeployStatusRsp.getErrorResponse()?.getMessage()
                let actualErrors = getAppDeployStatusRsp.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.MISSING_APPS_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.MISSING_APPS_ERROR()?.getMessage()
                let expectedErrors = KintoneErrorParser.MISSING_APPS_ERROR()?.getErrors()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors))
            }
            
            it("Test_083_Error_NonExistentAppId") {
                let nonExistentAppIds = [TestConstant.Common.NONEXISTENT_ID]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(nonExistentAppIds)) as! KintoneAPIException
                
                let actualCode = getAppDeployStatusRsp.getErrorResponse()?.getCode()
                let expectedCode = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()?.getCode()
                let actualMessage = getAppDeployStatusRsp.getErrorResponse()?.getMessage()
                var expectedMessage = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()?.getMessage()
                expectedMessage = expectedMessage?.replacingOccurrences(of: "%VARIABLE", with: String(TestConstant.Common.NONEXISTENT_ID))
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
            }
            
            it("Test_084_Error_DuplicatedAppId") {
                let duplicateAppIds = [appIds![0], appIds![0]]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(duplicateAppIds)) as! KintoneAPIException
                
                let actualCode = getAppDeployStatusRsp.getErrorResponse()?.getCode()
                let actualMessage = getAppDeployStatusRsp.getErrorResponse()?.getMessage()
                let actualErrors = getAppDeployStatusRsp.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.DUPLICATE_APP_ID_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.DUPLICATE_APP_ID_ERROR()?.getMessage()
                var expectedErrors = KintoneErrorParser.DUPLICATE_APP_ID_ERROR()
                expectedErrors?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(1))
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors?.errors))
            }
            
            it("Test_085_Error_NegativeAppId") {
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus([-100])) as! KintoneAPIException
                
                let actualCode = getAppDeployStatusRsp.getErrorResponse()?.getCode()
                let actualMessage = getAppDeployStatusRsp.getErrorResponse()?.getMessage()
                let actualErrors = getAppDeployStatusRsp.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()?.getMessage()
                var expectedErrors = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
                expectedErrors?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "")
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors?.errors))
            }
            
            it("Test_086_Error_ZeroAppId") {
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus([0])) as! KintoneAPIException
                
                let actualCode = getAppDeployStatusRsp.getErrorResponse()?.getCode()
                let actualMessage = getAppDeployStatusRsp.getErrorResponse()?.getMessage()
                let actualErrors = getAppDeployStatusRsp.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()?.getMessage()
                var expectedErrors = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
                expectedErrors?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "")
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors?.errors))
            }
            
            it("Test_087_Error_MoreThan300AppIds") {
                let appIds = [Int](repeating: 1, count: 301)
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds)) as! KintoneAPIException
                
                let actualCode = getAppDeployStatusRsp.getErrorResponse()?.getCode()
                let actualMessage = getAppDeployStatusRsp.getErrorResponse()?.getMessage()
                let actualErrors = getAppDeployStatusRsp.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.MORE_THAN_300_APP_IDS()?.getCode()
                let expectedMessage = KintoneErrorParser.MORE_THAN_300_APP_IDS()?.getMessage()
                let expectedErrors = KintoneErrorParser.MORE_THAN_300_APP_IDS()?.getErrors()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors))
            }
            
            it("Test_088_Error_WithoutPermission") {
                let appModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds!)) as! KintoneAPIException
                
                let actualCode = getAppDeployStatusRsp.getErrorResponse()?.getCode()
                let actualMessage = getAppDeployStatusRsp.getErrorResponse()?.getMessage()
                let expectedCode = KintoneErrorParser.PERMISSION_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.PERMISSION_ERROR()?.getMessage()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
            }
        }
    }
}
