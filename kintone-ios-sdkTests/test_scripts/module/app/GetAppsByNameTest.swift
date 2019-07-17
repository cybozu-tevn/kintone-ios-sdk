//
// kintone-ios-sdkTests
// Created on 5/10/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsByNameTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let appName = DataRandomization.generateString(prefix: "App-GetAppsByName", length: 5)
        let amountOfApps = 5
        var appIds: [Int] = []
        
        describe("GetAppsByName") {
            it("AddTestData_BeforeSuiteWorkaround") {
                appIds = AppUtils.createApps(appModule: appModule, appName: appName, spaceId: nil, threadId: nil, amount: amountOfApps)
            }
            
            it("Test_041_Success_Name") {
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(appModule.getAppsByName(appName)) as! [AppModel]
                
                expect(getAppsByNameRsp.count).to(equal(appIds.count))
                for (index, app) in getAppsByNameRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("Test_041_Success_Name_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceThreadId = TestConstant.InitData.GUEST_SPACE_THREAD_ID
                let guestSpaceAppName = DataRandomization.generateString(prefix: "App-GetAppsByName Guest space", length: 5)
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, guestSpaceId))
                let guestAppIds = AppUtils.createApps(appModule: guestAppModule, appName: guestSpaceAppName, spaceId: guestSpaceId, threadId: guestSpaceThreadId, amount: amountOfApps)
                
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(guestAppModule.getAppsByName(guestSpaceAppName)) as! [AppModel]
                
                expect(getAppsByNameRsp.count).to(equal(guestAppIds.count))
                for (index, app) in getAppsByNameRsp.enumerated() {
                    expect(app.getAppId()).to(equal(guestAppIds[index]))
                    expect(app.getName()).to(equal("\(guestSpaceAppName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(equal(guestSpaceId))
                    expect(app.getThreadId()).to(equal(guestSpaceThreadId))
                }
                
                AppUtils.deleteApps(appIds: guestAppIds)
            }
            
            it("Test_042_049_Success_Limit") {
                let limit = 2
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(appModule.getAppsByName(appName, nil, limit)) as! [AppModel]
                
                expect(getAppsByNameRsp.count).to(equal(limit))
                for (index, app) in getAppsByNameRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal("\(appName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("Test_043_Success_Offset") {
                let offset = 2
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(appModule.getAppsByName(appName, offset, nil)) as! [AppModel]
                
                expect(getAppsByNameRsp.count).to(equal(appIds.count - offset))
                for (index, app) in getAppsByNameRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index + offset]))
                    expect(app.getName()).to(equal("\(appName)\(index + offset)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            //            // This test is commented out because it takes so much time for executing
            //            it("Test_044_Success_Maximum100Apps") {
            //                // Prepare Apps
            //                let appName = "App - get 100 apps by app name"
            //                let appIds100 = AppUtils.createApps(appModule: appModule, appName: appName, spaceId: nil, threadId: nil, amount: 100)
            //                let getAppsByNameRsp = TestCommonHandling.awaitAsync(appModule.getAppsByName(appName)) as! [AppModel]
            //
            //                expect(getAppsByNameRsp.count).to(equal(appIds100.count))
            //                for(index, app) in getAppsByNameRsp.enumerated() {
            //                    expect(app.getAppId()).to(equal(appIds100[index]))
            //                }
            //
            //                AppUtils.deleteApps(appIds: appIds100)
            //            }
            
            it("Test_045_Error_LimitZero") {
                let limit = 0
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(appModule.getAppsByName(appName, nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsByNameRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_046_Error_LimitGreaterThan100") {
                let limit = 101
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(appModule.getAppsByName(appName, nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsByNameRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_047_Error_NegativeOffset") {
                let offset = -2
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(appModule.getAppsByName(appName, offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsByNameRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_050_Error_OffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(appModule.getAppsByName(appName, offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsByNameRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                AppUtils.deleteApps(appIds: appIds)
            }
        }
    }
}
