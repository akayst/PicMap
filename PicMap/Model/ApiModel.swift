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
        print(url)
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
    
    func postMarker(_ pic: inout PicData) {
        let sema = DispatchSemaphore(value:0)
        var markerId:Int = 0
        let parameter: Parameters = [
            "userId":       pic.ownerID,
            "longitude":    pic.longitude!, // 로컬 이미지 선택후  메모 알람창이 뜨기직전에 저장됨
            "latitude":     pic.latitude!, // 로컬 이미지 선택 후 메모 알람창이 뜨기직전에 저장됨
            "memo":         pic.memo, // 메모알람창이 뜬 후 버튼클릭시에 저장됨
            "loadAddress":  pic.address!
        ]
        let url: String = "http://3.35.168.181/api/v1/record"
        DispatchQueue.global().async {
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
                print("post result")
                print(result)
                print("id = \(markerId)")
                sema.signal()
            })
        }
        sema.wait(timeout: .now() + 5)
        pic.markerId = markerId
        self.postImg(&pic)
    }
    
    func postImg(_ pic: inout PicData) {
        let sema = DispatchSemaphore(value: 0)
        let data = pic.toData()
        var resultPath = ""
        let url = "http://3.35.168.181/api/v1/record/post/images"
        let parameter: [String:Any] = ["userId": pic.ownerID!,
                                       "recordId": pic.markerId!]
        print("pic.ownerID = [\(pic.ownerID)]\npic.markerId = [\(pic.markerId)]")
        
        DispatchQueue.global().async {
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
                
                if data != nil {
                    multipart.append(data!, withName: "images", fileName: "\(data!).jpg", mimeType: "images/jpeg")
                } else {
                    print("failed picData to data")
                    return
                }
            },
            to: url,
            headers: ["Content-Type" : "multipart/form-data"])
            .uploadProgress(queue: .main, closure: { progress in
                print("Upload Progress: \(progress.fractionCompleted)")
            }).responseJSON(completionHandler: { (data) in
                switch data.result {
                case .success(let value) :
                    // pic update
                    let json = JSON(value)
                    print("img upload success")
                    for (_, subJson) : (String, JSON) in json {
                        resultPath = subJson["imageUrl"].stringValue
                    }
                    print("updated imgpath=\(resultPath)")
                case .failure(let error) :
                    print(error.localizedDescription)
                }
                sema.signal()
            })
        }
        sema.wait(timeout: .now() + 5)
        pic.imgPath.append(resultPath)
        print("after pic.imgPath=\(pic.imgPath)")
    }
    
    func getAddr(lng: Double, lat: Double) -> String {
        let sema = DispatchSemaphore(value: 0)
        var addr = String()
        let url = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?coords=" + String(lng) + "," + String(lat) + "&orders=addr&output=json"
        let header = HTTPHeaders(["X-NCP-APIGW-API-KEY-ID": "77l5jo9x2b", "X-NCP-APIGW-API-KEY": "lvZ2SejTt6MgwOtXjuNyRifmdmpl1DcLp1scu9KT"])
        DispatchQueue.global().async {
            AF.request(url,
                       method: .get,
                       parameters: nil,
                       encoding: JSONEncoding.default,
                       headers: header)
                .validate(statusCode: 200..<300)
                .responseJSON { (response) in
                    print("get addr")
                    var json = JSON(response.data!)
                    json = json["results"][0]
                    let region = json["region"]
                    for i in 1...4 {
                        let name = region["area"+String(i)]["name"].stringValue
                        if name.isEmpty {
                            continue
                        }
                        addr += name
                        addr += " "
                    }
                    let detail = json["land"]["number1"].stringValue
                    addr += detail
                    let addition = json["land"]["number2"].stringValue
                    if !addition.isEmpty {
                        addr += "-" + addition
                    }
                    sema.signal()
                }
        }
        sema.wait(timeout: .now() + 5)
        return addr
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
