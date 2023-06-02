//
//  RoadAddrService.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/02.
//

import Foundation
import Combine

protocol RoadAddrServiceable {
	func geocoding(_ lat: Double, _ lng: Double) -> AnyPublisher<RoadAddressError, NetworkError>
}

struct RoadAddrService: HTTPClient, RoadAddrServiceable {
	func geocoding(_ lat: Double, _ lng: Double) -> AnyPublisher<RoadAddressError, NetworkError> {
		return sendRequest(endPoint: RoadAddrAPI.getRoadAddr(lat: lat, lng: lng),
						   params: ["coords": "\(lng),\(lat)",
									"orders": "addr",
									"output": "json"],
						   responseModel: RoadAddressError.self)
	}
}
