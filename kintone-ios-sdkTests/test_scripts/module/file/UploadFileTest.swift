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
    private let APP_ID: Int! = TestConstant.InitData.APP_ID
    private let RECORD_TEXT_FIELD: String! = TestConstant.InitData.TEXT_FIELD
    private let RECORD_ATTACHMENT_FIELD: String! = TestConstant.InitData.ATTACHMENT_FIELD
    
    override func spec() {
        beforeSuite {
            self.conn = TestCommonHandling.createConnection()
            self.recordModule = Record(self.conn)
            self.fileModule = File(self.conn)
        }
        
        describe("UploadFile") {
            it("Test_002_003_Success_UploadFile") {
                let bundleUploadFile = Bundle(for: type(of: self))
                var recordTestData: [String: FieldValue] = [:]
                recordTestData = RecordUtils.setRecordData(recordTestData,
                                                           self.RECORD_TEXT_FIELD, FieldType.SINGLE_LINE_TEXT,
                                                           "Upload single file")
                
                if let uploadFilePath = bundleUploadFile.url(forResource: "test", withExtension: "txt") {
                    let resourcesFile = try! uploadFilePath.resourceValues(forKeys: [.fileSizeKey])
                    let expectedFileSize = resourcesFile.fileSize
                    let expectedFileName = uploadFilePath.lastPathComponent
                    let expectedFileContent = try! String(contentsOf: uploadFilePath, encoding: String.Encoding.unicode)
                    
                    // prepare upload files
                    let uploadFileResponse1 = TestCommonHandling.awaitAsync(self.fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                    let uploadFileResponse2 = TestCommonHandling.awaitAsync(self.fileModule.upload(uploadFilePath.absoluteString)) as! FileModel
                    let fileList = [uploadFileResponse1, uploadFileResponse2]
                    recordTestData = RecordUtils.setRecordData(recordTestData, self.RECORD_ATTACHMENT_FIELD, FieldType.FILE, fileList)
                    
                    //upload files and get data
                    let addRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.addRecord(self.APP_ID, recordTestData)) as! AddRecordResponse
                    self.recordId = addRecordResponse.getId()!
                    let getRecordResponse = TestCommonHandling.awaitAsync(self.recordModule.getRecord(self.APP_ID, self.recordId)) as! GetRecordResponse
                    let fileResults = getRecordResponse.getRecord()![self.RECORD_ATTACHMENT_FIELD]!.getValue() as! [FileModel]
                    for fileResult in fileResults {
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
                                    expect(error).to(beNil())
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
        }
        
        afterSuite {
            // delete added test record
            _ = TestCommonHandling.awaitAsync(self.recordModule.deleteRecords(self.APP_ID, [self.recordId!]))
        }
    }
}
