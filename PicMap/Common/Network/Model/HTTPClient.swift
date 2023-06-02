	//
	//  Provider.swift
	//  PicMap
	//
	//  Created by 송준기 on 2023/06/01.
	//

import Foundation
import Combine

protocol HTTPClient {
	func sendRequest<T: Decodable>(endPoint: EndPoint,
								   params: [String: String]?,
								   body: [String: AnyObject]?,
								   responseModel: T.Type) -> AnyPublisher<T, NetworkError>
	
	func sendRequestMultiPart<T: Decodable>(endPoint: EndPoint,
											params: [String: String]?,
											body: [String: Data]?,
											responseModel: T.Type) -> AnyPublisher<T, NetworkError>
}

extension HTTPClient {
	func sendRequest<T: Decodable>(endPoint: EndPoint,
								   params: [String: String]? = nil,
								   body: [String: AnyObject]? = nil,
								   responseModel: T.Type) -> AnyPublisher<T, NetworkError> {
		var urlComponents = URLComponents()
		urlComponents.scheme = endPoint.scheme
		urlComponents.host = endPoint.host
		urlComponents.port = endPoint.port
		urlComponents.path = endPoint.path
		urlComponents.queryItems = params?.map { URLQueryItem(name: $0.key, value: $0.value) }
		
		guard let url = urlComponents.url else {
			return AnyPublisher(Fail<T, NetworkError>(error: .invalidURL))
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = endPoint.method.rawValue
		request.allHTTPHeaderFields = endPoint.header
		
		if let body = body {
			request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
		}
		
		
		return URLSession.shared
			.dataTaskPublisher(for: url)
			.tryMap { output in
				guard output.response is HTTPURLResponse else {
					throw NetworkError.unknown
				}
				return output.data
			}
			.decode(type: T.self, decoder: JSONDecoder())
			.mapError { error in
				print(error.localizedDescription)
				return NetworkError.unexpectedStatusCode
			}
			.eraseToAnyPublisher()
	}
	
	func sendRequestMultiPart<T: Decodable>(endPoint: EndPoint,
											params: [String: String]? = nil,
											body: [String: Data]? = nil,
											responseModel: T.Type) -> AnyPublisher<T, NetworkError> {
		var urlComponents = URLComponents()
		urlComponents.scheme = endPoint.scheme
		urlComponents.host = endPoint.host
		urlComponents.port = endPoint.port
		urlComponents.path = endPoint.path
		urlComponents.queryItems = params?.map { URLQueryItem(name: $0.key, value: $0.value) }
		
		guard let url = urlComponents.url else {
			return AnyPublisher(Fail<T, NetworkError>(error: .invalidURL))
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = endPoint.method.rawValue
		request.allHTTPHeaderFields = endPoint.header
		
		guard let body = body else {
			return AnyPublisher(Fail<T, NetworkError>(error: .decode))
		}
		
		let boundary = "Boundary-\(UUID().uuidString)"
		request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		
		
		request.httpBody = body.reduce(into: Data()) { (result: inout Data, elem: Dictionary<String, Data>.Element) in
			let boundaryPrefix = "--\(boundary)\r\n"
			
			result.append(boundaryPrefix.data(using: .utf8)!)
			result.append("Content-Disposition: form-data; name=\"\(elem.key)\"".data(using: .utf8)!)
			
			if elem.key == "images" {
				result.append("; filename=\"\(UUID().uuidString).jpg\"\r\n".data(using: .utf8)!)
				result.append(elem.value)
			} else {
				result.append("\r\n".data(using: .utf8)!)
				result.append(elem.value)
				result.append("\r\n".data(using: .utf8)!)
			}
			result.append("\(boundary)".data(using: .utf8)!)
		}
		request.httpBody?.append("--\r\n\r\n".data(using: .utf8)!)
		
		
		return URLSession.shared
			.dataTaskPublisher(for: url)
			.tryMap { output in
				guard output.response is HTTPURLResponse else {
					throw NetworkError.unknown
				}
				return output.data
			}
			.decode(type: T.self, decoder: JSONDecoder())
			.mapError { error in
				print(error.localizedDescription)
				return NetworkError.unexpectedStatusCode
			}
			.eraseToAnyPublisher()
	}
}



