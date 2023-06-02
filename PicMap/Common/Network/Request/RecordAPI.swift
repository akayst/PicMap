//
//  RecordService.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/01.
//

import Foundation


enum RecordAPI {
	case fetchMyMarkers(userId: String)
	case newRecord(requestRecord: RequestRecord)
	case deleteRecord(recordId: Int)
	case uploadImages
}

extension RecordAPI: EndPoint {
	var method: HTTPMethod {
		switch self {
			case .fetchMyMarkers:
				return .get
			case .newRecord, .uploadImages:
				return .post
			case .deleteRecord:
				return .delete
		}
	}
	
	var host: String {
		return "hyuny840501.cafe24.com"
	}
	
	var port: Int? {
		return 8081
	}
	
	var path: String {
		switch self {
			case .fetchMyMarkers(let userId):
				return "/pickmap/api/v1/record/get/\(userId)"
			case .newRecord:
				return "/pickmap/api/v1/record"
			case .deleteRecord(let recordId):
				return "/pickmap/api/v1/record/delete/\(recordId)"
			case .uploadImages:
				return "/pickmap/api/v1/record/post/images"
		}
	}
	
	var header: [String : String]? {
		switch self {
			case .uploadImages:
				return ["Content-Type": "multipart/form-data"]
			default:
				return ["Content-Type": "application/json"]
		}
	}
}
