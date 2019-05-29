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

class UploadFileTest: QuickSpec {
    private var auth: Auth!
    private var fileModule: File!
    private var recordModule: Record!
    private var conn: Connection!
    private var recordId: Int!
    
    // the app has attachment field
    private let TEST_APP_ID: Int! = 33
    private let RECORD_TEXT_FIELD: String! = "Text"
    private let RECORD_ATTCHMENT_FIELD: String! = "Attachment"
    
    override func spec() {
        beforeSuite {
            self.auth = Auth().setPasswordAuth(TestConstant.Connection.ADMIN_USERNAME, TestConstant.Connection.ADMIN_PASSWORD)
            self.conn = Connection(TestConstant.Connection.DOMAIN, self.auth)
            self.recordModule = Record(self.conn)
            self.fileModule = File(self.conn)
        }
        
        describe("UploadFile") {
            it("Test_002_003_Success_UploadFile") {
                let bundleUploadFile = Bundle(for: type(of: self))
                var recordTestData: [String: FieldValue] = [:]
                recordTestData = TestCommonHandling.addData(recordTestData,
                                                            self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT,
                                                            "Upload single file")
                
                if let uploadFilePath = bundleUploadFile.url(forResource: "test", withExtension: "txt") {
                    let resourcesFile = try! uploadFilePath.resourceValues(forKeys: [.fileSizeKey])
                    let expectedFileSize = resourcesFile.fileSize
                    let expectedFileName = uploadFilePath.lastPathComponent
                    let expectedFileContent = try! String(contentsOf: uploadFilePath, encoding: String.Encoding.unicode)
                    
                    // prepare upload files
                    let uploadFileResponse = TestCommonHandling.awaitAsync(self.fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                    let uploadFileResponse2 = TestCommonHandling.awaitAsync(self.fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                    let fileList = [uploadFileResponse, uploadFileResponse2]
                    recordTestData = TestCommonHandling.addData(recordTestData, self.RECORD_ATTCHMENT_FIELD, FieldType.FILE, fileList)
                    
                    //upload files and get data
                    let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.TEST_APP_ID, recordTestData)) as! AddRecordResponse
                    self.recordId = addRecordResponse.getId()!
                    let getRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.TEST_APP_ID, self.recordId)) as! GetRecordResponse
                    let fileResults = getRecordResponse.getRecord()![self.RECORD_ATTCHMENT_FIELD]!.getValue() as! [FileModel]
                    for fileResult in fileResults {
                        if let downloadDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
                            let pathFileName = downloadDir.appendingPathComponent(fileResult.getName()!)
                            self.fileModule.download(fileResult.getFileKey()!, pathFileName.absoluteString).then {
                                let actualResourcesFile = try! pathFileName.resourceValues(forKeys: [.fileSizeKey])
                                let actualFileName = pathFileName.lastPathComponent
                                let actualFileSize = actualResourcesFile.fileSize
                                let actualFileContent = try! String(contentsOf: pathFileName, encoding: String.Encoding.unicode)
                                expect(expectedFileName).to(equal(actualFileName))
                                expect(expectedFileSize).to(equal(actualFileSize))
                                expect(expectedFileContent).to(equal(actualFileContent))
                                }.catch {error in
                                    dump(error)
                            }
                        }
                    }
                }
            }
            
            it("Test_004_Error_UploadNoneExistFilePath") {
                self.fileModule.upload("none_exist_file_path").catch { error in
                    expect(error).toNot(beNil())
                }
            }
            
            afterSuite {
                // delete added test record
                _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.TEST_APP_ID, [self.recordId!]))
            }
        }// End describe
    }// End spec func
}
