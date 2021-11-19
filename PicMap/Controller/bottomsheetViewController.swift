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
    
    @IBOutlet weak var IdBottom: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    
       // Double(latData as! Substring)!
        IdBottom.text = "\(self.userid!)"
        latBottom.text = "\(self.latS!)"
        lonBottom.text = "\(self.lngS!)"
        // 이미지 post된거 get함수 실행
        // 로컬의 이미지인지? 다른사람의 이미지인지 확인작업
        //
        //UIImage로 변환
        // 스택뷰 써서 넣기
        //
    }
    
}
