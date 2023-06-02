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


final class mapViewModel {
    
	@Inject private var repository: Repository
    let api = ApiModel()
    var sema = DispatchSemaphore(value: 0)
	
    
    init() {
		repository.fetchMarkers()
		getAddr(lng: 127.1114893, lat: 37.3614463)
		repository.getRoadAddrFromCoordinate(lat: 37.3614463, lng: 127.1114893) { addr in
			print("도로명주소:\(addr)")
		}
	}
	
	func floatyLogout(successHandler: @escaping () -> Void) {
		do {
			try Auth.auth().signOut()
			successHandler()
		} catch {
			print("로그아웃에 실패했습니다.")
			print(error.localizedDescription)
		}
	}
	
	func floatyUpload(_ vc: inout UIViewController, alertHandler: @escaping () -> Void) {
		let imagePicker = ImagePickerController(selectedAssets: [PHAsset]())
		imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
		imagePicker.settings.selection.max = 5 // 이미지 피커의 선택 갯수제한 5장
		
		vc.presentImagePicker(imagePicker, select: nil, deselect: nil, cancel: nil) { assets in
			assets.forEach { asset in
				let picData = PicData(asset: asset)
				
				self.repository.myPics.append(picData)
			}
		}
		
	}
	
	
	func showSimpleAlert(title: String, message: String, vc: inout UIViewController) {
		let alert = UIAlertController()
		alert.title = title
		alert.message = message
		alert.addAction(UIAlertAction(title: "확인", style: .cancel))
	}
	
	func showAdvancedAlert(_ alert: UIAlertController, vc: inout UIViewController) {
		
	}
 
//    func getAllData() -> JSON {
//        return api.getAll()
//    }
    
    func getAddr(lng: Double, lat: Double) -> String? {
        return api.getAddr(lng: lng, lat: lat)
    }
    
    func postMarker(_ pic: inout PicData) {
        return api.postMarker(&pic)
    }
    
    func postImage(_ pic: inout PicData) {
        return api.postImg(&pic)
    }
}
