//
//  RoadAddrResponse.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/08.
//

import Foundation

struct RoadAddrResponse: Codable {
	let addr: String
	let code: Int
	let reason: String
}
