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
        let spaceIds: [Int] = [TestConstant.InitData.SPACE_ID!, TestConstant.InitData.SPACE_2_ID!]
        let expectedAppIds: [Int] = [TestConstant.InitData.SPACE_APP_ID!, TestConstant.InitData.SPACE_2_APP_ID!]
        
        describe("GetAppsBySpaceIDs") {
            it("Test_052_Error_ApiToken") {
                // Api token of app in space
                let apiToken = TestConstant.InitData.APP_API_TOKEN
                let appModuleApiToken = App(TestCommonHandling.createConnection(apiToken))
                let getAppsBySpaceIdsRsp = TestCommonHandling.awaitAsync(appModuleApiToken.getAppsBySpaceIDs(spaceIds)) as! KintoneAPIException
                
                let actualError = getAppsBySpaceIdsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_053_Success") {
                // Get total apps in spaces
                var totalAppInSpace = 0
                var totalApps: Int = 0
                repeat {
                    totalApps = (TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds, totalAppInSpace)) as! [AppModel]).count
                    totalAppInSpace += totalApps
                } while (totalApps == 100)
                
                let getAppsBySpaceIdsRsp = TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds)) as! [AppModel]

                expect(getAppsBySpaceIdsRsp.count).to(equal(totalAppInSpace))
            }
            
            it("Test_054_Success_Limit") {
                let limit = 2
                let getExpectedAppRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(expectedAppIds)) as! [AppModel]
                var appsExpected: [AppModel] = []
                for (_, app) in getExpectedAppRsp.enumerated() {
                    appsExpected.append(app)
                }
                let getAppsBySpaceIdsRsp = TestCommonHandling.awaitAsync(appModule.getAppsBySpaceIDs(spaceIds, nil, limit)) as! [AppModel]
                
                expect(getAppsBySpaceIdsRsp.count).to(equal(limit))
                for (index, app) in getAppsBySpaceIdsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appsExpected[index].getAppId()))
                    expect(app.getName()).to(equal(appsExpected[index].getName()))
                    expect(app.getCode()).to(equal(appsExpected[index].getCode()))
                    expect(app.getCreator()?.getName()).to(equal(appsExpected[index].getCreator()?.getName()))
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
        }
    }
}
