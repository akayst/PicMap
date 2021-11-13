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


var abc = mapViewController.self
var param = UIApplication.shared.delegate as! AppDelegate
struct postData{
    
    static var userId:String!
    static var localId:String!
    static var ownerId:String!
    static var longitude:Double!
    static var latitude:Double!
    static var memo :String?
    static var loadAddress :String!
    static var Opath:String!
    static var date:Date!
    
}

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

