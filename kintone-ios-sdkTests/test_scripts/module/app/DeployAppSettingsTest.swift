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
        describe("DeployAppSettings") {
            it("Test_64_66_Success_NormalApp") {
                let app = App(TestCommonHandling.createConnection())
                var appIds = [Int]()
                var appNames = [String]()
                
                for _ in 1...5 {
                    let appName = DataRandomization.generateString()
                    appNames.append(appName)
                    let appId = AppUtils.createApp(appModule: app, appName: appName)
                    appIds.append(appId)
                }
                
                let getAppStatusResponse = TestCommonHandling.awaitAsync(app.getAppDeployStatus(appIds)) as! GetAppDeployStatusResponse
                
                for (index, appItem) in getAppStatusResponse.getApps()!.enumerated() {
                    expect(appItem.getStatus()).to(equal( AppDeployStatus.Status.SUCCESS))
                    let getAppResponse = TestCommonHandling.awaitAsync(app.getApp(appItem.getApp()!)) as! AppModel
                    let actualAppName = getAppResponse.getName()
                    let expectedAppName = (appNames[index])
                    expect(actualAppName).to(equal(expectedAppName))
                }
                
                AppUtils.deleteApps(appIds: appIds)
            }
            
            it("Test_64_66_Success_GuestSpaceApp") {
                let app = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                var appIds = [Int]()
                var appNames = [String]()
                
                for _ in 1...5 {
                    let appName = DataRandomization.generateString()
                    appNames.append(appName)
                    let appId = AppUtils.createApp(appModule: app, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID)
                    appIds.append(appId)
                }
                
                let getAppStatusResponse = TestCommonHandling.awaitAsync(app.getAppDeployStatus(appIds)) as! GetAppDeployStatusResponse
                
                for (index, appItem) in getAppStatusResponse.getApps()!.enumerated() {
                    expect(appItem.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
                    let getAppResponse = TestCommonHandling.awaitAsync(app.getApp(appItem.getApp()!)) as! AppModel
                    let actualAppName = getAppResponse.getName()
                    let expectedAppName = (appNames[index])
                    expect(actualAppName).to(equal(expectedAppName))
                }
                
                AppUtils.deleteApps(appIds: appIds)
            }
            
            it("Test_65_Success_WithRevertTrue") {
                let app = App(TestCommonHandling.createConnection())
                let appName = DataRandomization.generateString()
                let addPreviewAppResponse = TestCommonHandling.awaitAsync(app.addPreviewApp(appName)) as! PreviewApp
                let appId = addPreviewAppResponse.getApp()!
                let preViewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(app.deployAppSettings([preViewApp], true))
                AppUtils.waitForDeployAppSucceed(appModule: app, appId: appId)
                let getAppResponse = TestCommonHandling.awaitAsync(app.getApp(appId)) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()
                expectedError?.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(getAppResponse.getErrorResponse(), expectedError!)
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_68_Success_WithoutRevision") {
                let app = App(TestCommonHandling.createConnection())
                let appName = DataRandomization.generateString()
                let addPreviewAppResponse = TestCommonHandling.awaitAsync(app.addPreviewApp(appName)) as! PreviewApp
                let appId = addPreviewAppResponse.getApp()!
                let preViewApp = PreviewApp(appId)
                _ = TestCommonHandling.awaitAsync(app.deployAppSettings([preViewApp]))
                AppUtils.waitForDeployAppSucceed(appModule: app, appId: appId)
                let getAppResponse = TestCommonHandling.awaitAsync(app.getApp(appId)) as! AppModel
                expect(appName).to(equal(getAppResponse.getName()!))
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_69_Error_WithApiToken") {
                var app = App(TestCommonHandling.createConnection())
                let appName = DataRandomization.generateString()
                let appId = AppUtils.createApp(appModule: app, appName: appName, spaceId: TestConstant.InitData.SPACE_ID, threadId: TestConstant.InitData.SPACE_THREAD_ID)
                let APIToken = AppUtils.generateApiToken(app, appId)
                app = App(TestCommonHandling.createConnection(APIToken))
                AppUtils.initAppModule(connectionType: ConnectionType.API_TOKEN, apiToken: APIToken)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(app.deployAppSettings([PreviewApp(appId)])) as! KintoneAPIException
                TestCommonHandling.compareError(deployAppSettingsResponse.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
                
                AppUtils.deleteApp(appId: appId)
                
            }
            
            it("Test_70_Error_NonexistentApp") {
                let app = App(TestCommonHandling.createConnection())
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(app.deployAppSettings([PreviewApp(TestConstant.Common.NONEXISTENT_ID)])) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()
                expectedError?.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(deployAppSettingsResponse.getErrorResponse(), expectedError!)
            }
            
            it("Test_71_Error_WrongRevision") {
                let app = App(TestCommonHandling.createConnection())
                let appName = DataRandomization.generateString()
                let addPreviewAppResponse = TestCommonHandling.awaitAsync(app.addPreviewApp(appName)) as! PreviewApp
                let appId = addPreviewAppResponse.getApp()!
                let previewApp = PreviewApp(appId, TestConstant.Common.NONEXISTENT_ID)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(app.deployAppSettings([previewApp])) as! KintoneAPIException
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()
                expectedError?.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(deployAppSettingsResponse.getErrorResponse(), expectedError!)
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_72_Error_InvalidRevision") {
                let app = App(TestCommonHandling.createConnection())
                let appName = DataRandomization.generateString()
                let addPreviewAppResponse = TestCommonHandling.awaitAsync(app.addPreviewApp(appName)) as! PreviewApp
                let appId = addPreviewAppResponse.getApp()!
                let preViewApp = PreviewApp(appId, -2)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(app.deployAppSettings([preViewApp])) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NEGATIVE_REVISION_ERROR()
                expectedError?.replaceKeyError(oldTemplate: "revision", newTemplate: "apps[0].revision")
                TestCommonHandling.compareError(deployAppSettingsResponse.getErrorResponse(), expectedError!)
                
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_74_Error_NonexistedAppId") {
                let app = App(TestCommonHandling.createConnection())
                let preViewApp = PreviewApp(TestConstant.Common.NONEXISTENT_ID)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(app.deployAppSettings([preViewApp])) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()
                expectedError?.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(deployAppSettingsResponse.getErrorResponse(), expectedError!)
            }
            
            it("Test_75_Error_ZeroAppId") {
                let app = App(TestCommonHandling.createConnection())
                let preViewApp = PreviewApp(0)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(app.deployAppSettings([preViewApp])) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
                expectedError?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[0].app")
                TestCommonHandling.compareError(deployAppSettingsResponse.getErrorResponse(), expectedError!)
            }
            
            it("Test_76_Error_NegativeAppId") {
                let app = App(TestCommonHandling.createConnection())
                let preViewApp = PreviewApp(-4)
                let deployAppSettingsResponse = TestCommonHandling.awaitAsync(app.deployAppSettings([preViewApp])) as! KintoneAPIException
                var expectedError = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
                expectedError?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[0].app")
                TestCommonHandling.compareError(deployAppSettingsResponse.getErrorResponse(), expectedError!)
            }
            
            // This test is conducted by XCode with invalid input for `Revert` param
            //    it("Test_77_Error_InvalidValueRevert") {
            //        let previewApp = PreviewApp(TestConstant.APP_ID, -1)
            //        // let actualResult = common.awaitAsync(common.appModule.deployAppSettings([previewApp], "false")) as! KintoneAPIException
            //    }
            
            //            it("Test_78_Error_PermissionDenied") {
            //                let app = App(TestCommonHandling.createConnection())
            //                let entityAdmin = DevMemberEntity(DevMemberType.USER, TestConstant.Connection.ADMIN_USERNAME)
            //                let admin = SpaceMember(entityAdmin, true)
            //                var members = [SpaceMember]()
            //                members.append(admin)
            //                print("aaaaa", members)
            //                let spaceId = SpaceUtils.addSpace(idTemplate: 1, name: "TestPermission", members: members, isPrivate: true)
            //                let appId = AppUtils.createApp(appModule: app, appName: "TestPermission", spaceId: spaceId, threadId: spaceId)
            //                AppUtils.initAppModule(
            //                    connectionType: ConnectionType.WITHOUT_PERMISSION,
            //                    username: TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION,
            //                    password: TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION)
            //                let deployAppSettings = TestCommonHandling.awaitAsync(app.deployAppSettings([PreviewApp(appId)])) as! KintoneAPIException
            //                let expectedError = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
            //                TestCommonHandling.compareError(deployAppSettings.getErrorResponse(), expectedError!)
            //
            //                SpaceUtils.deleteSpace(spaceId)
            //            }
        }
    }
}
