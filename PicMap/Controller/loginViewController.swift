//
//  loginViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import Firebase
import FirebaseAuth

class loginViewController: UIViewController{
    
 
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet var loginBtn: UIButton!
    
    override func viewDidLoad() {
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        self.navigationItem.title = ""
    }
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
                if let e = error{
                    print(e)
                    //self?.navigationController?.popViewController(animated: false) //로그인버튼누르면 걍 들어가져서 강제로 팝 뷰함 ->>2021.10.30버튼에서 뷰컨으로 세그를 건드는게 아니라 뷰컨에서 뷰컨으로 세그를 만들어야했었음 ;; 
                    
                }else{
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    self!.performSegue(withIdentifier: "loginToMap", sender: self)
                }
            }
        }
    }
}
