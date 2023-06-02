//
//  NetworkError.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/01.
//

import Foundation

enum NetworkError: Error {
	case decode
	case invalidURL
	case noResponse
	case unauthorized
	case unexpectedStatusCode
	case unknown
}

extension NetworkError: LocalizedError {
	var errorDescription: String? {
		switch self {
			case .decode: return "데이터 디코딩 오류. Model을 확인해주세요"
			case .invalidURL: return "존재하지 않는 URL입니다."
			case .noResponse: return "요청 시간이 초과됐거나 서버가 응답하지 않습니다."
			case .unauthorized: return "허가되지 않는 요청입니다."
			case .unexpectedStatusCode: return "예상치 못한 오류가 발생했습니다."
			case .unknown: return "알 수 없는 오류가 발생했습니다."
		}
	}
}
