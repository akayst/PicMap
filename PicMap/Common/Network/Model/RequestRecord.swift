//
//  RequestRecord.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/01.
//

import Foundation

struct RequestRecord: Codable {
	var userId: String
	var longitude: Double
	var latitude: Double
	var memo: String
	var loadAddress: String
	
	enum CodingKeys: String, CodingKey {
		case userId = "userId"
		case longitude = "longitude"
		case latitude = "latitude"
		case memo = "memo"
		case loadAddress = "loadAddress"
	}
}
