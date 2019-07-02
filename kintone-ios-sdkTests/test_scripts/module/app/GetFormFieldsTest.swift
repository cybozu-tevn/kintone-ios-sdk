//
// kintone-ios-sdkTests
// Created on 6/20/19
//

import Foundation
import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetFormFieldsTest: QuickSpec {
    override func spec() {
        let APP_ID = TestConstant.InitData.APP_ID!
        let appModule = App(TestCommonHandling.createConnection())
        
        describe("GetFormFields") {
            it("Test_003_FailedWithApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(TestConstant.InitData.APP_API_TOKEN))
                let result = TestCommonHandling.awaitAsync(appModuleApiToken.getFormFields(APP_ID, LanguageSetting.DEFAULT, false)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_004_Success") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT, false)) as! FormFields
                expect(result.getProperties()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())

                var actualResult: [String] = []
                for (_, value) in result.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(TestConstant.InitData.FIELD_CODES))
            }
            
            it("Test_005_GuestSpaceApp_Success_WithIsPreviewTrue") {
                let appModuleGuestSpace = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    TestConstant.InitData.GUEST_SPACE_ID!))
                let result = TestCommonHandling.awaitAsync(appModuleGuestSpace.getFormFields(TestConstant.InitData.GUEST_SPACE_APP_ID!, LanguageSetting.DEFAULT, true)) as! FormFields
                expect(result.getProperties()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
                
                var actualResult: [String] = []
                for (_, value) in result.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(TestConstant.InitData.FIELD_CODES))
            }
            
            it("Test_7_Success_DefaultLanguage") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                expect(result.getProperties()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
                
                var actualResult: [String] = []
                for (_, value) in result.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(TestConstant.InitData.FIELD_CODES))
            }
            
            it("Test_008_Success_WithIsPreviewTrue") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT, true)) as! FormFields
                expect(result.getProperties()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
                
                var actualResult: [String] = []
                for (_, value) in result.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(TestConstant.InitData.FIELD_CODES))
            }
            
            it("Test_009_Success_WithIsPreviewFalse") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormFields(APP_ID, LanguageSetting.DEFAULT, false)) as! FormFields
                expect(result.getProperties()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
                
                var actualResult: [String] = []
                for (_, value) in result.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(TestConstant.InitData.FIELD_CODES))
            }
            
            it("Test_010_FailedWithInvalidAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormFields(TestConstant.Common.NEGATIVE_ID, LanguageSetting.DEFAULT, false)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_010_FailedWithNonExistentAppId") {
                let result = TestCommonHandling.awaitAsync(appModule.getFormFields(TestConstant.Common.NONEXISTENT_ID, LanguageSetting.DEFAULT, false)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            // the user who don't have Manage Permission can get info, the same result with Postman
            it("Test_013_Success_WithPermissionDenied") {
                let appModuleWithoutAppPermisstion = App(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(appModuleWithoutAppPermisstion.getFormFields(APP_ID, LanguageSetting.DEFAULT)) as! FormFields
                expect(result.getProperties()).toNot(beNil())
                expect(result.getRevision()).toNot(beNil())
                
                var actualResult: [String] = []
                for (_, value) in result.getProperties()! {
                    actualResult.append(value.getCode())
                }
                expect(actualResult).to(contain(TestConstant.InitData.FIELD_CODES))
            }
        }
    }
}
