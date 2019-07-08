//
// kintone-ios-sdkTests
// Created on 5/29/19
//

import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class DownloadFileTest: QuickSpec {
    override func spec() {
        let appId = TestConstant.InitData.APP_ID
        let textField: String! = TestConstant.InitData.TEXT_FIELD
        let attachmentField: String! = TestConstant.InitData.ATTACHMENT_FIELD
        var fileKeys: [String]! = []
        
        var recordId: Int!
        var expectedFileName: String!
        var expectedFileSize: Int!
        var expectedFileContent: String!
        let conn = TestCommonHandling.createConnection()
        let recordModule = Record(conn)
        let fileModule = File(conn)
        
        describe("DowloadFile") {
            beforeSuite {
                // Prepare test data
                let bundleUploadFile = Bundle(for: type(of: self))
                var recordTestData: [String: FieldValue] = [:]
                recordTestData = RecordUtils.setRecordData(recordTestData,
                                                           textField, FieldType.SINGLE_LINE_TEXT,
                                                           "Upload single file")
                
                if let uploadFilePath = bundleUploadFile.url(forResource: "test", withExtension: "xlsx") {
                    let resourcesFile = try! uploadFilePath.resourceValues(forKeys: [.fileSizeKey])
                    expectedFileSize = resourcesFile.fileSize!
                    expectedFileName = uploadFilePath.lastPathComponent
                    expectedFileContent = try! String(contentsOf: uploadFilePath, encoding: String.Encoding.unicode)
                    
                    // Prepare upload files
                    let uploadFileResponse1 = TestCommonHandling.awaitAsync(fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                    let uploadFileResponse2 = TestCommonHandling.awaitAsync(fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                    let fileList = [uploadFileResponse1, uploadFileResponse2]
                    recordTestData = RecordUtils.setRecordData(recordTestData, attachmentField, FieldType.FILE, fileList)
                    
                    // Add record with upload files
                    let addRecordResponse = TestCommonHandling.awaitAsync(recordModule.addRecord(appId!, recordTestData)) as! AddRecordResponse
                    recordId = addRecordResponse.getId()!
                }
            }
            
            afterSuite {
                // Delete added test record
                _ = TestCommonHandling.awaitAsync(recordModule.deleteRecords(appId!, [recordId!]))
            }
            
            it("Test_006_Success_DowloadFile") {
                // Get record -> download file -> verify file info
                let getRecordResponse = TestCommonHandling.awaitAsync(recordModule.getRecord(appId!, recordId)) as! GetRecordResponse
                let fileResults = getRecordResponse.getRecord()![attachmentField]!.getValue() as! [FileModel]

                for fileResult in fileResults {
                    fileKeys.append(fileResult.getFileKey()!)
                    if let downloadDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                        let filePath = downloadDir.appendingPathComponent(fileResult.getName()!)
                        fileModule.download(fileResult.getFileKey()!, filePath.absoluteString).then {
                            let actualResourcesFile = try! filePath.resourceValues(forKeys: [.fileSizeKey])
                            let actualFileName = filePath.lastPathComponent
                            let actualFileSize = actualResourcesFile.fileSize
                            let actualFileContent = try! String(contentsOf: filePath, encoding: String.Encoding.unicode)
                            expect(actualFileName).to(equal(expectedFileName))
                            expect(actualFileSize).to(equal(expectedFileSize))
                            expect(actualFileContent).to(equal(expectedFileContent))
                            }.catch {error in
                                expect(error).to(beNil())
                        }
                    }
                }
            }
            
            it("Test_007_Error_DownloadNoneExistFilePath") {
                for fileKey in fileKeys {
                    let result = TestCommonHandling.awaitAsync(fileModule.download(fileKey, "none_exist_file_path")) is NSError
                    expect(result).to(beTruthy())
                }
            }
            
            it("Test_008_Error_DownloadNonexistFileKey") {
                let nonexistentFileKey = "Nonexistent"
                let result = TestCommonHandling.awaitAsync(fileModule.download(nonexistentFileKey, "")) as! KintoneAPIException
                
                let actualError = result.getErrorResponse()
                var expectedError  = KintoneErrorParser.INCORRECT_FILE_KEY_DOWNLOAD()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: nonexistentFileKey)
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
    }
}
