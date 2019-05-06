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

class GetApp: QuickSpec{
    override func spec(){
        let app = App(TestCommonHandling.createConnection())
        
        describe("GetApp"){
            it("Success Case"){
                //                var testAppID: Int?
                //                app.addPreviewApp("Preview App mob 1").then { response in
                //                    testAppID = response.getApp()
                //                    app.deployAppSettings(response)
                //                    }.then{ tmp in
                //
                //                }.catch{error in
                //                        XCTFail(TestCommonHandling.getErrorMessage(error))
                //                }
                //                XCTAssert(waitForPromises(timeout: 30))
                //
                //                app.deployAppSettings([response])
                //                app.getApp(testAppID!)
                //
                //
                //
                //                app.getApp(testAppID!).then{ appResponse in
                //                    print(appResponse.getAppId()!)
                //                    expect(appResponse.getAppId()).to(equal(testAppID))
                //                    }.catch{ error in
                //                        XCTFail(TestCommonHandling.getErrorMessage(error))
                //                }
                //                XCTAssert(waitForPromises(timeout: 10))
            }
        }
    }
}
