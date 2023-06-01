	//
	//  Record.swift
	//  PicMap
//
//  Created by 송준기 on 2023/06/01.
//

// 	This file was generated from JSON Schema using quicktype, do not modify it directly.
// 	To parse the JSON, add this file to your project and do:
//
//  let record = try? JSONDecoder().decode(Record.self, from: jsonData)

import Foundation

// MARK: - Record
struct Record: Codable {
	var id: Int
	var latitude: Double
	var loadAddress: String
	var longitude: Double
	var memo: String
	var totalImageURL: String = ""
	var userID: String
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case latitude = "latitude"
		case loadAddress = "loadAddress"
		case longitude = "longitude"
		case memo = "memo"
		case totalImageURL = "totalImageUrl"
		case userID = "userId"
	}
}
