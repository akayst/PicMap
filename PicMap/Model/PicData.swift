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
import FirebaseStorage
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
    
    /*
    func jsonParse(json:JSON)->PicData {
        let pic = PicData()
        pic.memo = json["memo"].stringValue
        pic.longitude = json["longitude"].stringValue
        pic.latitude = json["latitude"].stringValue

        if let user = UserDefaults.standard.string(forKey: "userEmail") {
            if user == json["ownerID"].stringValue {
                // userEmail == PicData.ownerID
                let id = json["localID"].stringValue
                let picc = PicData(localID: id)
                return picc
//                pic.localID = json["localID"].stringValue
//                let option = PHFetchOptions()
//                let result = PHAsset.fetchAssets(withLocalIdentifiers: [pic.localID!], options: option)
//                pic.asset = result[0]
//                return pic
            } else {
                // userEmail !- PicData.ownerID
                // Shared Picture
                
                return pic
            }
        } else {
            print("Failed Parse PicData from json!!!")
            return pic
        }
        
    }
    */
    
    func parseJson(_ json: JSON) {
        self.ownerID = json["userId"].stringValue
        self.markerId = json["id"].intValue
        self.latitude = json["latitude"].doubleValue
        self.longitude = json["longitude"].doubleValue
        self.memo = json["memo"].stringValue
<<<<<<< HEAD
        self.address = json["loadAddress"].stringValue
=======
>>>>>>> a6138c9d39e450fc3c2f356a8fec97737d68973c
        if let imgPaths = json["totalImageUrl"].string {
            self.imgPath = imgPaths.components(separatedBy: ";;")
        }
        
    }
    
    
    func getImage(size:CGSize) -> UIImage {
        var image = UIImage()
        if self.ownerID == UserDefaults.standard.string(forKey: "userEmail") {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            if self.asset != nil {
                manager.requestImage(for: self.asset!, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    image = result!
                })
            }
        } else {
            let storage = Storage.storage()
            let stoRef = storage.reference(forURL: "gs://pickimage-swift.appspot.com")
            let path:String = self.ownerID! + "/" + String(self.localID!)
            let picRef = stoRef.child(path)
            
            let serialQueue = DispatchQueue(label:"download")
            serialQueue.sync {
                picRef.getData(maxSize: 10*1024*1024, completion: { data, error in
                    if let error = error {
                        // download error
                        print("download error\n \(error)")
                    } else {
                        // downlaod successful
                        image = UIImage(data:data!)!
                    }
                })
            }
            serialQueue.sync {
                return image
            }
        }
        return image
    }
    
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
    
    /*
    func loadPath()->String {
        var path:String = ""
        self.asset?.requestContentEditingInput(with: PHContentEditingInputRequestOptions(), completionHandler: {(input, info) in
            if let url = input?.fullSizeImageURL {
                path = url.absoluteString
            }
        })
        self.OPath = path
        return self.OPath!
    }
     */
}
