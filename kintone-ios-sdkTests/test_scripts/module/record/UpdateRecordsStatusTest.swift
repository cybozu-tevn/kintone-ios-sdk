//
//  UpdateRecordStatusTest.swift
//  kintone-ios-sdkTests
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class UpdateRecordsStatusTest: QuickSpec {
    
    override func spec() {
        let AppId = TestConstant.InitData.APP_ID_HAS_PROCESS!
        let guestSpaceAppId = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        var record1Id: Int!
        var record2Id: Int!
        var revision: Int!
        let startAction = TestConstant.InitData.ACTION_START
        let testAction = TestConstant.InitData.ACTION_TEST
        let inProgressStatus = TestConstant.InitData.STATE_IN_PROGRESS
        let testingStatus = TestConstant.InitData.STATE_TESTING
        
        let recordModule = Record(TestCommonHandling.createConnection())
        
        // ---------------- NORMAL SPACE
        describe("UpdateRecordsStatus_1") {
            beforeEach {
                let testData1 = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let testData2 = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecord1Response = TestCommonHandling.awaitAsync(
                    recordModule.addRecord(AppId, testData1)) as! AddRecordResponse
                let addRecord2Response = TestCommonHandling.awaitAsync(
                    recordModule.addRecord(AppId, testData2)) as! AddRecordResponse
                
                record1Id = addRecord1Response.getId()
                record2Id = addRecord2Response.getId()
                revision = addRecord1Response.getRevision()
            }
            afterEach {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, [record1Id, record2Id]))
            }
            
            it("Test_200_StatusOnly") {
                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, -1)
                let recordsStatusItem = [record1StatusItem, record2StatusItem]
                
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem))
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, record1Id)) as! GetRecordResponse
                let record1Data = getRecordResponse.getRecord()!
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, record2Id)) as! GetRecordResponse
                let record2Data = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(Int(record1Data["$revision"]?.getValue() as! String)).to(equal(revision + 2))
                expect(record1Data["Status"]?.getValue() as? String).to(equal(inProgressStatus))
                expect(Int(record2Data["$revision"]?.getValue() as! String)).to(equal(revision + 2))
                expect(record2Data["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_201_StatusAndAssignee") {
                var record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                var record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
                var recordsStatusItem = [record1StatusItem, record2StatusItem]
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem))
                revision += 2
                
                // Update status with assignee
                let assignee = TestConstant.InitData.USERS[0]
                record1StatusItem = RecordUpdateStatusItem(testAction, assignee.username, record1Id, nil)
                record2StatusItem = RecordUpdateStatusItem(testAction, assignee.username, record2Id, nil)
                recordsStatusItem = [record1StatusItem, record2StatusItem]
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem))
                revision += 2
                
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, record1Id)) as! GetRecordResponse
                let record1Data = getRecordResponse.getRecord()!
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, record2Id)) as! GetRecordResponse
                let record2Data = getRecordResponse.getRecord()!
                let record1Assignees = record1Data["Assignee"]?.getValue() as! [Member]
                let record2Assignees = record2Data["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                // - Assignee is set
                expect(Int(record1Data["$revision"]?.getValue() as! String)).to(equal(revision))
                expect(record1Data["Status"]?.getValue() as? String).to(equal(testingStatus))
                expect(record1Assignees[0].getName()).to(equal(assignee.username))
                expect(Int(record2Data["$revision"]?.getValue() as! String)).to(equal(revision))
                expect(record2Data["Status"]?.getValue() as? String).to(equal(testingStatus))
                expect(record2Assignees[0].getName()).to(equal(assignee.username))
            }
            
            it("Test_202_Error_InvalidAction") {
                let record1StatusItem = RecordUpdateStatusItem("Invalid_action", nil, record1Id, nil)
                let record2StatusItem = RecordUpdateStatusItem("Invalid_action", nil, record2Id, nil)
                let recordsStatusItem = [record1StatusItem, record2StatusItem]
                
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INVALID_STATUS_ERROR()!)
            }
            
            it("Test_203_Error_InvalidAssignee") {
                var record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                var record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
                var recordsStatusItem = [record1StatusItem, record2StatusItem]
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem))
                
                let nonexistentUser = "nonexistent user blah blah"
                record1StatusItem = RecordUpdateStatusItem(testAction, nonexistentUser, record1Id, nil)
                record2StatusItem = RecordUpdateStatusItem(testAction, nonexistentUser, record2Id, nil)
                recordsStatusItem = [record1StatusItem, record2StatusItem]
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem)) as! KintoneAPIException
                
                var expectedError = KintoneErrorParser.NONEXISTENT_USER_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: nonexistentUser)
                TestCommonHandling.compareError(result.getErrorResponse(), expectedError)
            }
            
            it("Test_204_Error_InvalidRecordID") {
                let nonexistentId = TestConstant.Common.NONEXISTENT_ID
                let record1StatusItem = RecordUpdateStatusItem(testAction, nil, nonexistentId, nil)
                let record2StatusItem = RecordUpdateStatusItem(testAction, nil, record2Id, nil)
                let recordsStatusItem = [record1StatusItem, record2StatusItem]
                
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem)) as! KintoneAPIException
                
                var errorMessage = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                errorMessage.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(nonexistentId))
                TestCommonHandling.compareError(result.getErrorResponse(), errorMessage)
            }
            
            it("Test_205_Error_InvalidRevision") {
                let record1StatusItem = RecordUpdateStatusItem("Invalid_action", nil, record1Id, 9999)
                let record2StatusItem = RecordUpdateStatusItem("Invalid_action", nil, record2Id, 9999)
                let recordsStatusItem = [record1StatusItem, record2StatusItem]
                
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.INCORRECT_REVISION_RECORD_ERROR()!)
            }
            
            it("Test_206_Error_InvalidAppID") {
                // nonexistent appID
                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, 9999)
                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, 9999)
                let recordsStatusItem = [record1StatusItem, record2StatusItem]
                
                var result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(TestConstant.Common.NONEXISTENT_ID, recordsStatusItem)) as! KintoneAPIException
                var errorMessage = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                errorMessage.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(TestConstant.Common.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(result.getErrorResponse(), errorMessage)
                
                // negative appID
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(-1, recordsStatusItem)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
                
                // zero appID
                result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(0, recordsStatusItem)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!)
            }
            
            //            it("Test_207_Error_MissingAppID") {
            //                // Error is detected by xcode editor
            //                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
            //                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
            //                let recordsStatusItem = [record1StatusItem, record2StatusItem]
            //
            //                let result = TestCommonHandling.awaitAsync(
            //                    recordModule.updateRecordsStatus(nil, recordsStatusItem)) as! KintoneAPIException
            //            }
            
            it("Test_208_Error_MissingRecordID") {
                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, nil, nil)
                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, nil, nil)
                let recordsStatusItem = [record1StatusItem, record2StatusItem]
                
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.MISSING_RECORD_ID_UPDATE_RECORDS_ERROR()!)
            }
            
            it("Test_209_Error_MissingAssignees") {
                var record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                var record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
                var recordsStatusItem = [record1StatusItem, record2StatusItem]
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem))
                
                // Update status without assignee
                record1StatusItem = RecordUpdateStatusItem(testAction, nil, record1Id, nil)
                record2StatusItem = RecordUpdateStatusItem(testAction, nil, record2Id, nil)
                recordsStatusItem = [record1StatusItem, record2StatusItem]
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.MISSING_ASSIGNEE_ERROR()!)
            }
            
            //            it("Test_211_Error_InvalidInputType") {
            //                // Error is detected by xcode editor
            //                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
            //                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
            //                let recordsStatusItem = [record1StatusItem, record2StatusItem]
            //
            //                let result = TestCommonHandling.awaitAsync(
            //                    recordModule.updateRecordsStatus("9", recordsStatusItem)) as! KintoneAPIException
            //            }
            
            //            it("Test_212_Error_DisableProcessManagement") {
            //                // Currently the process management must be disabled by MANUAL
            //                // -> You should set break point here, then disable process management by manual
            //                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
            //                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
            //                let recordsStatusItem = [record1StatusItem, record2StatusItem]
            //
            //                let result = TestCommonHandling.awaitAsync(
            //                    recordModule.updateRecordsStatus(AppId, recordsStatusItem)) as! KintoneAPIException
            //
            //                 TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.PROCESS_MANAGEMENT_DISABLED_ERROR()!)
            //            }
            
            it("Test_214_Error_MoreThan100Records") {
                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
                var recordsStatusItem = [record1StatusItem]
                for _ in 1...100 {
                    recordsStatusItem.append(record2StatusItem)
                }
                
                let result = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem)) as! KintoneAPIException
                
                TestCommonHandling.compareError(result.getErrorResponse(), KintoneErrorParser.MORE_THAN_100_UPDATE_RECORDS_ERROR()!)
            }
            
            it("Test_213_100Records") {
                // Prepare 100 records
                let addData = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                var addDataList: [Dictionary<String, FieldValue>] = []
                for _ in 0...99 {
                    addDataList.append(addData)
                }
                let add100RecordsResponse = TestCommonHandling.awaitAsync(recordModule.addRecords(AppId, addDataList)) as! AddRecordsResponse
                let recordIDs = add100RecordsResponse.getIDs()
                
                // Prepare 100 status update items and update
                var recordsStatusItem: [RecordUpdateStatusItem]! = []
                for id in recordIDs! {
                    let recordStatusItem = RecordUpdateStatusItem(startAction, nil, id, nil)
                    recordsStatusItem.append(recordStatusItem)
                }
                _ = TestCommonHandling.awaitAsync(
                    recordModule.updateRecordsStatus(AppId, recordsStatusItem))
                
                // Verify all records are updated status
                for id in recordIDs! {
                    let getRecordResponse = TestCommonHandling.awaitAsync(
                        recordModule.getRecord(AppId, id)) as! GetRecordResponse
                    let recordData = getRecordResponse.getRecord()!
                    
                    expect(Int(recordData["$revision"]?.getValue() as! String)).to(equal(revision + 2))
                    expect(recordData["Status"]?.getValue() as? String).to(equal(inProgressStatus))
                }

                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, recordIDs!))
            }
        }
        
        // ---------------- GUEST SPACE
        describe("UpdateRecordsStatus_2") {
            let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                TestConstant.Connection.CRED_ADMIN_USERNAME,
                TestConstant.Connection.CRED_ADMIN_PASSWORD,
                TestConstant.InitData.GUEST_SPACE_ID!))
            
            beforeEach {
                let testData1 = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let testData2 = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecord1Response = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.addRecord(guestSpaceAppId, testData1)) as! AddRecordResponse
                let addRecord2Response = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.addRecord(guestSpaceAppId, testData2)) as! AddRecordResponse

                record1Id = addRecord1Response.getId()
                record2Id = addRecord2Response.getId()
                revision = addRecord1Response.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, [record1Id, record2Id]))
            }
            
            it("Test_200_GuestSpace_StatusOnly") {
                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, -1)
                let recordsStatusItem = [record1StatusItem, record2StatusItem]
                
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordsStatus(guestSpaceAppId, recordsStatusItem))
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, record1Id)) as! GetRecordResponse
                let record1Data = getRecordResponse.getRecord()!
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, record2Id)) as! GetRecordResponse
                let record2Data = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(Int(record1Data["$revision"]?.getValue() as! String)).to(equal(revision + 2))
                expect(record1Data["Status"]?.getValue() as? String).to(equal(inProgressStatus))
                expect(Int(record2Data["$revision"]?.getValue() as! String)).to(equal(revision + 2))
                expect(record2Data["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_201_GuestSpace_StatusAndAssignee") {
                // 1. Update status for records: Start action
                var record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                var record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
                var recordsStatusItem = [record1StatusItem, record2StatusItem]
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordsStatus(guestSpaceAppId, recordsStatusItem))
                revision += 2
                
                // 2. Update status for records: Test action + assignee
                let assignee = TestConstant.InitData.USERS[0]
                record1StatusItem = RecordUpdateStatusItem(testAction, assignee.username, record1Id, nil)
                record2StatusItem = RecordUpdateStatusItem(testAction, assignee.username, record2Id, nil)
                recordsStatusItem = [record1StatusItem, record2StatusItem]
                _ = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.updateRecordsStatus(guestSpaceAppId, recordsStatusItem))
                revision += 2
                
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, record1Id)) as! GetRecordResponse
                let record1Data = getRecordResponse.getRecord()!
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleGuestSpace.getRecord(guestSpaceAppId, record2Id)) as! GetRecordResponse
                let record2Data = getRecordResponse.getRecord()!
                let record1Assignees = record1Data["Assignee"]?.getValue() as! [Member]
                let record2Assignees = record2Data["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                // - Assignee is set
                expect(Int(record1Data["$revision"]?.getValue() as! String)).to(equal(revision))
                expect(record1Data["Status"]?.getValue() as? String).to(equal(testingStatus))
                expect(record1Assignees[0].getName()).to(equal(assignee.username))
                expect(Int(record2Data["$revision"]?.getValue() as! String)).to(equal(revision))
                expect(record2Data["Status"]?.getValue() as? String).to(equal(testingStatus))
                expect(record2Assignees[0].getName()).to(equal(assignee.username))
            }
        }
        
        // ---------------- API TOKEN
        describe("UpdateRecordsStatus_3") {
            let recordModuleAPIToken = Record(TestCommonHandling.createConnection(TestConstant.InitData.APP_WITH_PROCESS_API_TOKEN))
            
            beforeEach {
                let testData1 = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let testData2 = RecordUtils.setRecordData([:], textField, FieldType.SINGLE_LINE_TEXT, DataRandomization.generateString())
                let addRecord1Response = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.addRecord(AppId, testData1)) as! AddRecordResponse
                let addRecord2Response = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.addRecord(AppId, testData2)) as! AddRecordResponse

                record1Id = addRecord1Response.getId()
                record2Id = addRecord2Response.getId()
                revision = addRecord1Response.getRevision()
            }
            
            afterEach {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(AppId, [record1Id, record2Id]))
            }
            
            it("Test_200_APIToken_StatusOnly") {
                let record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                let record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, -1)
                let recordsStatusItem = [record1StatusItem, record2StatusItem]
                
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordsStatus(AppId, recordsStatusItem))
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.getRecord(AppId, record1Id)) as! GetRecordResponse
                let record1Data = getRecordResponse.getRecord()!
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.getRecord(AppId, record2Id)) as! GetRecordResponse
                let record2Data = getRecordResponse.getRecord()!
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                expect(Int(record1Data["$revision"]?.getValue() as! String)).to(equal(revision + 2))
                expect(record1Data["Status"]?.getValue() as? String).to(equal(inProgressStatus))
                expect(Int(record2Data["$revision"]?.getValue() as! String)).to(equal(revision + 2))
                expect(record2Data["Status"]?.getValue() as? String).to(equal(inProgressStatus))
            }
            
            it("Test_201_APIToken_StatusAndAssignee") {
                // 1. Update status for records: Start action
                var record1StatusItem = RecordUpdateStatusItem(startAction, nil, record1Id, nil)
                var record2StatusItem = RecordUpdateStatusItem(startAction, nil, record2Id, nil)
                var recordsStatusItem = [record1StatusItem, record2StatusItem]
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordsStatus(AppId, recordsStatusItem))
                revision += 2
                
                // 2. Update status for records: Test action + assignee
                let assignee = TestConstant.InitData.USERS[0]
                record1StatusItem = RecordUpdateStatusItem(testAction, assignee.username, record1Id, nil)
                record2StatusItem = RecordUpdateStatusItem(testAction, assignee.username, record2Id, nil)
                recordsStatusItem = [record1StatusItem, record2StatusItem]
                _ = TestCommonHandling.awaitAsync(
                    recordModuleAPIToken.updateRecordsStatus(AppId, recordsStatusItem))
                revision += 2
                
                var getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, record1Id)) as! GetRecordResponse
                let record1Data = getRecordResponse.getRecord()!
                getRecordResponse = TestCommonHandling.awaitAsync(
                    recordModule.getRecord(AppId, record2Id)) as! GetRecordResponse
                let record2Data = getRecordResponse.getRecord()!
                let record1Assignees = record1Data["Assignee"]?.getValue() as! [Member]
                let record2Assignees = record2Data["Assignee"]?.getValue() as! [Member]
                
                // Verify:
                // - Revision is increased by 2: execute Action + change status
                // - Status is changed
                // - Assignee is set
                expect(Int(record1Data["$revision"]?.getValue() as! String)).to(equal(revision))
                expect(record1Data["Status"]?.getValue() as? String).to(equal(testingStatus))
                expect(record1Assignees[0].getName()).to(equal(assignee.username))
                expect(Int(record2Data["$revision"]?.getValue() as! String)).to(equal(revision))
                expect(record2Data["Status"]?.getValue() as? String).to(equal(testingStatus))
                expect(record2Assignees[0].getName()).to(equal(assignee.username))
            }
        }
    }
}
