//
// kintone-ios-sdkTests
// Created on 5/10/19
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppsByIDsTest: QuickSpec {
    override func spec() {
        let appModule = App(TestCommonHandling.createConnection())
        let apps = TestConstant.InitData.APPS_TEST_GET_APPS
        let appIds: [Int] = [Int(apps[0].appId)!, Int(apps[1].appId)!, Int(apps[2].appId)!, Int(apps[3].appId)!, Int(apps[4].appId)!]
        
        describe("GetAppsByIDs") {
            it("Test_018_Error_ApiToken") {
                let appModuleApiToken = App(TestCommonHandling.createConnection(apps[0].apiToken.fullPermission))
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModuleApiToken.getAppsByIDs(appIds)) as! KintoneAPIException
                
                let actualError = getAppsByIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_019_Success") {
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds)) as! [AppModel]
                
                expect(getAppsByIDsRsp.count).to(equal(appIds.count))
                for (index, app) in getAppsByIDsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal(apps[index].name))
                    expect(app.getCode()).to(equal(apps[index].code))
                    expect(app.getDescription()).to(equal(apps[index].description))
                    expect(app.getCreator()?.getName()).to(equal(apps[index].creator.name))
                    if (apps[index].spaceId != "") {
                        expect(app.getSpaceId()).to(equal(Int(apps[index].spaceId)))
                        expect(app.getThreadId()).to(equal(Int(apps[index].threadId)))
                    } else {
                        expect(app.getSpaceId()).to(beNil())
                        expect(app.getThreadId()).to(beNil())
                    }
                }
            }
            
            it("Test_019_Success_GuestSpace") {
                // Prepare Apps for guest space
                let amountOfApps = 5
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceThreadId = TestConstant.InitData.GUEST_SPACE_THREAD_ID
                let guestSpaceAppName = DataRandomization.generateString(prefix: "App-GetAppsByIDs Guest space", length: 5)
                let guestAppModule = App(TestCommonHandling.createConnection(TestConstant.Connection.CRED_ADMIN_USERNAME, TestConstant.Connection.CRED_ADMIN_PASSWORD, guestSpaceId))
                let guestAppIds: [Int] = AppUtils.createApps(appModule: guestAppModule, appName: guestSpaceAppName, spaceId: guestSpaceId, threadId: guestSpaceThreadId, amount: amountOfApps)
                
                // Verify getting Apps by App code
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(guestAppModule.getAppsByIDs(guestAppIds)) as! [AppModel]
                
                expect(getAppsByIDsRsp.count).to(equal(guestAppIds.count))
                for (index, app) in getAppsByIDsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(guestAppIds[index]))
                    expect(app.getName()).to(equal("\(guestSpaceAppName)\(index)"))
                    expect(app.getCode()).to(equal(""))
                    expect(app.getCreator()!.getName()).to(equal(TestConstant.Connection.CRED_ADMIN_USERNAME))
                    expect(app.getSpaceId()).to(equal(guestSpaceId))
                    expect(app.getThreadId()).to(equal(guestSpaceThreadId))
                }
                
                AppUtils.deleteApps(appIds: guestAppIds)
            }
            
            it("Test_020_027_Susscess_Limit") {
                let limit = 2
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds, nil, limit)) as! [AppModel]
                
                expect(getAppsByIDsRsp.count).to(equal(limit))
                for(index, app) in getAppsByIDsRsp.enumerated() {
                    expect(app.getAppId()).to(equal(appIds[index]))
                    expect(app.getName()).to(equal(apps[index].name))
                    expect(app.getCode()).to(equal(apps[index].code))
                    expect(app.getDescription()).to(equal(apps[index].description))
                    expect(app.getCreator()?.getName()).to(equal(apps[index].creator.name))
                    if (apps[index].spaceId != "") {
                        expect(app.getSpaceId()).to(equal(Int(apps[index].spaceId)))
                        expect(app.getThreadId()).to(equal(Int(apps[index].threadId)))
                    } else {
                        expect(app.getSpaceId()).to(beNil())
                        expect(app.getThreadId()).to(beNil())
                    }
                }
            }
            
            it("Test_021_Success_Offset") {
                let offset = 2
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds, offset, nil)) as! [AppModel]
                
                expect(getAppsByIDsRsp.count).to(equal(appIds.count - offset))
                for(index, app) in getAppsByIDsRsp.enumerated() {
                    let appIndex = index + offset
                    expect(app.getAppId()).to(equal(appIds[appIndex]))
                    expect(app.getName()).to(equal(apps[appIndex].name))
                    expect(app.getCode()).to(equal(apps[appIndex].code))
                    expect(app.getDescription()).to(equal(apps[appIndex].description))
                    expect(app.getCreator()?.getName()).to(equal(apps[appIndex].creator.name))
                    if (apps[appIndex].spaceId != "") {
                        expect(app.getSpaceId()).to(equal(Int(apps[appIndex].spaceId)))
                        expect(app.getThreadId()).to(equal(Int(apps[appIndex].threadId)))
                    } else {
                        expect(app.getSpaceId()).to(beNil())
                        expect(app.getThreadId()).to(beNil())
                    }
                }
            }
            
            it("Test_023_Error_LimitZero") {
                let limit = 0
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds, nil, limit)) as! KintoneAPIException
                
                let actualError = getAppsByIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_LIMIT_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_024_Error_LimitGreaterThan100") {
                let limit = 101
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds, nil, limit)) as!KintoneAPIException
                
                let actualError = getAppsByIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_100_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_025_Error_NegativeOffset") {
                let offset = -1
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds, offset, nil)) as! KintoneAPIException
                
                let actualError = getAppsByIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_028_Error_OffsetExceedValue") {
                let offset = TestConstant.Common.MAX_VALUE + 1
                let getAppsByIDsRsp = TestCommonHandling.awaitAsync(appModule.getAppsByIDs(appIds, offset, nil)) as!KintoneAPIException
                
                let actualError = getAppsByIDsRsp.getErrorResponse()
                let expectedError = KintoneErrorParser.OFFSET_LARGER_THAN_2147483647_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}
