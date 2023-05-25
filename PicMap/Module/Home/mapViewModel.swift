//
//  mapViewModel.swift
//  PicMap
//
//  Created by 김진형 on 2023/05/25.
//

import Foundation
import SwiftyJSON
import Photos

final class mapViewModel {
    
    let api = ApiModel()
    var sema = DispatchSemaphore(value: 0)
    
    init() {}
    
    func getAllData() -> JSON {
        return api.getAll()
    }
    
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
