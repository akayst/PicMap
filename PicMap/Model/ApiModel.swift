//
//  userData.swift
//  PicMap
//
//  Created by akay on 2021/11/01.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import Photos
import NMapsMap


struct ApiModel{
    
    /*
    var userId:String?
    var localId:String?
    var ownerId:String?
    var longitude:Double?
    var latitude:Double?
    var memo :String?
    var loadAddress :String?
    var Opath:String?
    var date:Date?
    var markerId:Int?
 */
    var allJson:JSON?
    
    func getAll() -> JSON {
        let sema = DispatchSemaphore(value:0)
        var json:JSON = JSON()
        let url : String = "http://3.35.168.181/api/v1/record/get/" + UserDefaults.standard.string(forKey: "userEmail")! + "/"
        DispatchQueue.global().async {
            print("request now")
            AF.request(url,
                       method: .get,
                       parameters: nil,
                       encoding: JSONEncoding.default,
                       headers: ["Content-Type":"application/json","Accept":"application/json"]
            ).validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    print("parse response")
                    switch response.result {
                    case .success(let value) :
                        json = JSON(value)
                        print("succes")
                    case .failure(_) :
                        print("failed json")
                    }
                    sema.signal()
                }
        }
        sema.wait(timeout: .now()+5)
        print("json.count=\(json.count)")
        return json
    }
    
    func postMarker(_ pic:PicData) -> Int {
        var markerId:Int = 0
        let parameter: Parameters = [
            "userId":       pic.ownerID,
            "longitude":    pic.longitude!, // 로컬 이미지 선택후  메모 알람창이 뜨기직전에 저장됨
            "latitude":     pic.latitude!, // 로컬 이미지 선택 후 메모 알람창이 뜨기직전에 저장됨
            "memo":         pic.memo, // 메모알람창이 뜬 후 버튼클릭시에 저장됨
            //"loadAddress":postData.loadAddress
        ]
        let url: String = "http://3.35.168.181/api/v1/record"
        
        AF.request(url,
                   method: .post,
                    parameters: parameter,
                    encoding: JSONEncoding.default,
                    headers: ["Content-Type":"application/json",
                              "Accept":"application/json"
                    ]
        ).validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { (result) in
            let json = JSON(result.data)
            markerId = json["id"].intValue
            pic.markerId = markerId
            print("post result")
            print(result)
            print("id = \(markerId)")
            self.postImg(pic)
        })
        return markerId
    }
    
    func postImg(_ pic:PicData) {
        let url = "http://3.35.168.181/api/v1/record/post/images"
        
        let parameter: [String:Any] = ["userId": pic.ownerID!,
                                       "recordId": pic.markerId!]
        print("pic.ownerID = [\(pic.ownerID)]\npic.markerId = [\(pic.markerId)]")
        
        AF.upload(multipartFormData: { multipart in
            //IMAGE PART
            for (key,value) in parameter{
                if let temp = value as? String{
                    multipart.append(temp.data(using:.utf8)!, withName: key)
                }
                if let temp = value as? Int{
                    multipart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
            }
            
            if let data = pic.toData() {
                multipart.append(data, withName: "images", fileName: "\(data).jpg", mimeType: "images/jpeg")
            } else {
                print("failed picData to data")
                return
            }
            
        },
        to: url,
        headers: ["Content-Type" : "multipart/form-data"])
        .uploadProgress(queue: .main, closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }).responseJSON(completionHandler: { data in
            switch data.result {
            case .success(_) :
                print("img upload success")
            case .failure(let error) :
                print(error.localizedDescription)
            }
        })
    }
}

/*

func sendRequest(){ //로컬 이미지 선택 후 메모알람창까지 받은 후 api통신 포스트로 보냄
    //포스트 방식
    let paramter : Parameters = [
        "userId":postData.userId, //로그인,회원가입창에서 성공시 -> 데이터를 받아옴
        "longitude": postData.longitude, // 로컬 이미지 선택후  메모 알람창이 뜨기직전에 저장됨
        "latitude": postData.latitude, // 로컬 이미지 선택 후 메모 알람창이 뜨기직전에 저장됨
        "memo":postData.memo, // 메모알람창이 뜬 후 버튼클릭시에 저장됨
        "loadAddress":postData.loadAddress
    ]
    let url : String = "http://3.35.168.181/api/v1/record"
    
    AF.request(url,
               method: .post,
                parameters: paramter,
                encoding: JSONEncoding.default,
                headers: ["Content-Type":"application/json",
                          "Accept":"application/json"
                ]
    ).validate(statusCode: 200..<300)
    .responseJSON(completionHandler: {
        (response) in
        print(response)

    })
}




func getResponse(){
    let url : String = "http://3.35.168.181/api/v1/record/get-all"
    AF.request(url,
               method: .get,
               parameters: nil,
               encoding: JSONEncoding.default,
               headers: ["Content-Type":"application/json","Accept":"application/json"]
    ).validate(statusCode: 200..<300)
    .responseJSON { (response) in
        paramSender1!.memoP = response

    }
}

func parseJSON(_ response: DataResponse<Any,AFError>){ //테스트용 나중에 get할때 사용할 것 swiftyJSON
    switch response.result{
    case .success(_):
        if let json = try? JSON(data: response.data!){
            for (key, subJson):(String, JSON) in json {
                //let pic = PicData().jsonParse(json: subJson)
                let latP = subJson["latitude"].doubleValue
                let lonP = subJson["longitude"].doubleValue
                let userP = subJson["userId"].stringValue
                let memoP = subJson["memo"].stringValue
                
                print("\(latP)\(lonP)\(userP)\(memoP)")
                
                param.MyPics.append(PicData().jsonParse(json: subJson))
                
            }
        }
    case .failure(_):
        print("f")
    }
}

*/
