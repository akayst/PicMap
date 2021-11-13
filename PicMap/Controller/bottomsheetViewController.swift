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
    
    
    @IBOutlet weak var latBottom: UILabel!
    
    @IBOutlet weak var lonBottom: UILabel!
    
    @IBOutlet weak var IdBottom: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    
       // Double(latData as! Substring)!
        IdBottom.text = "\(postData.userId!)"
        latBottom.text = "\(postData.latitude!)"
        lonBottom.text = "\(postData.longitude!)"
        // 이미지 post된거 get함수 실행
        // 로컬의 이미지인지? 다른사람의 이미지인지 확인작업
        //
        //UIImage로 변환
        // 스택뷰 써서 넣기
        //
        
    }
    
    
}
