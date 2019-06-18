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
    private var recordModule: Record!
    private var recordModuleGuestSpace: Record!
    private var recordModuleApiToken: Record!
    
    private let APP_ID: Int = TestConstant.InitData.APP_ID!
    private let GUEST_SPACE_ID: Int = TestConstant.InitData.GUEST_SPACE_ID!
    private let GUEST_SPACE_APP_ID: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
    private let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
    private let API_TOKEN: String = TestConstant.InitData.APP_API_TOKEN
    
    private var recordID: Int!
    private var recordGuestSpaceID: Int!
    private var commentID: Int!
    private var commentGuestSpaceID: Int!
    
    // Comment Data
    private let mentionCode: String = "cybozu"
    private let mentionType: String = "USER"
    private let commentContent: String = "delete comment test"
    private let RECORD_TEXT_FIELD: String! = TestConstant.InitData.TEXT_FIELD
    private var mention: CommentMention!
    private var comment: CommentContent!
    private var mentionList = [CommentMention]()
    
    override func spec() {
        describe("DeleteComment") {
            beforeSuite {
                self.recordModule = Record(TestCommonHandling.createConnection())
                self.recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_ADMIN_USERNAME,
                    TestConstant.Connection.CRED_ADMIN_PASSWORD,
                    self.GUEST_SPACE_ID))
                self.recordModuleApiToken = Record(TestCommonHandling.createConnection(self.API_TOKEN))
                
                // Add record to contains comments
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, addData)) as! AddRecordResponse
                self.recordID = addRecordResponse.getId()
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addRecord(self.GUEST_SPACE_APP_ID, addData)) as! AddRecordResponse
                self.recordGuestSpaceID = addRecordGuestSpaceResponse.getId()
                
                self.mention = CommentMention()
                self.mention.setCode(self.mentionCode)
                self.mention.setType(self.mentionType)
                self.mentionList.append(self.mention)
                
                self.comment = CommentContent()
                self.comment.setText(self.commentContent)
                self.comment.setMentions(self.mentionList)
            }
            
            afterSuite {
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [self.recordID]))
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.deleteRecords(self.GUEST_SPACE_APP_ID, [self.recordGuestSpaceID]))
            }
            
            it("Test_256_ValidData") {
                let addCommentResponse = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, self.comment)) as! AddCommentResponse
                self.commentID = addCommentResponse.getId()
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteComment(self.APP_ID, self.recordID, self.commentID))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_256_GuestSpaceValidData") {
                let addCommentGuestSpaceResponse = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addComment(self.GUEST_SPACE_APP_ID, self.recordGuestSpaceID, self.comment)) as! AddCommentResponse
                self.commentGuestSpaceID = addCommentGuestSpaceResponse.getId()
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.deleteComment(self.GUEST_SPACE_APP_ID, self.recordGuestSpaceID, self.commentID))
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.GUEST_SPACE_APP_ID, self.recordGuestSpaceID, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_256_ApiTokenValidData") {
                let addCommentResponse = TestCommonHandling.awaitAsync(self.recordModuleApiToken.addComment(self.APP_ID, self.recordID, self.comment)) as! AddCommentResponse
                self.commentID = addCommentResponse.getId()
                _ = TestCommonHandling.awaitAsync(self.recordModuleApiToken.deleteComment(self.APP_ID, self.recordID, self.commentID))
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_257_Error_InvalidCommentID") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.deleteComment(self.APP_ID, self.recordID, self.NONEXISTENT_ID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_COMMENT_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_258_Error_NoPermissionForApp") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(self.APP_ID, self.recordID, self.commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_259_Error_NoPermissionForRecord") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORDS_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORDS_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(self.APP_ID, self.recordID, self.commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_260_Error_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PEMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PEMISSION))
                let addCommentResponse = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.addComment(self.APP_ID, self.recordID, self.comment)) as! AddCommentResponse
                self.commentID = addCommentResponse.getId()
                _ = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(self.APP_ID, self.recordID, self.commentID))
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                expect(result.getComments()?.count).to(equal(0))
            }
            
            it("Test_261_Error_InvalidAppID") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.deleteComment(self.NONEXISTENT_ID, self.recordID, self.commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_262_Error_InvalidRecordID") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.deleteComment(self.APP_ID, self.NONEXISTENT_ID, self.commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_269_Error_DeleteOtherUserComment") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PEMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PEMISSION))
                let addCommentResponse = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, self.comment)) as! AddCommentResponse
                self.commentID = addCommentResponse.getId()
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.deleteComment(self.APP_ID, self.recordID, self.commentID)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.DELETE_OTHER_USER_COMMENT_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.commentID))
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}
