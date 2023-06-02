//
//  Repository.swift
//  PicMap
//
//  Created by 송준기 on 2023/05/27.
//

import Foundation
import Combine

enum RepositryMessage {
    enum Input {
        case fetchMarker
        case postMarker(record: RequestRecord)
        case deleteMarker(markerId: Int)
        case uploadImageWithNewMarker(markerId: Int, images: Data?)
        case uploadImage(markerId: Int, images: PicData?)
    }
    
    enum output {
        case fetchedMarker(picDatas: [PicData])
        case postedMarker
        case deletedMarker
        case uploadedImage
    }
}

protocol RepositoryInterface: BaseRepository where Input == RepositryMessage.Input, Output == RepositryMessage.output {}

final class Repository: RepositoryInterface {
    
    typealias Input = RepositryMessage.Input
    typealias Output = RepositryMessage.output
    
    @Inject private var recordService: RecordService
    
	var userInfo: UserInfo
	var myPics: [PicData]
	var imgPics: [String]
    var input = PassthroughSubject<Input, Never>()
    var output = PassthroughSubject<Output, Never>()
	private var subscription = Set<AnyCancellable>()
	
    var userId: String {
        return userInfo.userId
    }
    
	init() {
		let id = UserDefaults.standard.string(forKey: "userEmail") ?? ""
		userInfo = UserInfo(userId: id)
		myPics = []
		imgPics = []
        bind()
	}
	
    private func bind() {
        input
            .sink { [weak self] input in
                self?.processInput(input)
            }.store(in: &subscription)
    }
    
    private func processInput(_ input: Input) {
        switch input {
        case .fetchMarker:
            fetchMarkers()
        case .postMarker(let record):
            postMarker(record)
        case .deleteMarker(let markerId):
            deleteMarker(markerId: markerId)
        case .uploadImage(let markerId, let images):
            uploadImage(images: images, markerId: markerId)
        case .uploadImageWithNewMarker(let markerId, let images):
            uploadImage(images: images, markerId: markerId)
        }
    }
    
	func setUserInfo(_ userId: String) {
		UserDefaults.standard.set(userId, forKey: "userEmail")
		userInfo = UserInfo(userId: userId)
	}
}

//MARK: - Repository Implement
private extension Repository {
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
                self.myPics = result.map { PicData(record: $0, isMine: $0.userId == self.userId) }
                self.output.send(.fetchedMarker(picDatas: self.myPics))
            }.store(in: &subscription)
    }
    
    func postMarker(_ postMarker: RequestRecord) {
        recordService.postRecord(postMarker)
            .sink { response in
                switch response {
                    case .failure(let err):
                        print(err)
                    case .finished:
                        return
                }
            } receiveValue: { result in
                self.myPics.append(PicData(record: result))
                self.output.send(.postedMarker)
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
    
    func uploadImage(images: Data?, markerId: Int) {
        guard let images = images else { return }
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
    
    func uploadImage(images: PicData?, markerId: Int) {
        guard let images = images, let imgData = images.toData() else { return }
        var formDatas = [String: Data]()
        
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
