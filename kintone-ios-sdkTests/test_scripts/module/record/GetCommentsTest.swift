//
// kintone-ios-sdkTests
// Created on 6/12/19
//

import Foundation
import Quick
import Nimble
@testable import kintone_ios_sdk
@testable import Promises

class GetCommentsTest: QuickSpec {
    override func spec() {
        let APP_ID: Int = TestConstant.InitData.APP_ID!
        let GUEST_SPACE_ID: Int = TestConstant.InitData.GUEST_SPACE_ID!
        let APP_GUEST_SPACE_ID: Int = TestConstant.InitData.GUEST_SPACE_APP_ID!
        let API_TOKEN: String = TestConstant.InitData.APP_API_TOKEN
        
        var recordID: Int!
        var recordGuestSpaceID: Int!
        
        // Comment Data
        let mentionCode: String = "cybozu"
        let mentionType: String = "USER"
        let commentContent: String = "get comment test"
        var commentID: Int!
        var commentGuestSpaceID: Int!
        var comments: [Int] = []
        var commentsGuestSpace: [Int] = []
        
        let NONEXISTENT_ID = TestConstant.Common.NONEXISTENT_ID
        let NEGATIVE_ID: Int = TestConstant.Common.NEGATIVE_ID
        let TOTAL_COMMENTS: Int = 10
        
        let recordModule = Record(TestCommonHandling.createConnection())
        let recordModuleGuestSpace = Record(TestCommonHandling.createConnection(
            TestConstant.Connection.CRED_ADMIN_USERNAME,
            TestConstant.Connection.CRED_ADMIN_PASSWORD,
            GUEST_SPACE_ID))
        let recordModuleApiToken = Record(TestCommonHandling.createConnection(API_TOKEN))
        
        describe("GetComments") {
            beforeSuite {
                // Add record to contains comments
                let addData: Dictionary<String, FieldValue> = [:]
                let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(APP_ID, addData)) as! AddRecordResponse
                recordID = addRecordResponse.getId()
                let addRecordGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addRecord(APP_GUEST_SPACE_ID, addData)) as! AddRecordResponse
                recordGuestSpaceID = addRecordGuestSpaceResponse.getId()
                
                let mention = CommentMention()
                mention.setCode(mentionCode)
                mention.setType(mentionType)
                
                let comment = CommentContent()
                comment.setText(commentContent)
                comment.setMentions([mention])
                
                // Add >10 comments - Normal Space
                for _ in 0...14 {
                    let addCommentResponse = TestCommonHandling.awaitAsync(recordModule.addComment(APP_ID, recordID, comment)) as! AddCommentResponse
                    commentID = addCommentResponse.getId()
                    comments.append(Int(commentID))
                    
                    let addCommentGuestSpaceResponse = TestCommonHandling.awaitAsync(recordModuleGuestSpace.addComment(
                        APP_GUEST_SPACE_ID,
                        recordGuestSpaceID,
                        comment)) as! AddCommentResponse
                    commentGuestSpaceID = addCommentGuestSpaceResponse.getId()
                    commentsGuestSpace.append(Int(commentGuestSpaceID))
                }
            }
            
            afterSuite {
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(APP_ID, [recordID]))
                _ = TestCommonHandling.awaitAsync(recordModuleGuestSpace.deleteRecords(APP_GUEST_SPACE_ID, [recordGuestSpaceID]))
            }
            
            it("Test_215_ValidData") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentID)
                for comment in result.getComments()! {
                    let expectedResult = mentionCode + " \n" + commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(mentionCode).to(equal(user.getCode()))
                        expect(mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_SortAscending") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_SortDesending") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = comments.count - 1
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_218_Error_InvalidOrder") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, "invalid", nil, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.INVALID_COMMENT_ORDER_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_219_OffsetValue") {
                let OFFSET_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, OFFSET_VALUE, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentIndex = comments.count - 1 - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_220_OffsetIsZero") {
                let OFFSET_VALUE = 0
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, OFFSET_VALUE, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentId = comments.count
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            it("Test_221_Error_OffsetIsInvalid") {
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, -10, nil)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.NEGATIVE_OFFSET_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_222_LimitValue") {
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
            }
            
            it("Test_223_LimitIsZero") {
                let LIMIT_VALUE = 0
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
            }
            
            it("Test_224_Error_LimitIsMoreThan10") {
                let LIMIT_VALUE = 11
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, nil, nil, LIMIT_VALUE)) as! KintoneAPIException
                let actualError = result.getErrorResponse()!
                let expectedError = KintoneErrorParser.LIMIT_LARGER_THAN_10_ERRORS()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_225_AscOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, "asc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var expectedCommentId = comments.count - OFFSET_VALUE - LIMIT_VALUE + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_DescOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, recordID, "desc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentID) - OFFSET_VALUE
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
                    APP_ID,
                    recordID,
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
                    APP_ID,
                    recordID,
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
                    APP_ID,
                    recordID,
                    nil,
                    nil,
                    nil)) as! GetCommentsResponse
                
                expect(TOTAL_COMMENTS).to(equal(result.getComments()?.count))
            }
            
            it("Test_230_Error_InvalidAppID") {
                var result = TestCommonHandling.awaitAsync(recordModule.getComments(NONEXISTENT_ID, recordID, nil, nil, nil)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_APP_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(NEGATIVE_ID, recordID, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(0, recordID, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_APP_ID_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            it("Test_231_Error_InvalidRecordID") {
                var result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, NONEXISTENT_ID, nil, nil, nil)) as! KintoneAPIException
                var actualError = result.getErrorResponse()!
                var expectedError = KintoneErrorParser.NONEXISTENT_RECORD_ID_ERROR()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: String(NONEXISTENT_ID))
                TestCommonHandling.compareError(actualError, expectedError)
                
                result = TestCommonHandling.awaitAsync(recordModule.getComments(APP_ID, NEGATIVE_ID, nil, nil, nil)) as! KintoneAPIException
                actualError = result.getErrorResponse()!
                expectedError = KintoneErrorParser.NEGATIVE_RECORD_ERROR()!
                TestCommonHandling.compareError(actualError, expectedError)
            }
            
            /***
             * GUEST SPACE TESTING
             ***/
            
            it("Test_215_GuestSpace_ValidData") {
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(
                    APP_GUEST_SPACE_ID,
                    recordGuestSpaceID,
                    nil,
                    nil,
                    nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentGuestSpaceID)
                for comment in result.getComments()! {
                    let expectedResult = mentionCode + " \n" + commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(mentionCode).to(equal(user.getCode()))
                        expect(mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_GuestSpace_SortAscending") {
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_GuestSpace_SortDesending") {
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = commentsGuestSpace.count - 1
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_219_GuestSpace_OffsetValue") {
                let OFFSET_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, nil, OFFSET_VALUE, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentIndex = commentsGuestSpace.count - 1 - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(commentsGuestSpace[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_222_GuestSpace_LimitValue") {
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, nil, nil, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
            }
            
            it("Test_225_GuestSpace_AscOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, "asc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var expectedCommentId = commentsGuestSpace.count - OFFSET_VALUE - LIMIT_VALUE + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_GuestSpace_DescOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModuleGuestSpace.getComments(APP_GUEST_SPACE_ID, recordGuestSpaceID, "desc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentGuestSpaceID) - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
            
            /***
             * API TOKEN TESTING
             ***/
            
            it("Test_215_ApiToken_ValidData") {
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentID)
                for comment in result.getComments()! {
                    let expectedResult = mentionCode + " \n" + commentContent + " "
                    expect(expectedResult).to(equal(comment.getText()))
                    expect(commentId).to(equal(comment.getId()))
                    expect(TestConstant.Connection.CRED_ADMIN_USERNAME).to(equal(comment.getCreator()?.code))
                    let mentions = comment.getMentions()
                    for user in mentions! {
                        expect(mentionCode).to(equal(user.getCode()))
                        expect(mentionType).to(equal(user.getType()))
                    }
                    commentId -= 1
                }
            }
            
            it("Test_216_ApiToken_SortAscending") {
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, "asc", nil, nil)) as! GetCommentsResponse
                var commentIndex = 0
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex += 1
                }
            }
            
            it("Test_217_ApiToken_SortDesending") {
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, "desc", nil, nil)) as! GetCommentsResponse
                var commentIndex = comments.count - 1
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_219_ApiToken_OffsetValue") {
                let OFFSET_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, OFFSET_VALUE, nil)) as! GetCommentsResponse
                
                // Only 10 comments are returned by default
                expect(TOTAL_COMMENTS).to(equal(result.getComments()?.count))
                
                var commentIndex = comments.count - 1 - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(comments[commentIndex]).to(equal(value.getId()))
                    commentIndex -= 1
                }
            }
            
            it("Test_222_ApiToken_LimitValue") {
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, nil, nil, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
            }
            
            it("Test_225_ApiToken_AscOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, "asc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var expectedCommentId = comments.count - OFFSET_VALUE - LIMIT_VALUE + 1
                for value in result.getComments()! {
                    expect(expectedCommentId).to(equal(value.getId()))
                    expectedCommentId += 1
                }
            }
            
            it("Test_225_ApiToken_DescOrderOffsetLimitCombination") {
                let OFFSET_VALUE = 5
                let LIMIT_VALUE = 5
                let result = TestCommonHandling.awaitAsync(recordModuleApiToken.getComments(APP_ID, recordID, "desc", OFFSET_VALUE, LIMIT_VALUE)) as! GetCommentsResponse
                expect(LIMIT_VALUE).to(equal(result.getComments()?.count))
                
                var commentId = Int(commentID) - OFFSET_VALUE
                for value in result.getComments()! {
                    expect(commentId).to(equal(value.getId()))
                    commentId -= 1
                }
            }
        }
    }
}
