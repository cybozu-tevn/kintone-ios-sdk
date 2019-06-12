///**
/**
 kintone-ios-sdkTests
 Created on 5/10/19
 */

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppDeployStatusTest: QuickSpec {
    override func spec() {
        let app = App(TestCommonHandling.createConnection())
        let appName = "App Name"
        let amountOfApps = 5
        var appIds: [Int]?
        
        beforeSuite {
            print("=== TEST PREPARATION ===")
            appIds = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
        }
        
        afterSuite {
            print("=== TEST CLEANING UP ===")
            AppUtils.deleteApps(appIds: appIds!)
        }
        
        describe("GetAppDeployStatusTest") {
            it("Test_079_Success") {
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(appIds!)) as! GetAppDeployStatusResponse
                for appDeployStatus in getAppDeployStatusRsp.getApps()! {
                    let appId = appDeployStatus.getApp()!
                    let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(appId)) as! AppModel
                    expect(getAppRsp.getName()).to(contain(appName))
                    expect(appDeployStatus.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
                }
            }
            
            fit("Test_079_Success_GuestSpaceApp") {
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD, TestConstant.Connection.GUEST_SPACE_ID))
                
                let guestAppIds: [Int]? = AppUtils.createApps(appModule: guestAppModule, appName: appName, spaceId: TestConstant.Common.GUEST_SPACE_ID, threadId: TestConstant.Common.GUEST_SPACE_THREAD_ID, amount: amountOfApps)
                
                let getAppDeployeStatusRsp = TestCommonHandling.awaitAsync(guestAppModule.getAppDeployStatus(guestAppIds!)) as! GetAppDeployStatusResponse
                for appDeployStatus in getAppDeployeStatusRsp.getApps()! {
                    let appId = appDeployStatus.getApp()!
                    let getAppRsp = TestCommonHandling.awaitAsync(guestAppModule.getApp(appId)) as! AppModel
                    expect(getAppRsp.getName()).to(contain(appName))
                    expect(appDeployStatus.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
                }
                AppUtils.deleteApps(appIds: guestAppIds!)
            }
            
            // TODO: Unstable when running this test with home network which connects to Cybozu via VPN. need to be rerun with campus network
            // This case is used so much time, if you want to execute it, please un-rem
            //            it("Test_080_Maximum300Apps") {
            //                let appIds = AppUtils.createApps(appModule: app, appName: appName, spaceId: nil, threadId: nil, amount: 300)
            //                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(appIds)) as! GetAppDeployStatusResponse
            //                expect(getAppDeployStatusRsp.getApps()?.count).to(equal(appIds.count))
            //                for appDeployStt in getAppDeployStatusRsp.getApps()! {
            //                    expect(appDeployStt.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
            //                    let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(appDeployStt.getApp()!)) as! AppModel
            //                    expect(getAppRsp.getName()).to(contain(appName))
            //                }
            //                AppUtils.deleteApps(appIds: appIds)
            //            }
            
            it("Test_081_FailedWithApiToken") {
                let apiToken = AppUtils.generateApiToken(app, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appIds![0], token: tokenPermission)
                
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds!)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
            }
            
            it("Test_082_FailedWithoutAppId") {
                let apiToken = AppUtils.generateApiToken(app, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appIds![0], token: tokenPermission)
                
                let emptyArray = [Int]()
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(emptyArray)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), KintoneErrorParser.MISSING_APPS_ERROR()!)
            }
            
            it("Test_083_FailedWithNonExistentAppId") {
                let nonExistentAppIds = [TestConstant.Common.NONEXISTENT_ID]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(nonExistentAppIds)) as! KintoneAPIException
                var expectedErr = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()
                expectedErr?.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonExistentAppIds[0]))
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_084_FailedWithDuplicatedAppId") {
                let duplicateAppIds = [appIds![0], appIds![0]]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(duplicateAppIds)) as! KintoneAPIException
                var expectedErr = KintoneErrorParser.DUPLICATE_APP_ID_ERROR()
                expectedErr?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(1))
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_085_FailedWithNegativeAppId") {
                let negativeAppIds = [-1]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(negativeAppIds)) as! KintoneAPIException
                var expectedErr = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
                expectedErr?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "")
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_086_FailedWithZeroAppId") {
                let negativeAppIds = [0]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(negativeAppIds)) as! KintoneAPIException
                var expectedErr = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
                expectedErr?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "")
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_087_FailedWithMoreThan300AppIds") {
                let appIds = [Int](repeating: 1, count: 301)
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(appIds)) as! KintoneAPIException
                let expectedErr = KintoneErrorParser.MORE_THAN_300_APP_IDS()
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_088_FailedWithoutPermission") {
                // TODO: implement this test.
            }
        }
    }
}
