//
//  RoadAddrService.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/02.
//

import Foundation
import Combine

protocol RoadAddrServiceable {
	func revGeocoding(_ lat: Double, _ lng: Double) -> AnyPublisher<RoadAddrResponse, NetworkError>
}

struct RoadAddrService: HTTPClient, RoadAddrServiceable {
	func revGeocoding(_ lat: Double, _ lng: Double) -> AnyPublisher<RoadAddrResponse, NetworkError> {
		return sendRequest(endPoint: RoadAddrAPI.getRoadAddr(lat: lat, lng: lng),
						   params: ["lat": lat.description,
									"lng": lng.description],
						   responseModel: RoadAddrResponse.self)
	}
}
