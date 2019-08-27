//
// kintone-ios-sdkTests
// Created on 8/19/19
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class CreateCursorTest: QuickSpec {
    override func spec() {
        let appId = TestConstant.InitData.SPACE_APP_ID!
        let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
        let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let queryOfCursor = "Created_by in (LOGINUSER()) and Created_datetime = TODAY() order by $id asc"
        var recordIds = [Int]()
        var guestSpaceRecordIds = [Int]()
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let guestSpaceRecordModule = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            guestSpaceId))
        let cursorModule = Cursor(TestCommonHandling.createConnection())
        let guestSpaceCursorModule = Cursor(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            guestSpaceId))
        
        describe("CreateCursor") {
            it("AddTestData_BeforeSuiteWorkaround") {
                recordIds = RecordUtils.addRecords(recordModule, appId, 500, textField)
                guestSpaceRecordIds = RecordUtils.addRecords(guestSpaceRecordModule, guestSpaceAppId, 500, textField)
            }
            
            it("Test_010_Success_ValidRequest_FullOptions") {
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, 1)) as! CreateRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addCursorRsp.getId()))
            }
            
            it("Test_011_Success_ValidRequest_DefaultSizeIs100") {
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, nil)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                expect(getRecordCursorRsp.getRecords().count).to(equal(100))
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_012_Success_ValidRequest_SizeIs500") {
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, 500)) as! CreateRecordCursorResponse
                let cursorId = addCursorRsp.getId()
                let getRecordCursorRsp = TestCommonHandling.awaitAsync(cursorModule.getRecords(cursorId)) as! GetRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                expect(getRecordCursorRsp.getRecords().count).to(equal(500))

                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorId))
            }
            
            it("Test_013_Error_InvalidAppId") {
                let noneExistentAppId = TestConstant.Common.NONEXISTENT_ID
                let negativeAppId = TestConstant.Common.NEGATIVE_ID
                let zeroAppId = 0
                
                // create cursor with unexisted app id
                var addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(noneExistentAppId, [textField], queryOfCursor, 500)) as! KintoneAPIException
                
                var actualError = addCursorRsp.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentAppId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                // create cursor with negative app id
                addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(negativeAppId, [textField], queryOfCursor, 500)) as! KintoneAPIException
                
                actualError = addCursorRsp.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(negativeAppId))
                TestCommonHandling.compareError(actualError, expectedError)
                
                // create cursor with zero app id
                addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(zeroAppId, [textField], queryOfCursor, 500)) as! KintoneAPIException
                
                actualError = addCursorRsp.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(zeroAppId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_014_Success_InvalidFields") {
                let invalidField = "InvalidField"
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [invalidField], queryOfCursor, 500)) as! CreateRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addCursorRsp.getId()))
            }
            
            it("Test_015_Error_InvalidQuery") {
                let invalidQuery = "InvalidQuery"
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], invalidQuery, 500)) as! KintoneAPIException
                
                let actualError = addCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_QUERY_GET_DATA_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_016_Error_InvalidSize") {
                let negativeSize = -1
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, negativeSize)) as! KintoneAPIException
                
                let actualError = addCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_CURSOR_NEGATIVE_SIZE()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_018_Success_WithoutFields") {
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, nil, queryOfCursor, 1)) as! CreateRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addCursorRsp.getId()))
            }
            
            it("Test_019_Success_WithoutQuery") {
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], nil, 1)) as! CreateRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addCursorRsp.getId()))
            }
            
            it("Test_020_Success_WithoutSize") {
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, nil)) as! CreateRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(addCursorRsp.getId()))
            }
            
            it("Test_021_Error_WithoutRecordViewPermission") {
                let usernameWithoutViewRecordPermission = TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION
                let passwordWithoutViewRecordPermission = TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION
                let cursorModuleWithoutViewRecordPermission = Cursor(TestCommonHandling.createConnection(
                    usernameWithoutViewRecordPermission,
                    passwordWithoutViewRecordPermission))
                
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModuleWithoutViewRecordPermission.createCursor(appId, [textField], queryOfCursor, nil)) as! KintoneAPIException
                
                let actualError = addCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_023_Error_WithoutRecordViewPermission_ApiToken") {
                let apiTokenWithoutViewRecordPermission = TestConstant.InitData.SPACE_APP_API_TOKEN_WITHOUT_VIEW_RECORD_PERMISSION
                let cursorModuleWithoutViewRecordPermission = Cursor(TestCommonHandling.createConnection(apiTokenWithoutViewRecordPermission))
                
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModuleWithoutViewRecordPermission.createCursor(appId, [textField], queryOfCursor, nil)) as! KintoneAPIException
                
                let actualError = addCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.API_TOKEN_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_024_Success_FullOptions_GuestSpace") {
                let addCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceAppId, [textField], queryOfCursor, 1)) as! CreateRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _ = TestCommonHandling.awaitAsync(guestSpaceCursorModule.deleteCursor(addCursorRsp.getId()))
            }
            
            it("Test_025_Success_DefaultSizeIs100_GuestSpace") {
                let addCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceAppId, [textField], queryOfCursor, nil)) as! CreateRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _ = TestCommonHandling.awaitAsync(guestSpaceCursorModule.deleteCursor(addCursorRsp.getId()))
            }
            
            it("Test_026_Success_SizeIs500_GuestSpace") {
                let addCursorRsp = TestCommonHandling.awaitAsync(guestSpaceCursorModule.createCursor(guestSpaceAppId, [textField], queryOfCursor, 500)) as! CreateRecordCursorResponse
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _ = TestCommonHandling.awaitAsync(guestSpaceCursorModule.deleteCursor(addCursorRsp.getId()))
            }
            
            it("Test_027_Error_SizeLargerThan500") {
                let invalidSize = 501
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, invalidSize)) as! KintoneAPIException
                
                let actualError = addCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.EXCEED_CURSOR_SIZE_LIMIT()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_028_029_Error_MaximumCursorsIs10") {
                let cursorIds = _addMaximumRecordCursor()
                
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, nil)) as! KintoneAPIException
                
                let actualError = addCursorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.MAXIMUM_LIMIT_CURSOR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                _deleteCursors(cursorIds)
            }
            
            it("Test_032_034_Success_CreateCursorAfterRemoveCurorWhenMaximum") {
                var cursorIds = _addMaximumRecordCursor()
                
                // Delete one of 10 cursor after created
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorIds[0]))
                cursorIds.remove(at: 0)
                
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, nil)) as! CreateRecordCursorResponse
                cursorIds.append(addCursorRsp.getId())
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _deleteCursors(cursorIds)
            }
            
            it("Test_033_Success_ObtainedExistingCursor") {
                var cursorIds = _addMaximumRecordCursor()
                
                // Verify that can not add new cursor
                let addCursorErrorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, nil)) as! KintoneAPIException
                
                let actualError = addCursorErrorRsp.getErrorResponse()!
                let expectedError = KintoneErrorParser.MAXIMUM_LIMIT_CURSOR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                // Delete one of 10 cursor
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(cursorIds[0]))
                cursorIds.remove(at: 0)
                
                // Add new one cursor
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, 500)) as! CreateRecordCursorResponse
                cursorIds.append(addCursorRsp.getId())
                
                _verifyCursorIsCreated(addCursorRsp)
                
                _deleteCursors(cursorIds)
            }
            
            it("WipeoutTestData_AfterSuiteWorkaround") {
                RecordUtils.deleteRecords(recordModule, appId, recordIds)
                RecordUtils.deleteRecords(guestSpaceRecordModule, guestSpaceAppId, guestSpaceRecordIds)
            }
        }
        
        func _verifyCursorIsCreated(_ addCursorRsp: CreateRecordCursorResponse) {
            expect(addCursorRsp.getId()).toNot(beNil())
            expect(addCursorRsp.getTotalCount()).toNot(beNil())
        }
        
        func _addMaximumRecordCursor() -> [String] {
            var cursorIds = [String]()
            for _ in 0...9 {
                let addCursorRsp = TestCommonHandling.awaitAsync(cursorModule.createCursor(appId, [textField], queryOfCursor, nil)) as! CreateRecordCursorResponse
                cursorIds.append(addCursorRsp.getId())
            }
            
            return cursorIds
        }
        
        func _deleteCursors(_ cursorIds: [String]) {
            for id in cursorIds {
                _ = TestCommonHandling.awaitAsync(cursorModule.deleteCursor(id))
            }
        }
    }
}
