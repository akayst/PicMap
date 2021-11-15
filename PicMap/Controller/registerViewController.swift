//
//  registerViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import Firebase
class registerViewController: UIViewController{
    

    @IBOutlet weak var emailTextfield: UITextField!
    
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    
    @IBOutlet var registerBtn: UIButton!
    

    override func viewDidLoad() {
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
    }

    @IBAction func registerPressed(_ sender: Any) {
        if let email = emailTextfield.text , let password = passwordTextfield.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    //self.navigationController?.popViewController(animated: false) 회원가입버튼누르면 걍 들어가져서 강제로 팝 뷰함2021.10.30버튼에서 뷰컨으로 세그를 건드는게 아니라 뷰컨에서 뷰컨으로 세그를 만들어야했었음 ;; 
                    
                }else{
                    postData.userId = email
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    self.performSegue(withIdentifier: "registerToMap", sender: self)
                }
                
            }
        }
    }
}



