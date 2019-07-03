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
        
        describe("UpdateGeneralSettings_1") {
            beforeSuite {
                let appName = DataRandomization.generateString()
                appId = AppUtils.createApp(appModule: appModule, appName: appName)
            }
            
            afterSuite {
                AppUtils.deleteApp(appId: appId)
            }
            
            it("Test_028_Success") {
                let appIcon = Icon("APP38", Icon.IconType.PRESET)
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                settings.setDescription("updated description")
                settings.setIcon(appIcon)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getName()).to(equal(settings.getName()))
                expect(getGeneralSettingsResponse.getDescription()).to(equal(settings.getDescription()))
                expect(getGeneralSettingsResponse.getIcon()?.getKey()).to(equal(settings.getIcon()?.getKey()))
            }
            
            it("Test_029_Success_AppName") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName(DataRandomization.generateString(prefix: "updated appName", length: 20))
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getName()).to(equal(settings.getName()))
            }
            
            it("Test_030_Success_AppDescription") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setDescription(DataRandomization.generateString(prefix: "updated description"))
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getDescription()).to(equal(settings.getDescription()))
            }
            
            it("Test_031_Success_AppIcon") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let appIcon = Icon("APP38", Icon.IconType.PRESET)
                settings.setIcon(appIcon)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getIcon()?.getKey()).to(equal(settings.getIcon()?.getKey()))
            }
            
            it("Test_032_Success_AppTheme_White") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.WHITE)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_033_Success_AppTheme_Red") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.RED)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_034_Success_AppTheme_Blue") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.BLUE)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_035_Success_AppTheme_Green") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.GREEN)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_036_Success_AppTheme_Yellow") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.YELLOW)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_037_Success_AppTheme_Black") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.BLACK)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_038_Success_WithoutRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let currentRevision = settings.getRevision()
                settings.setRevision()
                settings.setName(DataRandomization.generateString(prefix: "updated appName", length: 20))
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(currentRevision! + 1))
            }
            
            it("Test_039_Success_NegativeRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let currentRevision = settings.getRevision()
                settings.setRevision(-1)
                settings.setName(DataRandomization.generateString(prefix: "updated appName", length: 20))
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(currentRevision! + 1))
            }
            
            it("Test_040_Success_WithoutGeneralSetting") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, nil)) as! BasicResponse
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
            }
            
            it("Test_041_Error_ApiToken") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                let appModuleWithAPIToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModuleWithAPIToken.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
            }
            
            it("Test_042_Error_WrongRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setRevision(TestConstant.Common.NONEXISTENT_ID)
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(appModule.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), expectedError)
            }
            
            it("Test_043_Error_InvalidRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setRevision(-4)
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.NEGATIVE_REVISION_ERROR()!)
            }
            
            it("Test_045_Error_NonexistedAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(TestConstant.Common.NONEXISTENT_ID, settings)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), expectedError)
            }
            
            it("Test_046_Error_ZeroAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(0, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
            }
            
            it("Test_047_Error_NegativeAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(-4, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
            }
            
            it("Test_051_Error_PermissionDenied") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let appModuleWithoutViewRecordsPermission = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(appModuleWithoutViewRecordsPermission.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
            }
        }
        
        describe("UpdateGeneralSettings_2") {
            it("Test_029_Success_AppName_GuestSpaceApp") {
                print("aaaa2-1")
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                let appName = DataRandomization.generateString()
                let appId = AppUtils.createApp(appModule: appModuleGuestSpace, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID)
                
                let settings = TestCommonHandling.awaitAsync(appModuleGuestSpace.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(appModuleGuestSpace.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(appModuleGuestSpace.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getName()).to(equal(settings.getName()))
                
                AppUtils.deleteApp(appId: appId)
            }
        }
    }
}
