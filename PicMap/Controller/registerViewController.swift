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
        emailTextfield.backgroundColor = .white
        passwordTextfield.backgroundColor = .white
        emailTextfield.textAlignment = .center
        passwordTextfield.textAlignment = .center
    }

    @IBAction func registerPressed(_ sender: Any) {
        if let email = emailTextfield.text , let password = passwordTextfield.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                }else{
                    
                    self.performSegue(withIdentifier: "registerToMap", sender: self)
                }                
            }
        }
    }
}



