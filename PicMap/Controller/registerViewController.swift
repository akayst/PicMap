//
//  registerViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import Firebase
import FirebaseAuth
class registerViewController: UIViewController{
    

    @IBOutlet weak var emailTextfield: UITextField!
    
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    
    @IBOutlet var registerBtn: UIButton!
    

    override func viewDidLoad() {
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
<<<<<<< HEAD
        emailTextfield.backgroundColor = .white
        passwordTextfield.backgroundColor = .white
        emailTextfield.textAlignment = .center
=======
        emailTextfield.borderStyle = .none
        passwordTextfield.borderStyle = .none
        let border = CALayer()
        let border2 = CALayer()
        border.frame = CGRect(x: 0, y: emailTextfield.frame.size.height-1, width: emailTextfield.frame.width, height: 1)
        border.backgroundColor = UIColor.black.cgColor
        border2.frame = CGRect(x: 0, y: passwordTextfield.frame.size.height-1, width: passwordTextfield.frame.width, height: 1)
        border2.backgroundColor = UIColor.black.cgColor
        emailTextfield.backgroundColor = .white
        passwordTextfield.backgroundColor = .white
        emailTextfield.layer.addSublayer(border)
        emailTextfield.textAlignment = .center
        passwordTextfield.layer.addSublayer(border2)
>>>>>>> 8077722f91575fa8f8969b220c19b2cd56b74a9a
        passwordTextfield.textAlignment = .center
    }

    @IBAction func registerPressed(_ sender: Any) {
        if let email = emailTextfield.text , let password = passwordTextfield.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    //self.navigationController?.popViewController(animated: false) 회원가입버튼누르면 걍 들어가져서 강제로 팝 뷰함2021.10.30버튼에서 뷰컨으로 세그를 건드는게 아니라 뷰컨에서 뷰컨으로 세그를 만들어야했었음 ;; 
                    
                }else{
                    
                    self.performSegue(withIdentifier: "registerToMap", sender: self)
                }
                
            }
        }
    }
}



