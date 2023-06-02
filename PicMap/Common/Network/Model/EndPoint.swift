//
//  EndPoint.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/01.
//

import Foundation

protocol EndPoint {
	var scheme: String { get }
	var host: String { get }
	var port: Int? { get }
	var path: String { get }
	var method: HTTPMethod { get }
	var header: [String: String]? { get }
	var requestTimeOut: Float { get }
}

extension EndPoint {
	var scheme: String {
		return "http"
	}

	var port: Int? {
		return nil
	}
	
	var requestTimeOut: Float {
		return 15.0
	}
}
