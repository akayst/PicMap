//
//  RoadAddressResponse.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/02.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let roadAddressResponse = try? JSONDecoder().decode(RoadAddressResponse.self, from: jsonData)

import Foundation

	// MARK: - RoadAddressResponse
struct RoadAddressResponse: Codable {
	let status: Status
	let results: [Result]
	
	enum CodingKeys: String, CodingKey {
		case status = "status"
		case results = "results"
	}
}

	// MARK: - Result
struct Result: Codable {
	let name: String
	let code: Code
	let region: Region
	let land: Land
	
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case code = "code"
		case region = "region"
		case land = "land"
	}
}

	// MARK: - Code
struct Code: Codable {
	let id: String
	let type: String
	let mappingID: String
	
	enum CodingKeys: String, CodingKey {
		case id = "id"
		case type = "type"
		case mappingID = "mappingId"
	}
}

	// MARK: - Land
struct Land: Codable {
	let type: String
	let number1: String
	let number2: String
	let addition0: Addition
	let addition1: Addition
	let addition2: Addition
	let addition3: Addition
	let addition4: Addition
	let name: String
	let coords: Coords
	
	enum CodingKeys: String, CodingKey {
		case type = "type"
		case number1 = "number1"
		case number2 = "number2"
		case addition0 = "addition0"
		case addition1 = "addition1"
		case addition2 = "addition2"
		case addition3 = "addition3"
		case addition4 = "addition4"
		case name = "name"
		case coords = "coords"
	}
}

	// MARK: - Addition
struct Addition: Codable {
	let type: String
	let value: String
	
	enum CodingKeys: String, CodingKey {
		case type = "type"
		case value = "value"
	}
}

	// MARK: - Coords
struct Coords: Codable {
	let center: Center
	
	enum CodingKeys: String, CodingKey {
		case center = "center"
	}
}

	// MARK: - Center
struct Center: Codable {
	let crs: String
	let x: Double
	let y: Double
	
	enum CodingKeys: String, CodingKey {
		case crs = "crs"
		case x = "x"
		case y = "y"
	}
}

	// MARK: - Region
struct Region: Codable {
	let area0: Area
	let area1: Area1
	let area2: Area
	let area3: Area
	let area4: Area
	
	enum CodingKeys: String, CodingKey {
		case area0 = "area0"
		case area1 = "area1"
		case area2 = "area2"
		case area3 = "area3"
		case area4 = "area4"
	}
}

	// MARK: - Area
struct Area: Codable {
	let name: String
	let coords: Coords
	
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case coords = "coords"
	}
}

	// MARK: - Area1
struct Area1: Codable {
	let name: String
	let coords: Coords
	let alias: String
	
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case coords = "coords"
		case alias = "alias"
	}
}

	// MARK: - Status
struct Status: Codable {
	let code: Int
	let name: String
	let message: String
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case name = "name"
		case message = "message"
	}
}



extension RoadAddressResponse {
	var getFullRoadAddress: String {
		guard let region = self.results.first?.region else {
			print(self)
			print("region is nil")
			return "--"
		}
		
		guard let land = self.results.first?.land else {
			return "--"
		}
		
		
		return "\(region.area1.name) \(region.area2.name) \(region.area3.name) \(region.area4.name) \(land.number1)-\(land.number2)"
	}
}
