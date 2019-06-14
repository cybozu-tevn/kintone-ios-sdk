///**
/**
 kintone-ios-sdkTests
 Created on 6/13/19
 */

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class AddPreviewAppTest: QuickSpec {
    override func spec() {
        describe("AddPreviewAppTest") {
            let app = App(TestCommonHandling.createConnection())
            let appName = "App Name"
            var appIds = [Int]()
            
            afterSuite {
                AppUtils.deleteApps(appIds: appIds)
            }
            
            it("Test_089_SuccessWithSpaceThread") {
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(appName, TestConstant.Connection.SPACE_ID, TestConstant.Connection.SPACE_ID)) as! PreviewApp
                expect(addPreviewAppRsp.getApp()).notTo(beNil())
                expect(addPreviewAppRsp.getRevision()).notTo(beNil())
                appIds.append(addPreviewAppRsp.getApp()!)
                
                AppUtils._deployApp(appModule: app, apps: [addPreviewAppRsp])
                let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(addPreviewAppRsp.getApp()!)) as! AppModel
                expect(getAppRsp.getName()).to(equal(appName))
            }
            
            it("Test_089_SuccessWithSpaceThread_GuestSpaceApp") {
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD, TestConstant.Connection.GUEST_SPACE_ID))
                
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(guestAppModule.addPreviewApp(appName, TestConstant.Connection.GUEST_SPACE_ID, TestConstant.Connection.GUEST_SPACE_ID)) as! PreviewApp
                expect(addPreviewAppRsp.getApp()).notTo(beNil())
                expect(addPreviewAppRsp.getRevision()).notTo(beNil())
                appIds.append(addPreviewAppRsp.getApp()!)
                
                AppUtils._deployApp(appModule: guestAppModule, apps: [addPreviewAppRsp])
                let getAppRsp = TestCommonHandling.awaitAsync(guestAppModule.getApp(addPreviewAppRsp.getApp()!)) as! AppModel
                expect(getAppRsp.getName()).to(equal(appName))
            }
            
            it("Test_090_SuccessWithoutSpaceThread") {
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(appName)) as! PreviewApp
                expect(addPreviewAppRsp.getApp()).notTo(beNil())
                expect(addPreviewAppRsp.getRevision()).notTo(beNil())
                appIds.append(addPreviewAppRsp.getApp()!)
                
                AppUtils._deployApp(appModule: app, apps: [addPreviewAppRsp])
                let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(addPreviewAppRsp.getApp()!)) as! AppModel
                expect(getAppRsp.getName()).to(equal(appName))
            }
            
            it("Test_092_FailedWithApiToken") {
                let appId = AppUtils.createApp(appModule: app)
                appIds.append(appId)
                let apiToken = AppUtils.generateApiToken(app, appId)
                let appModuleApiToken = App(TestCommonHandling.createConnection(apiToken))
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(appModuleApiToken.addPreviewApp(appName)) as! KintoneAPIException
                TestCommonHandling.compareError(addPreviewAppRsp.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
            }
            
            // Xcode will catch this error
            //            fit("Test_093_FailedWithoutAppName") {
            //                let result = TestCommonHandling.awaitAsync(app.addPreviewApp()) as! KintoneAPIException
            //            }
            
            it("Test_094_FailedWithMoreThan64CharsAppName") {
                let invalidAppName = DataRandomization.generateString(length: 65)
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(invalidAppName)) as! KintoneAPIException
                TestCommonHandling.compareError(addPreviewAppRsp.getErrorResponse(), KintoneErrorParser.NAME_LARGER_THAN_64_CHARACTERS_ERROR()!)
            }
            
            it("Test_095_FailedWithoutSpaceId") {
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(appName, nil, TestConstant.Connection.SPACE_ID)) as! KintoneAPIException
                TestCommonHandling.compareError(addPreviewAppRsp.getErrorResponse(), KintoneErrorParser.MISSING_SPACE_ERROR()!)
            }
            
            it("Test_096_FailedWithNonExistentSpaceId") {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(appName, TestConstant.Common.MAX_VALUE, TestConstant.Connection.SPACE_ID)) as! KintoneAPIException
                var expectedResult = KintoneErrorParser.NONEXISTENT_SPACE_ERROR()!
                expectedResult.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: formatter.string(for: TestConstant.Common.MAX_VALUE)!)
                TestCommonHandling.compareError(addPreviewAppRsp.getErrorResponse(), expectedResult)
            }
            
            it("Test_097_FailedWithNegativeSpaceId") {
                let addPreViewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(appName, -1, TestConstant.Connection.SPACE_ID)) as! KintoneAPIException
                TestCommonHandling.compareError(addPreViewAppRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_SPACE_ERROR()!)
            }
            
            it("Test_098_FailedWithoutThreadId(") {
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(appName, TestConstant.Connection.SPACE_ID, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(addPreviewAppRsp.getErrorResponse(), KintoneErrorParser.MISSING_THREAD_ERROR()!)
            }
            
            it("Test_099_FailedWithNonExistentThreadId") {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(appName, TestConstant.Connection.SPACE_ID, TestConstant.Common.MAX_VALUE)) as! KintoneAPIException
                var expectedResult = KintoneErrorParser.NONEXISTENT_THREAD_ERROR()!
                expectedResult.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: formatter.string(for: TestConstant.Common.MAX_VALUE)!)
                TestCommonHandling.compareError(addPreviewAppRsp.getErrorResponse(), expectedResult)
            }
            
            it("Test_100_FailedWithNegativeThreadId") {
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(app.addPreviewApp(appName, TestConstant.Common.SPACE_ID, -1)) as! KintoneAPIException
                TestCommonHandling.compareError(addPreviewAppRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_THREAD_ERROR()!)
            }
            
            // This case needs to setup a user with no previledge to create app
            // kintone Administration > Permission Management > Add the user which you want to deal with
            it("Test_101_FailedWithoutPermission") {
                let appModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let addPreviewAppRsp = TestCommonHandling.awaitAsync(appModule.addPreviewApp(appName)) as! KintoneAPIException
                TestCommonHandling.compareError(addPreviewAppRsp.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
            }
        }
    }
}
