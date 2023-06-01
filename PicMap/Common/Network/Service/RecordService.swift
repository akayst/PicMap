//
//  RecordService.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/01.
//

import Foundation
import Combine

protocol RecordServiceable {
	func getRecordList(_ userId: String) -> AnyPublisher<[Record], NetworkError>
	func postRecord(_ requestRecord: RequestRecord) -> AnyPublisher<Record, NetworkError>
	func deleteRecord(_ recordId: Int) -> AnyPublisher<Bool, NetworkError>
	func postImages(_ formDatas: [String: Data]) -> AnyPublisher<ImageUploadResponse, NetworkError>
}

struct RecordService: HTTPClient, RecordServiceable {
	func getRecordList(_ userId: String) -> AnyPublisher<[Record], NetworkError> {
		return sendRequest(endPoint: RecordAPI.fetchMyMarkers(userId: userId), responseModel: [Record].self)
	}
	
	func postRecord(_ requestRecord: RequestRecord) -> AnyPublisher<Record, NetworkError> {
		return sendRequest(endPoint: RecordAPI.newRecord(requestRecord: requestRecord), responseModel: Record.self)
	}
	
	func deleteRecord(_ recordId: Int) -> AnyPublisher<Bool, NetworkError> {
		return sendRequest(endPoint: RecordAPI.deleteRecord(recordId: recordId), responseModel: Bool.self)
	}
	
	func postImages(_ formDatas: [String: Data]) -> AnyPublisher<ImageUploadResponse, NetworkError> {
		guard formDatas["images"] != nil,
			  formDatas["recordId"] != nil,
			  formDatas["userId"] != nil else {
			return AnyPublisher(Fail<ImageUploadResponse, NetworkError>(error: .decode))
		}
		
		return sendRequestMultiPart(endPoint: RecordAPI.uploadImages, body: formDatas ,responseModel: ImageUploadResponse.self)
	}
}
