//
//  PicData.swift
//  PicMap
//
//  Created by 송준기 on 2021/11/10.
//

import UIKit
import Photos
import SwiftyJSON
import Firebase
import NMapsMap


class PicData {
    var asset:PHAsset?
    var ownerID:String?
    var imgPath:[String] = []
    var localID:String?
    var latitude:Double?
    var longitude:Double?
    var address:String?
    var date:Date?
    var memo:String?
    var markerId:Int?
    var marker:NMFMarker?
    
   
    init(){
        self.asset = nil
    }
    init(json: JSON) {
        parseJson(json)
    }
    init(asset:PHAsset) {
        self.asset = asset
        self.localID = self.asset!.localIdentifier
        if let loc = self.asset!.location {
            self.latitude = Double(loc.coordinate.latitude)
            self.longitude = Double(loc.coordinate.longitude)
        }
        if let date = self.asset!.creationDate {
            self.date = date
        }
    }
    init(localID:String) {
        self.localID = localID
        let option = PHFetchOptions()
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [self.localID!], options: option)
        self.asset = result[0]
        
        if let loc = self.asset!.location {
            self.latitude = Double(loc.coordinate.latitude)
            self.longitude = Double(loc.coordinate.longitude)
        }
        if let userid = UserDefaults.standard.string(forKey: "userEmail") {
            self.ownerID = userid
        }
    }
    
    func parseJson(_ json: JSON) {
        self.ownerID = json["userId"].stringValue
        self.markerId = json["id"].intValue
        self.latitude = json["latitude"].doubleValue
        self.longitude = json["longitude"].doubleValue
        self.memo = json["memo"].stringValue
        self.address = json["loadAddress"].stringValue
        let tempPaths = json["totalImageUrl"].stringValue
        self.imgPath = tempPaths.components(separatedBy: ";;")
        self.imgPath.removeLast()
    }
    
    
//    func getImage(size:CGSize) -> UIImage {
//        var image = UIImage()
//        if self.ownerID == UserDefaults.standard.string(forKey: "userEmail") {
//            let manager = PHImageManager.default()
//            let option = PHImageRequestOptions()
//            option.isSynchronous = true
//            if self.asset != nil {
//                manager.requestImage(for: self.asset!, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
//                    image = result!
//                })
//            }
//        } else {
//            //let stoRef = storage.reference(forURL: "gs://pickimage-swift.appspot.com")
//            //let path:String = self.ownerID! + "/" + String(self.localID!)
//            //let picRef = stoRef.child(path)
//
//            let serialQueue = DispatchQueue(label:"download")
//            serialQueue.sync {
//                picRef.getData(maxSize: 10*1024*1024, completion: { data, error in
//                    if let error = error {
//                        // download error
//                        print("download error\n \(error)")
//                    } else {
//                        // downlaod successful
//                        image = UIImage(data:data!)!
//                    }
//                })
//            }
//            serialQueue.sync {
//                return image
//            }
//        }
//        return image
//    }
    
    func toData() -> Data? {
        if let asset = self.asset {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: option, resultHandler: { (result, info) -> Void in
                image = result!
            })
            return image.jpegData(compressionQuality: 0.8)!
        }
        return nil
    }
    
    func updateImgFromJSON(json:JSON) {
        if let imgPaths = json["imageUrl"].string {
            self.imgPath = imgPaths.components(separatedBy: ";;")
        }
    }
}
