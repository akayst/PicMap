//
//  bottomsheetViewController.swift
//  PicMap
//
//  Created by akay on 2021/11/05.
//

import UIKit
import Firebase
import NMapsMap


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
      
    }
    
    
}
