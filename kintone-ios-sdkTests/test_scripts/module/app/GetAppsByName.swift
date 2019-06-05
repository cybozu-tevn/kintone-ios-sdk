///**
/**
 kintone-ios-sdkTests
 Created on 5/10/19
 */

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsByNameTest: QuickSpec {
    override func spec() {
        let app = App(TestCommonHandling.createConnection())
        let appName = DataRandomization.generateString(prefix: "GetAppsByName", length: 16)
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
        
        describe("GetAppsByName") {
            it("Test_041_SuccessWithName") {
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(app.getAppsByName(appName)) as! [AppModel]
                expect(getAppsByNameRsp.count).to(equal(appIds?.count))
                for app in getAppsByNameRsp {
                    expect(app.getName()!).to(contain(appName))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("Test_041_SuccessWithName_GuestSpaceApp") {
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD, TestConstant.Connection.GUEST_SPACE_ID))
                let guestAppIds = AppUtils.createApps(appModule: guestAppModule, appName: appName, spaceId: TestConstant.Connection.GUEST_SPACE_ID, threadId: TestConstant.Connection.GUEST_THREAD_ID, amount: amountOfApps)
                
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(guestAppModule.getAppsByName(appName)) as! [AppModel]
                expect(getAppsByNameRsp.count).to(equal(guestAppIds.count))
                for app in getAppsByNameRsp {
                    expect(app.getName()!).to(contain(appName))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(equal(TestConstant.Connection.GUEST_SPACE_ID))
                    expect(app.getThreadId()).to(equal(TestConstant.Connection.GUEST_THREAD_ID))
                }
            }
            
            it("Test_42_49_SuccessWithLimit") {
                let limit = 2
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(app.getAppsByName(appName, nil, limit)) as! [AppModel]
                expect(getAppsByNameRsp.count).to(equal(limit))
                for app in getAppsByNameRsp {
                    expect(app.getName()!).to(contain(appName))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            it("Test_43_SuccessWithOffset") {
                let offset = 2
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(app.getAppsByName(appName, offset, nil)) as! [AppModel]
                expect(getAppsByNameRsp.count).to(equal(appIds!.count - offset))
                for app in getAppsByNameRsp {
                    expect(app.getName()!).to(contain(appName))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()?.getName()).to(equal(TestConstant.Connection.ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(beNil())
                    expect(app.getThreadId()).to(beNil())
                }
            }
            
            // This case is used so much time, if you want to execute it, please un-rem
            //    func test_44_GetAppsByName_Maximum100Apps(){
            //        let appIds100Apps = AppFunctions.createApps(appModule: this.commonModule.appModule, appName: "Add100Apps", spaceId: Constants.SPACE_ID, threadId: Constants.THREAD_ID, amount: 100)
            //        let getAppsResponse = CommonFunctions.awaitAsync(this.commonModule.appModule.getAppsByName("Add100Apps")) as! [AppModel]
            //        XCTAssert(getAppsResponse.count == 100)
            //        for (index, app) in getAppsResponse.enumerated() {
            //            XCTAssertEqual(appIds100Apps[index], app.getAppId())
            //        }
            //        AppFunctions.deleteApps(appIds: appIds100Apps)
            //    }
            
            it("Test_45_FailedWithLimitZero") {
                let limit = 0
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(app.getAppsByName(appName, nil, limit)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByNameRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!)
            }
            
            it("Test_46_FailedWithLimitGreaterThan100") {
                let limit = 101
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(app.getAppsByName(appName, nil, limit)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByNameRsp.getErrorResponse(), KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!)
            }
            
            it("Test_47_FailedWithNegativeOffset") {
                let offset = -2
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(app.getAppsByName(appName, offset, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByNameRsp.getErrorResponse(), KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!)
            }
            
            it("Test_50_FailedWithOffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsByNameRsp = TestCommonHandling.awaitAsync(app.getAppsByName(appName, offset, nil)) as! KintoneAPIException
                TestCommonHandling.compareError(getAppsByNameRsp.getErrorResponse(), KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!)
            }
        }
    }
}
