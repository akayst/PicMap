//
//  Inject.swift
//  PicMap
//
//  Created by 송준기 on 2023/05/29.
//

import Foundation

/**
 # Inject
 ## 의존성 주입을 위한 프로퍼티 랩퍼 클래스
 - Precondition: AppDelegate 에서  DIContainer로 register()를 먼저 해주세요
 */
@propertyWrapper
public class Inject<T> {
	private var storage: T?
	
	private let container: DIContainer
	
	public init() {
		container = DIContainer.shared
	}
	
	public var wrappedValue: T {
		if let storage { return storage }
		let object: T = container.resolve()
		storage = object
		return object
	}
}
