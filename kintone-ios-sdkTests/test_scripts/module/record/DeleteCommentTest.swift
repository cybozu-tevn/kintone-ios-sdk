///**
/**
 kintone-ios-sdkTests
 Created on 6/12/19
*/

import Foundation
import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class DeleteCommentTest: QuickSpec {
    override func spec() {
        let APP_ID: Int = TestConstant.InitData.APP_ID!
        let GUEST_SPACE_ID: Int = TestConstant.InitData.GUEST_SPACE_ID!
        let GUEST_SPACE_APP_ID: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
        let API_TOKEN: String = TestConstant.InitData.APP_API_TOKEN
        
        var recordID: Int!
        var recordGuestSpaceID: Int!
        var commentID: Int!
        
        // Comment Data
        let mentionCode: String = "cybozu"
        let mentionType: String = "USER"
        let commentContent: String = "delete comment test"
        var mention: CommentMention!
        var comment: CommentContent!
        var mentionList = [CommentMention]()
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            GUEST_SPACE_ID))
        
        describe("DeleteComment") {
            beforeSuite {
                // Add record to contains comments
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, addData)) as! AddRecordResponse
                recordID = addRecordResponse.getId()
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(GUEST_SPACE_APP_ID, addData)) as! AddRecordResponse
                recordGuestSpaceID = addRecordGuestSpaceResponse.getId()
                
                mention = CommentMention()
                mention.setCode(mentionCode)
                mention.setType(mentionType)
                mentionList.append(mention)
                
                comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions(mentionList)
            }
            
            afterSuite {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, [recordID]))
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(GUEST_SPACE_APP_ID, [recordGuestSpaceID]))
            }
            
            it("Test_256_ValidData") {
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment)) as! AddCommentResponse
                commentID = addCommentResponse.getId()
                _ = TestCommonHandling.awaitAsync(recordModule.deleteComment(APP_ID, recordID, commentID))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_256_GuestSpaceValidData") {
                let addCommentGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(GUEST_SPACE_APP_ID, recordGuestSpaceID, comment)) as! AddCommentResponse
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteComment(GUEST_SPACE_APP_ID, recordGuestSpaceID, commentID))
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(GUEST_SPACE_APP_ID, recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_256_ApiTokenValidData") {
                let recordModuleApiToken = Record(TestCommonHandling.createConnection(API_TOKEN))
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModuleApiToken.addComment(APP_ID, recordID, comment)) as! AddCommentResponse
                commentID = addCommentResponse.getId()
                _ = TestCommonHandling.awaitAsync(recordModuleApiToken.deleteComment(APP_ID, recordID, commentID))
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_257_Error_InvalidCommentID") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteComment(APP_ID, recordID, NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_COMMENT_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_258_Error_NoPermissionForApp") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(APP_ID, recordID, commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_259_Error_NoPermissionForRecord") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(APP_ID, recordID, commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_260_Error_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(APP_ID, recordID, comment)) as! AddCommentResponse
                commentID = addCommentResponse.getId()
                _ = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(APP_ID, recordID, commentID))
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_261_Error_InvalidAppID") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteComment(NONEXISTENT_ID, recordID, commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_262_Error_InvalidRecordID") {
                let result = TestCommonHandling.awaitAsync(recordModule.deleteComment(APP_ID, NONEXISTENT_ID, commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_269_Error_DeleteOtherUserComment") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment)) as! AddCommentResponse
                commentID = addCommentResponse.getId()
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(APP_ID, recordID, commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.DELETE_OTHER_USER_COMMENT_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(commentID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}
