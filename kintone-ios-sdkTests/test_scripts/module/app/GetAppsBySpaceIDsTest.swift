//
// kintone-ios-sdkTests
// Created on 6/6/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsBySpaceIDsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appName = DataRandomization.generateString(prefix: "App-GetAppsBySpaceIDs", length: 5)
        
        let spaceIds: [Int] = [TestConstant.InitData.SPACE_ID!, TestConstant.InitData.SPACE_2_ID!]
        let amountOfApps = 5
        var appIds: [Int] = []
        
        describe("GetAppsBySpaceIDs") {
            it("AddTestData_BeforeSuiteWorkaround") {
                for space in spaceIds {
                    let ids = AppUtils.createApps(appModule: appModule, appName: appName, spaceId: space, threadId: space, amount: amountOfApps)
                    appIds.append(contentsOf: ids)
                }
            }
            
            it("Test_052_Error_ApiToken") {
                let apiToken = AppUtils.generateApiToken(appModule, appIds[0])
                let tokenPermission  = TokenEntity(tokenString: apiToken, viewRecord: true, addRecord: true, editRecord: true, deleteRecord: true, editApp: true)
                AppUtils.updateTokenPermission(appModule: appModule, appId: appIds[0], token: tokenPermission)
                
                let appModule = App(TestCommonHandling.createConnection(apiToken))
                let getAppsRsp = TestCommonHandling.awaitAsync(appModule.getApps()) as! KintoneAPIException
                
                let actualError = getAppsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_053_Success") {
                let getAppsBySpaceIdsRsp = TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds)) as! [AppModel]
                
                expect(getAppsBySpaceIdsRsp.count).to(equal(appIds.count))
                for (index, app) in getAppsBySpaceIdsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(spaceIds.contains(app.getSpaceId()!)).to(beTrue())
                }
            }
            
            it("Test_054_Success_Limit") {
                let limit = 2
                let getAppsBySpaceIdsRsp = TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds, nil, limit)) as! [AppModel]
                
                expect(getAppsBySpaceIdsRsp.count).to(equal(limit))
                for (index, app) in getAppsBySpaceIdsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(spaceIds.contains(app.getSpaceId()!)).to(beTrue())
                    
                }
            }
            
            // // This test is commented out because it takes so much time for executing
            //        it("Test_056_Maximum100Apps") {
            //            var appIds100Apps = appIds!
            //            let appIds95Apps = AppUtils.createApps(appModule: app, appName: "Add100Apps", spaceId: spaceIds[0], threadId: spaceIds[0], amount: 100)
            //            appIds100Apps += appIds95Apps
            //            let getAppsBySpaceIDsRsp = TestCommonHandling.awaitAsync(app.getAppsBySpaceIDs(spaceIds)) as! [AppModel]
            //            expect(getAppsBySpaceIDsRsp.count).to(equal(100))
            //
            //            AppUtils.deleteApps(appIds: appIds95Apps)
            //        }
            
            it("Test_057_Error_LimitZero") {
                let limit = 0
                let getAppsBySpaceIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds, nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsBySpaceIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_058_Error_LimitGreaterThan100") {
                let limit = 101
                let getAppsBySpaceIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds, nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsBySpaceIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_059_Error_NegativeOffset") {
                let offset = -2
                let getAppsBySpaceIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds, offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsBySpaceIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_062_Error_OffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsBySpaceIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds, offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsBySpaceIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                AppUtils.deleteApps(appIds: appIds)
            }
        }
    }
}
