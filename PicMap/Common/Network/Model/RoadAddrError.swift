//
//  RoadAddrError.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/02.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let roadAddressError = try? JSONDecoder().decode(RoadAddressError.self, from: jsonData)

import Foundation

	// MARK: - RoadAddressError
struct RoadAddressError: Codable {
	let error: RoadAddrError
	
	enum CodingKeys: String, CodingKey {
		case error = "error"
	}
}

	// MARK: - Error
struct RoadAddrError: Codable {
	let errorCode: String
	let message: String
	let details: String
	
	enum CodingKeys: String, CodingKey {
		case errorCode = "errorCode"
		case message = "message"
		case details = "details"
	}
}
