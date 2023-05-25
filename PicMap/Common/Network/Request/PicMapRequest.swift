//
//  PicMapRequest.swift
//  PicMap
//
//  Created by 김진형 on 2023/05/25.
//

import Foundation
import Alamofire
import SwiftyJSON

final class PicMapRequest {
    
    /*
     네트워크 요청 메소드 타입 열거형 선언
     
     - GET
     - POST
     - DELETE
     */
    
    /*
     SwiftyJSON -> Codable 로 변경예정
     
     - getAll
     - getAddr
     - postImage
     - deleteMarker
     
     */
    typealias Handler = (_ result: Bool, _ data: JSON?) -> (Bool, JSON?)
    
    func request(method: Alamofire.HTTPMethod, url: String, parameters: [String: AnyObject], headers: HTTPHeaders, handler: @escaping Handler) {
        DispatchQueue.global().async {
            print("requset Start")
            AF.request(url,
                       method: method,
                       parameters: parameters,
                       encoding: JSONEncoding.default,
                       headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                print("responseData")
                switch response.result {
                case .success(let datas):
                    handler(true, JSON(datas))
                case .failure(_):
                    handler(false, nil)
                    print("failed response")
                }
            }
        }
    }
    
    func multiPartRequest(_ data: Data?, url: String, parameters: [String: AnyObject], headers: HTTPHeaders, handler: @escaping Handler) {
        DispatchQueue.global().async {
            AF.upload(multipartFormData: { multipart in
                //IMAGE PART
                for (key,value) in parameters{
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
            }, to: url,
            headers: headers)
            .uploadProgress(queue: .main) { progress in
                print("upload Progress: \(progress.fractionCompleted)")
            }.responseJSON { response in
                switch response.result {
                case .success(let datas):
                    handler(true, JSON(datas))
                case .failure(let error):
                    handler(false, JSON(datas))
                    print(error.localizedDescription)
                }
            }
        }
        
    }
}
