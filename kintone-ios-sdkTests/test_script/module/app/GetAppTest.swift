//
//  GetApp.swift
//  kintone-ios-sdkTests
//
//  Created by Vu Tran on 5/6/19.
//  Copyright © 2019 Cybozu. All rights reserved.
//

import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetAppTest: QuickSpec{
    override func spec(){
        let app = App(TestCommonHandling.createConnection())
        var appId: Int?
        
        describe("GetAppTest"){
            
            beforeSuite {
                print("=== TEST PREPARATION ===")
                appId = AppUtils.createApp(appModule: app)
            }
            
            afterSuite {
                
            }
            
            it("Success Case"){
                
                app.getApp(appId!).then{ appResponse in
                    // print(appResponse.getAppId()!)
                    expect(appResponse.getAppId()).to(equal(appId))
                    }.catch{ error in
                        XCTFail(TestCommonHandling.getErrorMessage(error))
                }
                _ = waitForPromises(timeout: TestsConstants.WAIT_FOR_PROMISE_TIMEOUT)
            }
        }
    }
}
