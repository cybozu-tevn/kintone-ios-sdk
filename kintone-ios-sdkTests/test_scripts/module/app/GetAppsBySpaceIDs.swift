//
// kintone-ios-sdkTests
// Created on 6/6/19
// 

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsBySpaceIDs: QuickSpec {
    override func spec() {
        let app = App(TestCommonHandling.createConnection())
        let appName = "App Name"
        
        // TODO: need to use dynamic spaceIds
        let spaceIds: [Int] = [TestConstant.InitData.SPACE_ID!, TestConstant.InitData.SPACE_2_ID!]
        let amountOfApps = 5
        var appIds: [Int]? = []
        
        beforeSuite {
            print("=== TEST PREPARATION ===")
            for space in spaceIds {
                let tmp = AppUtils.createApps(appModule: app, appName: appName, spaceId: space, threadId: space, amount: amountOfApps)
                appIds?.append(contentsOf: tmp)
            }
        }
        
        afterSuite {
            print("=== TEST CLEANING UP ===")
            AppUtils.deleteApps(appIds: appIds!)
        }
        
        it("Test_052_FailedWithApiToken") {
            let apiToken = AppUtils.generateApiToken(app, appIds![0])
            let tokenPermission  = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
            AppUtils.updateTokenPermission(appModule: app, appId: appIds![0], token: tokenPermission)
            
            let appModule = App(TestCommonHandling.createConnection(apiToken))
            let getAppsRsp = TestCommonHandling.awaitAsync(appModule.getApps()) as! KintoneAPIException
            TestCommonHandling.compareError(getAppsRsp.getErrorResponse(), KintoneErrorParser.API_TOKEN_ERROR()!)
        }
        
        it("Test_053_Success") {
            let getAppsBySpaceIdsRsp = TestCommonHandling.awaitAsync(app.getAppsBySpaceIDs(spaceIds)) as! [AppModel]
            expect(getAppsBySpaceIdsRsp.count).to(equal(appIds?.count))
            for (index, app) in getAppsBySpaceIdsRsp.enumerated() {
                expect(app.getAppId()).to(equal(appIds![index]))
                expect(app.getName()).to(contain(appName))
                expect(app.getCode()).to(equal(""))
                expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                expect(spaceIds.contains(app.getSpaceId()!)).to(beTrue())
                //                expect(app.getThreadId()).to(beNil())
            }
        }
        
        it("Test_054_SuccessWithLimit") {
            let limit = 2
            let getAppsBySpaceIdsRsp = TestCommonHandling.awaitAsync(app.getAppsBySpaceIDs(spaceIds, nil, limit)) as! [AppModel]
            expect(getAppsBySpaceIdsRsp.count).to(equal(limit))
            for (index, app) in getAppsBySpaceIdsRsp.enumerated() {
                expect(app.getAppId()).to(equal(appIds![index]))
                expect(app.getName()).to(contain(appName))
                expect(app.getCode()).to(equal(""))
                expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                expect(spaceIds.contains(app.getSpaceId()!)).to(beTrue())
                //                expect(app.getThreadId()).to(beNil())
            }
        }
        
        //This case is used so much time, if you want to execute it, please un-rem
        //        it("Test_056_Maximum100Apps") {
        //            var appIds100Apps = appIds!
        //            let appIds95Apps = AppUtils.createApps(appModule: app, appName: "Add100Apps", spaceId: spaceIds[0], threadId: spaceIds[0], amount: 100)
        //            appIds100Apps += appIds95Apps
        //            let getAppsBySpaceIDsRsp = TestCommonHandling.awaitAsync(app.getAppsBySpaceIDs(spaceIds)) as! [AppModel]
        //            expect(getAppsBySpaceIDsRsp.count).to(equal(100))
        //            AppUtils.deleteApps(appIds: appIds95Apps)
        //        }
        
        it("Test_057_FailedWithLimitZero") {
            let limit = 0
            let getAppsBySpaceIDs = TestCommonHandling.awaitAsync(app.getAppsBySpaceIDs(spaceIds, nil, limit)) as! KintoneAPIException
            TestCommonHandling.compareError(getAppsBySpaceIDs.getErrorResponse(), KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!)
        }
        
        it("Test_058_FailedWithLimitGreaterThan100") {
            let limit = 101
            let getAppsBySpaceIDs = TestCommonHandling.awaitAsync(app.getAppsBySpaceIDs(spaceIds, nil, limit)) as! KintoneAPIException
            TestCommonHandling.compareError(getAppsBySpaceIDs.getErrorResponse(), KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!)
        }
        
        it("Test_059_FailedWithNegativeOffset") {
            let offset = -2
            let getAppsBySpaceIDs = TestCommonHandling.awaitAsync(app.getAppsBySpaceIDs(spaceIds, offset, nil)) as! KintoneAPIException
            TestCommonHandling.compareError(getAppsBySpaceIDs.getErrorResponse(), KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!)
        }
        
        it("Test_062_FailedWithOffsetExceedValue") {
            let offset = TestConstant.Common.MAX_VALUE + 1
            let getAppsBySpaceIDs = TestCommonHandling.awaitAsync(app.getAppsBySpaceIDs(spaceIds, offset, nil)) as! KintoneAPIException
            TestCommonHandling.compareError(getAppsBySpaceIDs.getErrorResponse(), KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!)
        }
    }
}
