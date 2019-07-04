//
// kintone-ios-sdkTests
// Created on 5/30/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class DeployAppSettingsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        
        describe("DeployAppSettings") {
            it("Test_064_066_Success_NormalApp") {
                // Add preview apps and deploy
                var appIds = [Int]()
                var appNames = [String]()
                
                for _ in 1...5 {
                    let appName = DataRandomization.generateString()
                    appNames.append(appName)
                    let appId = AppUtils.createApp(appModule: appModule, appName: appName)
                    appIds.append(appId)
                }
                
                // Verify apps have been deployed
                let getAppStatusResponse = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds)) as! GetAppDeployStatusResponse
                
                for (index, appItem) in getAppStatusResponse.getApps()!.enumerated() {
                    expect(appItem.getStatus()).to(equal( AppDeployStatus.Status.SUCCESS))
                    let getAppResponse = TestCommonHandling.awaitAsync(appModule.getApp(appItem.getApp()!)) as! AppModel
                    let actualAppName = getAppResponse.getName()
                    let expectedAppName = (appNames[index])
                    expect(actualAppName).to(equal(expectedAppName))
                }
                
                // Delete test data
                AppUtils.deleteApps(appIds: appIds)
            }
            
            it("Test_064_066_Success_GuestSpace") {
                let appModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                var appIds = [Int]()
                var appNames = [String]()
                
                for _ in 1...5 {
                    let appName = DataRandomization.generateString()
                    appNames.append(appName)
                    let appId = AppUtils.createApp(appModule: appModule, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID)
                    appIds.append(appId)
                }
                
                let getAppStatusResponse = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds)) as! GetAppDeployStatusResponse
                
                for (index, appItem) in getAppStatusResponse.getApps()!.enumerated() {
                    expect(appItem.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
                    let getAppResponse = TestCommonHandling.awaitAsync(appModule.getApp(appItem.getApp()!)) as! AppModel
                    let actualAppName = getAppResponse.getName()
                    let expectedAppName = (appNames[index])
                    expect(actualAppName).to(equal(expectedAppName))
                }
                
                AppUtils.deleteApps(appIds: appIds)
            }
            
            it("Test_065_Success_RevertTrue") {
                // Add Preview App
                let appName = DataRandomization.generateString()
                let addPreviewAppResponse = TestCommonHandling.awaitAsync(appModule.addPreviewApp(appName)) as! PreviewApp
                let appId = addPreviewAppResponse.getApp()!
                
                // Deploy App settings with revert = true
                let preViewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([preViewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
                
                // Verify App is not deployed
                let getAppResponse = TestCommonHandling.awaitAsync(appModule.getApp(appId)) as! KintoneAPIException
                let actualError = getAppResponse.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_068_Success_WithoutRevision") {
                let appName = DataRandomization.generateString()
                let addPreviewAppResponse = TestCommonHandling.awaitAsync(appModule.addPreviewApp(appName)) as! PreviewApp
                let appId = addPreviewAppResponse.getApp()!
                let preViewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(appModule.deployAppSettings([preViewApp]))
                AppUtils.waitForDeployAppSucceed(appModule: appModule, appId: appId)
                
                let getAppResponse = TestCommonHandling.awaitAsync(appModule.getApp(appId)) as! AppModel
                expect(appName).to(equal(getAppResponse.getName()!))
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_069_Error_ApiToken") {
                let appName = DataRandomization.generateString()
                let appId = AppUtils.createApp(appModule: appModule, appName: appName, spaceId: TestConstant.InitData.SPACE_ID, threadId: TestConstant.InitData.SPACE_THREAD_ID)
                
                let APIToken = AppUtils.generateApiToken(appModule, appId)
                let appModuleAPIToken = App(TestCommonHandling.createConnection(APIToken))
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(appModuleAPIToken.deployAppSettings([PreviewApp(appId)])) as! KintoneAPIException
                
                let actualError = deployAppSettingsResponse.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_070_Error_NonexistentApp") {
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(appModule.deployAppSettings([PreviewApp(TestConstant.Common.NONEXISTENT_ID)])) as! KintoneAPIException
                
                let actualError = deployAppSettingsResponse.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_071_Error_WrongRevision") {
                let appName = DataRandomization.generateString()
                let addPreviewAppResponse = TestCommonHandling.awaitAsync(appModule.addPreviewApp(appName)) as! PreviewApp
                let appId = addPreviewAppResponse.getApp()!
                let previewApp = PreviewApp(appId, TestConstant.Common.NONEXISTENT_ID)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp])) as! KintoneAPIException
                
                let actualError = deployAppSettingsResponse.getErrorResponse()
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_072_Error_InvalidRevision") {
                let appName = DataRandomization.generateString()
                let addPreviewAppResponse = TestCommonHandling.awaitAsync(appModule.addPreviewApp(appName)) as! PreviewApp
                let appId = addPreviewAppResponse.getApp()!
                let preViewApp = PreviewApp(appId, -2)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(appModule.deployAppSettings([preViewApp])) as! KintoneAPIException
                
                let actualError = deployAppSettingsResponse.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_REVISION_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "revision", newTemplate: "apps[0].revision")
                TestCommonHandling.compareError(actualError, expectedError)
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_074_Error_NonexistedAppId") {
                let preViewApp = PreviewApp(TestConstant.Common.NONEXISTENT_ID)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(appModule.deployAppSettings([preViewApp])) as! KintoneAPIException
                
                let actualError = deployAppSettingsResponse.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_075_Error_ZeroAppId") {
                let preViewApp = PreviewApp(0)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(appModule.deployAppSettings([preViewApp])) as! KintoneAPIException
                
                let actualError = deployAppSettingsResponse.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[0].app")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_076_Error_NegativeAppId") {
                let preViewApp = PreviewApp(-4)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(appModule.deployAppSettings([preViewApp])) as! KintoneAPIException
                
                let actualError = deployAppSettingsResponse.getErrorResponse()
                var expectedError = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[0].app")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // This test is conducted by XCode with invalid input for `Revert` param
            //    it("Test_077_Error_InvalidValueRevert") {
            //        let previewApp = PreviewApp(TestConstant.APP_ID, -1)
            //        // let actualResult = TestCommonHandling.awaitAsync(appModule.deployAppSettings([previewApp], "false")) as! KintoneAPIException
            //    }
            
            it("Test_078_Error_PermissionDenied") {
                let appName = DataRandomization.generateString()
                let appId = AppUtils.createApp(appModule: appModule, appName: appName, spaceId: TestConstant.InitData.SPACE_ID, threadId: TestConstant.InitData.SPACE_THREAD_ID)
                
                let appModuleWithoutManageAppPermission = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(appModuleWithoutManageAppPermission.deployAppSettings([PreviewApp(appId)])) as! KintoneAPIException
                
                let actualError = deployAppSettingsResponse.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                AppUtils.deleteApp(appId: appId)
            }
        }
    }
}
