//
// kintone-ios-sdkTests
// Created on 5/7/19
// 

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class AddRecordTest: QuickSpec {
    override func spec() {
        let recordModule = Record(TestCommonHandling.createConnection())
        let appId = TestConstant.InitData.APP_ID!
        
        var recordId: Int?
        var recordRevision: Int?
        let textField: String = TestConstant.InitData.TEXT_FIELD
        let numberField: String = TestConstant.InitData.NUMBER_FIELD
        var recordTextValue: String?
        var testData: Dictionary<String, FieldValue>! = [:]
        
        describe("AddRecord") {
            it("Test_027_Success_ValidData") {
                recordTextValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordId).toNot(beNil())
                expect(1).to(equal(recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == textField) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId!]))
            }
            
            it("Test_027_Success_ValidData_ApiToken") {
                let apiToken = TestConstant.InitData.APP_API_TOKEN
                let recordModuleWithAPIToken = Record(TestCommonHandling.createConnection(apiToken))
                recordTextValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.addRecord(appId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordId).toNot(beNil())
                expect(1).to(equal(recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.getRecord(appId, recordId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == textField) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleWithAPIToken.deleteRecords(appId, [recordId!]))
            }
            
            it("Test_028_Error_NonexistentAppId") {
                let noneExistentId = TestConstant.Common.NONEXISTENT_ID
                recordTextValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(noneExistentId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError  = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(noneExistentId))
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_029_Error_NegativeAppId") {
                let negativeId = TestConstant.Common.NEGATIVE_ID
                recordTextValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(negativeId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError  = KintoneErrorParser.NEGATIVE_APPID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            //To test this case please set up an application have number field
            it("Test_030_Error_InputTextToNumberField") {
                testData = RecordUtils.setRecordData([:], numberField, FieldType.NUMBER, "inputTextToNumber")
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_FIELD_TYPE_NUMBER_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: "[\(numberField)]")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            //To test this case please set up an application have prohibit duplicate value field. fieldCode = RECORD_TEXT_FIELD
            it("Test_031_Error_DuplicateDataForProhibitDuplicateValue") {
                let appHasProhibitDuplicateFieldId = TestConstant.InitData.APP_ID_HAS_PROHIBIT_DUPLICATE_VALUE_FIELDS!
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, "prohibitValue")
                let addRecord = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasProhibitDuplicateFieldId, testData)) as! AddRecordResponse
                recordId = addRecord.getId()
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasProhibitDuplicateFieldId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.INVALID_VALUE_DUPLICATED_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(textField)")
                TestCommonHandling.compareError(actualError, expectedError)
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appHasProhibitDuplicateFieldId, [recordId!]))
            }
            
            it("Test_035_Success_WithoutRecordData") {
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId, nil)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordId).toNot(beNil())
                expect(1).to(equal(recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModule.getRecord(appId, recordId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == textField) {
                        expect("").to(equal(value.getValue() as? String))
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId, [recordId!]))
            }
            
            //To test this case please set up an application have required field. fieldCode = RECORD_TEXT_FIELD
            it("Test_036_Error_WithoutRequiredField") {
                let appHasRequiredFieldId = TestConstant.InitData.APP_ID_HAS_REQUIRED_FIELDS!
                let result = TestCommonHandling.awaitAsync(recordModule.addRecord(appHasRequiredFieldId, nil)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError = KintoneErrorParser.MISSING_REQUIRED_FIELD_ADD_RECORD_ERROR()!
                expectedError.replaceKeyError(oldTemplate: "%VARIABLE", newTemplate: ".\(textField)")
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_039_Success_ValidData_GuestSpace") {
                let guestSpaceId = TestConstant.InitData.GUEST_SPACE_ID!
                let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
                let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    guestSpaceId))
                recordTextValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(guestSpaceAppId, testData)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordId).toNot(beNil())
                expect(1).to(equal(recordRevision))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getRecord(guestSpaceAppId, recordId!)) as! GetRecordResponse
                for(key, value) in result.getRecord()! {
                    if(key == textField) {
                        expect(recordTextValue).to(equal(value.getValue() as? String))
                    }
                }
                
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(guestSpaceAppId, [recordId!]))
            }
            
            it("Test_041_Error_WithoutAddRecordPermissionOnApp") {
                let recordModuleWithoutAddPermissionApp = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_ADD_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_ADD_RECORDS_PERMISSION))
                recordTextValue = DataRandomization.generateString(prefix: "AddRecord", length: 10)
                testData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, recordTextValue as Any)
                
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutAddPermissionApp.addRecord(appId, testData)) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_045_Success_BlankApp") {
                let blankAppId = TestConstant.InitData.APP_BLANK_ID
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(blankAppId!, nil)) as! AddRecordResponse
                recordId = addRecordResponse.getId()
                recordRevision = addRecordResponse.getRevision()
                
                expect(recordId).toNot(beNil())
                expect(1).to(equal(recordRevision))
                
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(blankAppId!, [recordId!]))
            }
        }
    }
}
