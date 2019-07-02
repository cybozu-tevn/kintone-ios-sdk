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
        
        describe("GetAppDeployStatus") {
            it("Test_079_Success") {
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(appIds!)) as! GetAppDeployStatusResponse
                for appDeployStatus in getAppDeployStatusRsp.getApps()! {
                    let appId = appDeployStatus.getApp()!
                    let getAppRsp = TestCommonHandling.awaitAsync(app.getApp(appId)) as! AppModel
                    expect(getAppRsp.getName()).to(contain(appName))
                    expect(appDeployStatus.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
                }
            }
            
            it("Test_079_Success_GuestSpace") {
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, TestConstant.InitData.GUEST_SPACE_ID!))
                
                let guestAppIds: [Int]? = AppUtils.createApps(appModule: guestAppModule, appName: appName, spaceId: TestConstant.InitData.GUEST_SPACE_ID, threadId: TestConstant.InitData.GUEST_SPACE_THREAD_ID, amount: amountOfApps)
                
                let getAppDeployeStatusRsp = TestCommonHandling.awaitAsync(guestAppModule.getAppDeployStatus(guestAppIds!)) as! GetAppDeployStatusResponse
                for appDeployStatus in getAppDeployeStatusRsp.getApps()! {
                    let appId = appDeployStatus.getApp()!
                    let getAppRsp = TestCommonHandling.awaitAsync(guestAppModule.getApp(appId)) as! AppModel
                    expect(getAppRsp.getName()).to(contain(appName))
                    expect(appDeployStatus.getStatus()).to(equal(AppDeployStatus.Status.SUCCESS))
                }
                AppUtils.deleteApps(appIds: guestAppIds!)
            }
            
            // This case is used so much time, if you want to execute it, please un-rem
            //            fit("Test_080_Maximum300Apps") {
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
            
            it("Test_081_Error_ApiToken") {
                let apiToken = AppUtils.generateApiToken(app, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appIds![0], token: tokenPermission)
                
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds!)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
            }
            
            it("Test_082_Error_WithoutAppId") {
                let apiToken = AppUtils.generateApiToken(app, appIds![0])
                let tokenPermission = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: app, appId: appIds![0], token: tokenPermission)
                
                let emptyArray = [Int]()
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(emptyArray)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), KintoneErrorParser.MISSING_APPS_ERROR()!)
            }
            
            it("Test_083_Error_NonExistentAppId") {
                let nonExistentAppIds = [TestConstant.Common.NONEXISTENT_ID]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(nonExistentAppIds)) as! KintoneAPIException
                var expectedErr = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()
                expectedErr?.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonExistentAppIds[0]))
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_084_Error_DuplicatedAppId") {
                let duplicateAppIds = [appIds![0], appIds![0]]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(duplicateAppIds)) as! KintoneAPIException
                var expectedErr = KintoneErrorParser.DUPLICATE_APP_ID_ERROR()
                expectedErr?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: String(1))
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_085_Error_NegativeAppId") {
                let negativeAppIds = [-1]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(negativeAppIds)) as! KintoneAPIException
                var expectedErr = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
                expectedErr?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "")
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_086_Error_ZeroAppId") {
                let negativeAppIds = [0]
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(negativeAppIds)) as! KintoneAPIException
                var expectedErr = KintoneErrorParser.NEGATIVE_APPS_ID_ERROR()
                expectedErr?.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "")
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_087_Error_MoreThan300AppIds") {
                let appIds = [Int](repeating: 1, count: 301)
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(app.getAppDeployStatus(appIds)) as! KintoneAPIException
                let expectedErr = KintoneErrorParser.MORE_THAN_300_APP_IDS()
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), expectedErr!)
            }
            
            it("Test_088_Error_WithoutPermission") {
                //                let entityAdmin = DevMemberEntity(DevMemberType.USER, TestConstant.Connection.ADMIN_USERNAME)
                //                let admin = SpaceMember(entityAdmin, true)
                //                var members = [SpaceMember]()
                //                members.append(admin)
                //                let spaceId = SpaceUtils.addSpace(idTemplate: 1, name: "TestPermission", members: members, isPrivate: false)
                //                let appId = AppUtils.createApp(appModule: app, appName: appName, spaceId: spaceId, threadId: spaceId)
                
                let appModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_USERNAME_WITHOUT_MANAGE_APP_PERMISSION, TestConstant.Connection.CRED_PASSWORD_WITHOUT_MANAGE_APP_PERMISSION))
                let getAppDeployStatusRsp = TestCommonHandling.awaitAsync(appModule.getAppDeployStatus(appIds!)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppDeployStatusRsp.getErrorResponse(), KintoneErrorParser.PERMISSION_ERROR()!)
            }
        }
    }
}
