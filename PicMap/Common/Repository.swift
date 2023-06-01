//
//  Repository.swift
//  PicMap
//
//  Created by 송준기 on 2023/05/27.
//

import Foundation
import Combine

final class Repository {
	var userInfo: UserInfo
	var myPics: [PicData]
	var imgPics: [String]
	
	@Inject private var recordService: RecordService
	private var subscription = Set<AnyCancellable>()
	
	init() {
		let id = UserDefaults.standard.string(forKey: "userEmail") ?? ""
		userInfo = UserInfo(userId: id)
		myPics = []
		imgPics = []
	}
	
	
	func setUserInfo(_ userId: String) {
		if userId.isEmpty {
			UserDefaults.standard.removeObject(forKey: "userEmail")
		}
		UserDefaults.standard.set(userId, forKey: "userEmail")
		userInfo = UserInfo(userId: userId)
	}
	
	var userId: String {
		return userInfo.userId
	}
	
	func fetchMarkers() {
		recordService.getRecordList(userId)
			.sink { response in
				switch response {
					case .failure(let err):
						print(err)
					case .finished:
						return
				}
			} receiveValue: { result in
				self.myPics.append(contentsOf: result.map { PicData(record: $0, isMine: $0.userID == self.userId) })
			}.store(in: &subscription)
	}
	
	func newMarkers(_ newMarker: RequestRecord) {
		recordService.postRecord(newMarker)
			.sink { response in
				switch response {
					case .failure(let err):
						print(err)
					case .finished:
						return
				}
			} receiveValue: { result in
				self.myPics.append(PicData(record: result))
			}.store(in: &subscription)
	}
	
	func deleteMarker(markerId: Int) {
		recordService.deleteRecord(markerId)
			.sink { response in
				switch response {
					case .failure(let err):
						print(err)
					case .finished:
						return
				}
			} receiveValue: { isDelete in
				if isDelete {
					print("Deleted record \(markerId).")
				}
			}.store(in: &subscription)
	}
	
	func uploadImage(images: Data, markerId: Int) {
		var formDatas = [String: Data]()
		
		formDatas.updateValue(images, forKey: "images")
		formDatas.updateValue(markerId.description.data(using: .utf8)!, forKey: "recordId")
		formDatas.updateValue(userId.data(using: .utf8)!, forKey: "userId")
		
		recordService.postImages(formDatas)
			.sink { response in
				switch response {
					case .failure(let err):
						print(err)
					case .finished:
						return
				}
			} receiveValue: { result in
				// image upload success
			}.store(in: &subscription)
	}
	
	func uploadImage(images: PicData, markerId: Int) {
		var formDatas = [String: Data]()
		
		guard let imgData = images.toData() else {
			return
		}
		
		formDatas.updateValue(imgData, forKey: "images")
		formDatas.updateValue(markerId.description.data(using: .utf8)!, forKey: "recordId")
		formDatas.updateValue(userId.data(using: .utf8)!, forKey: "userId")
		
		recordService.postImages(formDatas)
			.sink { response in
				switch response {
					case .failure(let err):
						print(err)
					case .finished:
						return
				}
			} receiveValue: { result in
					// image upload success
			}.store(in: &subscription)
	}
}
