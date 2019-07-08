//
// kintone-ios-sdkTests
// Created on 7/3/19
// 

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetGeneralSettingsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        var appId: Int?
        
        // prepare Settings info
        let generalSettings: GeneralSettings = GeneralSettings()
        generalSettings.setName("App Name")
        // generalSettings.setDescription("")
        generalSettings.setIcon(Icon("APP39", Icon.IconType.PRESET))
        generalSettings.setTheme(GeneralSettings.IconTheme.WHITE)
        
        describe("GetGeneralSettings") {
            beforeSuite {
                print("=== TEST PREPARATION ===")
                appId = AppUtils.createApp(appModule: appModule, appName: "App Name", spaceId: nil, threadId: nil)
            }
            afterSuite {
                print("=== TEST CLEANING UP ===")
                AppUtils.deleteApp(appId: appId!)
            }
            
            it("Test_003_Success_PreliveApp") {
                // Get GeneralSettings of an app which is created in beforeSuite
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_004_Success_LiveApp") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_004_Success_LiveApp_GuestSpace") {
                let generalSettingsForGuestSpaceApp: GeneralSettings = GeneralSettings()
                generalSettingsForGuestSpaceApp.setName("Guest Space App Name")
                generalSettingsForGuestSpaceApp.setDescription("")
                generalSettingsForGuestSpaceApp.setIcon(Icon("APP39", Icon.IconType.PRESET))
                generalSettingsForGuestSpaceApp.setTheme(GeneralSettings.IconTheme.WHITE)
                
                let guestSpaceAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                let guestAppId = AppUtils.createApp(appModule: guestSpaceAppModule, appName: "Guest Space App Name", spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID)
                let response = TestCommonHandling.awaitAsync(guestSpaceAppModule.getGeneralSettings(guestAppId)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettingsForGuestSpaceApp.getName()))
                // expect(response.getDescription()).to(equal(generalSettingsForGuestSpaceApp.getDescription()))
                expect(response.getTheme()).to(equal(generalSettingsForGuestSpaceApp.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettingsForGuestSpaceApp.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettingsForGuestSpaceApp.getIcon()?.getIconType()))
                
                AppUtils.deleteApp(appId: guestAppId)
            }
            
            it("Test_005_Success_LiveApp") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_006_Success_Prelive_DefaultLang") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.DEFAULT)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_007_Success_Prelive_ZhLang") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.ZH, false)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_008_Success_Prelive_JaLang") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.JA, false)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_009_Success_Prelive_UserLang") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.USER, false)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_010_Success_DefaultLang") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.DEFAULT, true)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_011_Success_ZhLang") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.ZH, true)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_012_Success_JaLang") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.JA, true)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_013_Success_UserLang") {
                let reponse = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.USER, true)) as! GeneralSettings
                
                expect(reponse.getName()).to(equal(generalSettings.getName()))
                // expect(reponse.getDescription()).to(equal(generalSettings.getDescription()))
                expect(reponse.getTheme()).to(equal(generalSettings.getTheme()))
                expect(reponse.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(reponse.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_014_Success_DefaultLang_WithoutIsPreview") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting.DEFAULT)) as! GeneralSettings
                
                expect(response.getName()).to(equal(generalSettings.getName()))
                // expect(response.getDescription()).to(equal(generalSettings.getDescription()))
                expect(response.getTheme()).to(equal(generalSettings.getTheme()))
                expect(response.getIcon()?.getKey()).to(equal(generalSettings.getIcon()?.getKey()))
                expect(response.getIcon()?.getIconType()).to(equal(generalSettings.getIcon()?.getIconType()))
            }
            
            it("Test_015_Error_WithIsPreviewTrue_ApiToken") {
                let appModuleTmp = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let appIdTmp = TestConstant.InitData.APP_ID
                
                let response = TestCommonHandling.awaitAsync(appModuleTmp.getGeneralSettings(appIdTmp!, LanguageSetting.DEFAULT, true)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                let expectedCode = KintoneErrorParser.API_TOKEN_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.API_TOKEN_ERROR()?.getMessage()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
            }
            
            it("Test_016_Error_WithIsPreviewFalse_ApiToken") {
                let appModuleTmp = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let appIdTmp = TestConstant.InitData.APP_ID
                
                let response = TestCommonHandling.awaitAsync(appModuleTmp.getGeneralSettings(appIdTmp!, LanguageSetting.DEFAULT, false)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                let expectedCode = KintoneErrorParser.API_TOKEN_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.API_TOKEN_ERROR()?.getMessage()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
            }
            
            it("Test_017_Error_WithoutIsPreview_ApiToken") {
                let appModuleTmp = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let appIdTmp = TestConstant.InitData.APP_ID
                
                let response = TestCommonHandling.awaitAsync(appModuleTmp.getGeneralSettings(appIdTmp!, LanguageSetting.DEFAULT)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                let expectedCode = KintoneErrorParser.API_TOKEN_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.API_TOKEN_ERROR()?.getMessage()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
            }
            
            // Xcode will shown an error when missing input param
            //            it("Test_018_Error_WithoutAppId"){
            //                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings())
            //            }
            
            it("Test_019_Error_WithNonExistentPreliveAppId") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(TestConstant.Common.NONEXISTENT_ID, LanguageSetting.DEFAULT, true)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                let expectedCode = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()?.getCode()
                var expectedMessage = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()?.getMessage()
                expectedMessage = expectedMessage!.replacingOccurrences(of: "%VARIABLE", with: String(TestConstant.Common.NONEXISTENT_ID))
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
            }
            
            it("Test_020_Error_WithNegativePreliveAppId") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(TestConstant.Common.NEGATIVE_ID, LanguageSetting.DEFAULT, true)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                let actualErrors = response.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getMessage()
                let expectedErrors = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getErrors()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors))
            }
            
            it("Test_021_Error_WithZeroPreliveAppId") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(0, LanguageSetting.DEFAULT, true)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                let actualErrors = response.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getMessage()
                let expectedErrors = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getErrors()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors))
            }
            
            //            it("Test_022_Error_WithInvalidLanguagePreliveApp"){
            //                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting(rawValue: "TEVN"))) as! GeneralSettings
            //            }
            
            // Xcode will show an error
            //            it("Test_023_Error_WithoutAppId"){
            //                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(nil, LanguageSetting.DEFAULT, true)) as! KintoneAPIException
            //            }
            
            it("Test_024_Error_WithNonExistentAppId") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(TestConstant.Common.NONEXISTENT_ID, LanguageSetting.DEFAULT, false)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let expectedCode = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                var expectedMessage = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()?.getMessage()
                expectedMessage = expectedMessage!.replacingOccurrences(of: "%VARIABLE", with: String(TestConstant.Common.NONEXISTENT_ID))
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
            }
            
            it("Test_025_Error_WithNegativeAppId") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(TestConstant.Common.NEGATIVE_ID, LanguageSetting.DEFAULT, false)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                let actualErrors = response.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getMessage()
                let expectedErrors = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getErrors()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors))
            }
            
            it("Test_026_Error_WithZeroAppId") {
                let response = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(0, LanguageSetting.DEFAULT, false)) as! KintoneAPIException
                
                let actualCode = response.getErrorResponse()?.getCode()
                let actualMessage = response.getErrorResponse()?.getMessage()
                let actualErrors = response.getErrorResponse()?.getErrors()
                let expectedCode = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getCode()
                let expectedMessage = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getMessage()
                let expectedErrors = KintoneErrorParser.NEGATIVE_APPID_ERROR()?.getErrors()
                
                expect(actualCode).to(equal(expectedCode))
                expect(actualMessage).to(equal(expectedMessage))
                expect(actualErrors).to(equal(expectedErrors))
            }
            
            //            it("Test_027_ErrorWithInvalidLanguage"){
            //                _ = TestCommonHandling.awaitAsync(appModule.getGeneralSettings(appId!, LanguageSetting(rawValue: "TEVN"), false)) as! GeneralSettings
            //            }
        }
    }
}
