//
//  bottomsheetViewController.swift
//  PicMap
//
//  Created by akay on 2021/11/05.
//

import UIKit
import Firebase
import NMapsMap
import FirebaseFirestore

class bottomsheetViewController: UIViewController{
    let db = Firestore.firestore()
    var pic:PicData?
    var userid:String?
    var latS:String?
    var lngS:String?
    
    
    @IBOutlet weak var latBottom: UILabel!
    
    @IBOutlet weak var lonBottom: UILabel!
    
   
    @IBOutlet var imgView: UIImageView!
    @IBOutlet weak var IdBottom: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://picmap-viva.s3.ap-northeast-2.amazonaws.com/zzzz1014%40naver.com/129/2445527%20bytes.jpg")
       // Double(latData as! Substring)!
        IdBottom.text = "\(self.userid!)"
        latBottom.text = "\(self.latS!)"
        lonBottom.text = "\(self.lngS!)"
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.imgView.image = UIImage(data: data!)
            }
            
        }
        // 이미지 post된거 get함수 실행
        // 로컬의 이미지인지? 다른사람의 이미지인지 확인작업
        //
        //UIImage로 변환
        // 스택뷰 써서 넣기
        //
        
    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
        var paramSender1 = UIApplication.shared.delegate as? AppDelegate
        print("현재 경로이미지 : \(paramSender1!.latP)")
        imgView.image = UIImage(named:"https://picmap-viva.s3.ap-northeast-2.amazonaws.com/zzzz1014%40naver.com/129/2445527%20bytes.jpg")
      }
    
}
