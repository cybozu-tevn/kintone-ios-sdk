///**
/**
 kintone-ios-sdkTests
 Created on 6/10/19
 */

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
            
            it("Test_029_SuccessWithAppName") {
                print("aaaa1-2")
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName(DataRandomization.generateString(prefix: "updated appName", length: 20))
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getName()).to(equal(settings.getName()))
            }
            
            it("Test_030_SuccessWithAppDescription") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setDescription(DataRandomization.generateString(prefix: "updated description"))
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getDescription()).to(equal(settings.getDescription()))
            }
            
            
            it("Test_031_SuccessWithAppIcon") {
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
            
            it("Test_032_SuccessWithAppTheme_White") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.WHITE)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_033_SuccessWithAppTheme_Red") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.RED)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_034_SuccessWithAppTheme_Blue") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.BLUE)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_035_SuccessWithAppTheme_Green") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.GREEN)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_036_SuccessWithAppTheme_Yellow") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.YELLOW)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_037_SuccessWithAppTheme_Black") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setTheme(GeneralSettings.IconTheme.BLACK)
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                let getGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
                expect(getGeneralSettingsResponse.getTheme()).to(equal(settings.getTheme()))
            }
            
            it("Test_038_SuccessWithApp_WithoutRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let currentRevision = settings.getRevision()
                settings.setRevision()
                settings.setName(DataRandomization.generateString(prefix: "updated appName", length: 20))
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(currentRevision! + 1))
            }
            
            it("Test_039_SuccessWithApp_NegativeRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                let currentRevision = settings.getRevision()
                settings.setRevision(-1)
                settings.setName(DataRandomization.generateString(prefix: "updated appName", length: 20))
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! BasicResponse
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(currentRevision! + 1))
            }
            
            it("Test_040_SuccessWithoutGeneralSetting") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, nil)) as! BasicResponse
                
                expect(updateGeneralSettingsResponse.getRevision()).to(equal(settings.getRevision()! + 1))
            }
            
            it("Test_041_FailedWithApiToken") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                let appModuleWithAPIToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModuleWithAPIToken.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
            }
            
            it("Test_042_FailedWithWrongRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setRevision(TestConstant.Common.NONEXISTENT_ID)
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(appModule.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.INCORRECT_REVISION_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(appId))
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), expectedError)
            }
            
            it("Test_043_FailedWithInvalidRevision") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setRevision(-4)
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.NEGATIVE_REVISION_ERROR()!)
            }
            
            it("Test_045_FailedWithNonexistedAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(TestConstant.Common.NONEXISTENT_ID, settings)) as! KintoneAPIException
                
                
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), expectedError)
            }
            
            it("Test_046_FailedWithZeroAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(0, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
            }
            
            it("Test_047_FailedWithNegativeAppId") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(
                    appModule.updateGeneralSettings(-4, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
            }
            
            it("Test_051_PermissionDenied") {
                let settings = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                settings.setName("updated appName")
                
                let appModuleWithoutViewRecordsPermission = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let updateGeneralSettingsResponse = TestCommonHandling.awaitAsync(appModuleWithoutViewRecordsPermission.updateGeneralSettings(appId, settings)) as! KintoneAPIException
                
                TestCommonHandling.compareError(updateGeneralSettingsResponse.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
            }
        }
        
        describe("UpdateGeneralSettings_2") {
            it("Test_029_SuccessWithAppName_GuestSpaceApp") {
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
