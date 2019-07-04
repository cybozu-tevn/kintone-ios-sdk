//
// kintone-ios-sdkTests
// Created on 6/10/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class UpdateGeneralSettingsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        var appId: Int!
        
        describe("UpdateGeneralSettings") {
            beforeSuite {
                let appName = DataRandomization.generateString()
                appId = AppUtils.createApp(appModule: appModule, appName: appName)
            }
            
            afterSuite {
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_028_Success") {
                // Set properties for app general settings
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                let appName = DataRandomization.generateString(prefix: "updated appName", length: 20)
                settings.setName(appName)
                let description = DataRandomization.generateString(prefix: "updated description")
                settings.setDescription(description)
                let appIcon = Icon("APP38", Icon.IconType.PRESET)
                settings.setIcon(appIcon)
                
                // Update general settings
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                // Verify
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getName()).to(equal(appName))
                expect(getGeneralSettingsRsp.getDescription()).to(equal(description))
                expect(getGeneralSettingsRsp.getIcon()?.getKey()).to(equal(appIcon.getKey()))
            }
            
            it("Test_029_Success_AppName") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                let appName = DataRandomization.generateString(prefix: "updated appName", length: 20)
                settings.setName(appName)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getName()).to(equal(appName))
            }
            
            it("Test_030_Success_AppDescription") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                let description = DataRandomization.generateString(prefix: "updated description")
                settings.setDescription(description)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getDescription()).to(equal(description))
            }
            
            it("Test_031_Success_AppIcon") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                let appIcon = Icon("APP38", Icon.IconType.PRESET)
                settings.setIcon(appIcon)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getIcon()?.getKey()).to(equal(appIcon.getKey()))
            }
            
            it("Test_032_Success_AppTheme_White") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setTheme(GeneralSettings.IconTheme.WHITE)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_033_Success_AppTheme_Red") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setTheme(GeneralSettings.IconTheme.RED)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_034_Success_AppTheme_Blue") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setTheme(GeneralSettings.IconTheme.BLUE)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_035_Success_AppTheme_Green") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setTheme(GeneralSettings.IconTheme.GREEN)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_036_Success_AppTheme_Yellow") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setTheme(GeneralSettings.IconTheme.YELLOW)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_037_Success_AppTheme_Black") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setTheme(GeneralSettings.IconTheme.BLACK)
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_038_Success_WithoutRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setRevision()
                settings.setName(DataRandomization.generateString(prefix: "updated appName", length: 20))
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
            }
            
            it("Test_039_Success_NegativeRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setRevision(-1)
                settings.setName(DataRandomization.generateString(prefix: "updated appName", length: 20))
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
            }
            
            it("Test_040_Success_WithoutGeneralSetting") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, nil)) as! BasicResponse
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
            }
            
            it("Test_041_Error_ApiToken") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                let appModuleWithAPIToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModuleWithAPIToken.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                let actualError = updateGeneralSettingsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_042_Error_WrongRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setRevision(TestConstant.Common.NONEXISTENT_ID)
                settings.setName("updated appName")
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(appModule.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                let actualError = updateGeneralSettingsRsp.getErrorResponse()
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_043_Error_InvalidRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setRevision(-4)
                settings.setName("updated appName")
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                let actualError = updateGeneralSettingsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_REVISION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_045_Error_NonexistedAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(TestConstant.Common.NONEXISTENT_ID, settings)) as! KintoneAPIException
                
                let actualError = updateGeneralSettingsRsp.getErrorResponse()
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_046_Error_ZeroAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(0, settings)) as! KintoneAPIException
                
                let actualError = updateGeneralSettingsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_047_Error_NegativeAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(-4, settings)) as! KintoneAPIException
                
                let actualError = updateGeneralSettingsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_051_Error_PermissionDenied") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let appModuleWithoutManageAppPermission = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(appModuleWithoutManageAppPermission.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                let actualError = updateGeneralSettingsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_029_Success_AppName_GuestSpace") {
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                let appName = DataRandomization.generateString()
                let appId = AppUtils.createApp(appModule: appModuleGuestSpace, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID)
                
                let settings = TestCommonHandling.awaitAsync(appModuleGuestSpace.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let revision = settings.getRevision()!
                settings.setName("updated appName")
                
                let updateGeneralSettingsRsp = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsRsp = TestCommonHandling.awaitAsync(appModuleGuestSpace.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsRsp.getRevision()).to(equal(revision + 1))
                expect(getGeneralSettingsRsp.getName()).to(equal(settings.getName()))
                
                AppUtils.deleteApp(appId: appId)
            }
        }
    }
}
