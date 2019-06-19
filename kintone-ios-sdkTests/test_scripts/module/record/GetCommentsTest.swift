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

class GetCommentsTest: QuickSpec {
    private var recordModule: Record!
    private var recordModuleGuestSpace: Record!
    private var recordModuleApiToken: Record!

    private let APP_ID: Int = TestConstant.InitData.APP_ID!
    private let GUEST_SPACE_ID: Int = TestConstant.InitData.GUEST_SPACE_ID!
    private let APP_GUEST_SPACE_ID: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
    private let API_TOKEN: String = TestConstant.InitData.APP_API_TOKEN

    private var recordID: Int!
    private var recordGuestSpaceID: Int!
    
    // Comment Data
    private let mentionCode: String = "cybozu"
    private let mentionType: String = "USER"
    private let commentContent: String = "get comment test"
    private var commentID: Int!
    private var commentGuestSpaceID: Int!
    private var comments: [Int] = []
    private var commentsGuestSpace: [Int] = []
    
    private let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
    private let NEGATIVE_ID: Int = TestConstant.Common.NEGATIVE_ID
    private let TOTAL_COMMENTS: Int = 10
    
    override func spec() {
        describe("GetComments") {

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
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addRecord(self.APP_GUEST_SPACE_ID, addData)) as! AddRecordResponse
                self.recordGuestSpaceID = addRecordGuestSpaceResponse.getId()
                
                let mention = CommentMention()
                mention.setCode(self.mentionCode)
                mention.setType(self.mentionType)
                
                let comment = CommentContent()
                comment.setText(self.commentContent)
                comment.setMentions([mention])
                
                // Add >10 comments - Normal Space
                for _ in 0...14 {
                    let addCommentResponse = TestCommonHandling.awaitAsync(self.recordModule.addComment(self.APP_ID, self.recordID, comment)) as! AddCommentResponse
                    self.commentID = addCommentResponse.getId()
                    self.comments.append(Int(self.commentID))
                    
                    let addCommentGuestSpaceResponse = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.addComment(
                        self.APP_GUEST_SPACE_ID,
                        self.recordGuestSpaceID,
                        comment)) as! AddCommentResponse
                    self.commentGuestSpaceID = addCommentGuestSpaceResponse.getId()
                    self.commentsGuestSpace.append(Int(self.commentGuestSpaceID))
                }
            }
            
            afterSuite {
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [self.recordID]))
                _ = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.deleteRecords(self.APP_GUEST_SPACE_ID, [self.recordGuestSpaceID]))
            }
            
            it("Test_215_ValidData") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(self.TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentId = Int(self.commentID)
                for comment in result.getComments()! {
                    let expectedResult = self.mentionCode + " \n" + self.commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(self.mentionCode).to(equal(user.getCode()))
                        expect(self.mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_SortAscending") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                for value in result.getComments()! {
                    expect(self.comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_SortDesending") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = self.comments.count - 1
                for value in result.getComments()! {
                    expect(self.comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_218_Error_InvalidOrder") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, "invalid", nil, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_COMMENT_ORDER_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_219_OffsetValue") {
                let OFFSET_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, OFFSET_VALUE, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(self.TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentIndex = self.comments.count - 1 - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(self.comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_220_OffsetIsZero") {
                let OFFSET_VALUE = 0
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, OFFSET_VALUE, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(self.TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentId = self.comments.count
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            it("Test_221_Error_OffsetIsInvalid") {
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, -10, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_222_LimitValue") {
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
            }
            
            it("Test_223_LimitIsZero") {
                let LIMIT_VALUE = 0
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
            }
            
            it("Test_224_Error_LimitIsMoreThan10") {
                let LIMIT_VALUE = 11
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, nil, nil, LIMIT_VALUE)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_10_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_225_AscOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, "asc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var expectedCommentId = self.comments.count - OFFSET_VALUE - LIMIT_VALUE + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_DescOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.recordID, "desc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var commentId = Int(self.commentID) - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            it("Test_227_Error_NoPermissionForApp") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_APP_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_APP_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.getComments(
                    self.APP_ID,
                    self.recordID,
                    nil,
                    nil,
                    nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_228_Error_NoPermissionForRecord") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_RECORD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_RECORD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.getComments(
                    self.APP_ID,
                    self.recordID,
                    nil,
                    nil,
                    nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.PERMISSION_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_229_Error_NoPermissionForField") {
                let recordModuleWithoutPermission = Record(TestCommonHandling.createConnection(
                    TestConstant.Connection.CRED_USERNAME_WITHOUT_VIEW_FIELD_PERMISSION,
                    TestConstant.Connection.CRED_PASSWORD_WITHOUT_VIEW_FIELD_PERMISSION))
                let result = TestCommonHandling.awaitAsync(recordModuleWithoutPermission.getComments(
                    self.APP_ID,
                    self.recordID,
                    nil,
                    nil,
                    nil)) as! GetCommentsResponse
                
                expect(self.TOTAL_COMMENTS).to(equal(result.getComments()?.count))
            }
            
            it("Test_230_Error_InvalidAppID") {
                var result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.NONEXISTENT_ID, self.recordID, nil, nil, nil)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.NEGATIVE_ID, self.recordID, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(self.recordModule.getComments(0, self.recordID, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_231_Error_InvalidRecordID") {
                var result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.NONEXISTENT_ID, nil, nil, nil)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(self.NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(self.recordModule.getComments(self.APP_ID, self.NEGATIVE_ID, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            /***
             * GUEST SPACE TESTING
             ***/
            
            it("Test_215_GuestSpace_ValidData") {
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(
                    self.APP_GUEST_SPACE_ID,
                    self.recordGuestSpaceID,
                    nil,
                    nil,
                    nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(self.TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentId = Int(self.commentGuestSpaceID)
                for comment in result.getComments()! {
                    let expectedResult = self.mentionCode + " \n" + self.commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(self.mentionCode).to(equal(user.getCode()))
                        expect(self.mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_GuestSpace_SortAscending") {
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                for value in result.getComments()! {
                    expect(self.comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_GuestSpace_SortDesending") {
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = self.commentsGuestSpace.count - 1
                for value in result.getComments()! {
                    expect(self.comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_219_GuestSpace_OffsetValue") {
                let OFFSET_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, nil, OFFSET_VALUE, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(self.TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentIndex = self.commentsGuestSpace.count - 1 - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(self.commentsGuestSpace[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_222_GuestSpace_LimitValue") {
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, nil, nil, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
            }
            
            it("Test_225_GuestSpace_AscOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, "asc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var expectedCommentId = self.commentsGuestSpace.count - OFFSET_VALUE - LIMIT_VALUE + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_GuestSpace_DescOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModuleGuestSpace.getComments(self.APP_GUEST_SPACE_ID, self.recordGuestSpaceID, "desc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var commentId = Int(self.commentGuestSpaceID) - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            /***
             * API TOKEN TESTING
             ***/
            
            it("Test_215_ApiToken_ValidData") {
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(self.TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentId = Int(self.commentID)
                for comment in result.getComments()! {
                    let expectedResult = self.mentionCode + " \n" + self.commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(self.mentionCode).to(equal(user.getCode()))
                        expect(self.mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_ApiToken_SortAscending") {
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                for value in result.getComments()! {
                    expect(self.comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_ApiToken_SortDesending") {
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = self.comments.count - 1
                for value in result.getComments()! {
                    expect(self.comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_219_ApiToken_OffsetValue") {
                let OFFSET_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, OFFSET_VALUE, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(self.TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentIndex = self.comments.count - 1 - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(self.comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_222_ApiToken_LimitValue") {
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, nil, nil, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
            }
            
            it("Test_225_ApiToken_AscOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, "asc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var expectedCommentId = self.comments.count - OFFSET_VALUE - LIMIT_VALUE + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_ApiToken_DescOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(self.recordModuleApiToken.getComments(self.APP_ID, self.recordID, "desc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var commentId = Int(self.commentID) - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
        }
    }
}
