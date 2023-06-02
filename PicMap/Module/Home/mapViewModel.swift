//
//  mapViewModel.swift
//  PicMap
//
//  Created by 김진형 on 2023/05/25.
//

import Foundation
import Photos
import Combine
import FirebaseAuth
import BSImagePicker

enum mapViewModelMessage {
    enum Action {
        case getAllData
        case getAddr
        case postMarker(picData: PicData?)
        case deleteMarker(markerId: Int)
        case postImage(markerId: Int, isNewMarker: Bool, picData: PicData?, images: Data?)
        case fetchMarker
    }
    
    enum ViewState {
        case loading
        case presenting
    }
}

final class mapViewModel {
	@Inject private var repository: Repository
    let input = PassthroughSubject<mapViewModelMessage.Action, Never>()
    let output = PassthroughSubject<mapViewModelMessage.ViewState, Never>()
    var picDatas: [PicData] = []
    
    private var subscription = Set<AnyCancellable>()
    let api = ApiModel()
    var sema = DispatchSemaphore(value: 0)
	
    
    init() {
		bind()
		repository.fetchMarkers()
		getAddr(lng: 127.1114893, lat: 37.3614463)
		repository.getRoadAddrFromCoordinate(lat: 37.3614463, lng: 127.1114893) { addr in
			print("도로명주소:\(addr)")
		}
	}
	
	private func bind() {
		input
			.sink { [weak self] input in
				self?.processInput(input)
			}
			.store(in: &subscription)
		repository.output
			.sink { output in
				switch output {
					case .fetchedMarker(let picDatas):
						self.picDatas = picDatas
					case .postedMarker:
						print("-> 7870 postedMarker 성공")
					case .deletedMarker:
						print("-> 7870 deletedmarker 성공")
					default:
						break
				}
			}.store(in: &subscription)
	}
	
	private func processInput(_ input: mapViewModelMessage.Action) {
		switch input {
			case .fetchMarker:
				repository.input.send(.fetchMarker)
			case .postMarker(let picData):
				guard let picData = picData else { return }
				let requestModel = RequestRecord(userId: picData.ownerID ?? "",
												 longitude: picData.longitude ?? 0.0,
												 latitude: picData.latitude ?? 0.0,
												 memo: picData.memo ?? "",
												 loadAddress: picData.address ?? "")
				repository.input.send(.postMarker(record: requestModel))
			case .deleteMarker(let markerId):
				repository.input.send(.deleteMarker(markerId: markerId))
			case .postImage(let markerId, let isNewMarker, var picData, var data):
				repository.input.send(isNewMarker
									  ? .uploadImageWithNewMarker(markerId: markerId, images: data)
									  : .uploadImage(markerId: markerId, images: picData))
			default:
				break
		}
	}
 
//    func getAllData() -> JSON {
//        return api.getAll()
//    }
    
    func getAddr(lng: Double, lat: Double) -> String? {
        return api.getAddr(lng: lng, lat: lat)
    }
//
//    func postMarker(_ pic: inout PicData) {
//        return api.postMarker(&pic)
//    }
//
    func postImage(_ pic: inout PicData) {
        return api.postImg(&pic)
    }
}
