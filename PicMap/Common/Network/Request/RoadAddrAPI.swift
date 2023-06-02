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
		return "https"
	}
	
	var host: String {
		return "naveropenapi.apigw.ntruss.com"
	}
	
	var path: String {
		return "/map-reversegeocode/v2/gc"
	}
	
	var method: HTTPMethod {
		return .get
	}
	
	var header: [String : String]? {
		return ["Accept": "*/*",
				"Content-Type": "application/json",
				"X-NCP-APIGW-API-KEY": "lvZ2SejTt6MgwOtXjuNyRifmdmpl1DcLp1scu9KT",
				"X-NCP-APIGW-API-KEY-ID": "77l5jo9x2b"]
	}
}
