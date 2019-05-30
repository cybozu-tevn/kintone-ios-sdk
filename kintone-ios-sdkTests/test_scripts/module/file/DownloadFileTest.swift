///**
/**
 kintone-ios-sdkTests
 Created on 5/29/19
 */

import Foundation
import Quick
import Nimble
@testable import Promises
@testable import kintone_ios_sdk

class DownloadFileTest: QuickSpec {
    private var auth: Auth!
    private var fileModule: File!
    private var recordModule: Record!
    private var conn: Connection!
    private var recordId: Int!
    
    // the app has attachment field
    private let APP_ID: Int! = 33
    private let RECORD_TEXT_FIELD: String! = "Text"
    private let RECORD_ATTCHMENT_FIELD: String! = "Attachment"
    private var fileKeys: [String]! = []
    
    override func spec() {
        var expectedFileName: String!
        var expectedFileSize: Int!
        var expectedFileContent: String!
        
        beforeSuite {
            self.conn = TestCommonHandling.createConnection()
            self.recordModule = Record(self.conn)
            self.fileModule = File(self.conn)
            
            // Prepare test data
            let bundleUploadFile = Bundle(for: type(of: self))
            var recordTestData: [String: FieldValue] = [:]
            recordTestData = RecordUtils.setRecordData(recordTestData,
                                                       self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT,
                                                       "Upload single file")
            
            if let uploadFilePath = bundleUploadFile.url(forResource: "test", withExtension: "xlsx") {
                let resourcesFile = try! uploadFilePath.resourceValues(forKeys: [.fileSizeKey])
                expectedFileSize = resourcesFile.fileSize!
                expectedFileName = uploadFilePath.lastPathComponent
                expectedFileContent = try! String(contentsOf: uploadFilePath, encoding: String.Encoding.unicode)
                
                // Prepare upload files
                let uploadFileResponse1 = TestCommonHandling.awaitAsync(self.fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                let uploadFileResponse2 = TestCommonHandling.awaitAsync(self.fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                let fileList = [uploadFileResponse1, uploadFileResponse2]
                recordTestData = RecordUtils.setRecordData(recordTestData, self.RECORD_ATTCHMENT_FIELD, FieldType.FILE, fileList)
                
                // Upload files and get data
                let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, recordTestData)) as! AddRecordResponse
                self.recordId = addRecordResponse.getId()!
            }
        }
        
        describe("DowloadFile") {
            it("Test_006_Success_DowloadFile") {
                let getRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, self.recordId)) as! GetRecordResponse
                let fileResults = getRecordResponse.getRecord()![self.RECORD_ATTCHMENT_FIELD]!.getValue() as! [FileModel]
                for fileResult in fileResults {
                    self.fileKeys.append(fileResult.getFileKey()!)
                    if let downloadDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                        let filePath = downloadDir.appendingPathComponent(fileResult.getName()!)
                        self.fileModule.download(fileResult.getFileKey()!, filePath.absoluteString).then {
                            let actualResourcesFile = try! filePath.resourceValues(forKeys: [.fileSizeKey])
                            let actualFileName = filePath.lastPathComponent
                            let actualFileSize = actualResourcesFile.fileSize
                            let actualFileContent = try! String(contentsOf: filePath, encoding: String.Encoding.unicode)
                            expect(actualFileName).to(equal(expectedFileName))
                            expect(actualFileSize).to(equal(expectedFileSize))
                            expect(actualFileContent).to(equal(expectedFileContent))
                            }.catch {error in
                                dump(error)
                        }
                    }
                }
            }
            
            it("Test_007_Error_DownloadNoneExistFilePath") {
                for fileKey in self.fileKeys {
                    let result = TestCommonHandling.awaitAsync(self.fileModule.download(fileKey, "none_exist_file_path")) is NSError
                    expect(result).to(beTruthy())
                }
            }
            
            it("Test_008_Error_DownloadNonexistFileKey") {
                let nonexistentFileKey = "Nonexistent"
                let result = TestCommonHandling.awaitAsync(self.fileModule.download(nonexistentFileKey, "")) as! KintoneAPIException
                let actualError = result.getErrorResponse()
                var expectedError  = KintoneErrorParser.INCORRECT_FILE_KEY_DOWNLOAD()!
                expectedError.replaceMessage(oldTemplate: "%VARIABLE", newTemplate: nonexistentFileKey)
                
                TestCommonHandling.compareError(actualError, expectedError)
            }
        }
        
        afterSuite {
            // delete added test record
            _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [self.recordId!]))
        }
    }
}
