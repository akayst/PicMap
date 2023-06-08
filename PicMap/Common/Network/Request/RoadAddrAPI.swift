//
//  RoadAddrAPI.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/02.
//

import Foundation

enum RoadAddrAPI {
	case getRoadAddr(lat: Double, lng: Double)
}

extension RoadAddrAPI: EndPoint {
	var scheme: String {
		return "http"
	}
	
	var host: String {
		return "hyuny840501.cafe24.com"
	}
	
	var path: String {
		return "/pickmap/api/v1/gc/rev"
	}
	
	var port: Int? {
		return 8081
	}
	
	var method: HTTPMethod {
		return .get
	}
	
	var header: [String : String]? {
		return nil
	}
}
