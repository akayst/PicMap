//
//  loginViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class loginViewController: UIViewController{
    
 
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet var loginBtn: UIButton!
    
    @IBOutlet var registerBtn: UIButton!

    
    @IBOutlet var googleLoginBtn: UIView!
 
    @IBAction func googlebb(_ sender: Any) {
        let user = AppDelegate.user
        GIDSignIn.sharedInstance().signIn()
        emailTextfield.text = user?.profile.email
    }
    override func viewDidLoad() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        navigationController?.setNavigationBarHidden(true, animated: false)
        //if let _ = UserDefaults.standard.string(forKey: "userEmail") {
       //     performSegue(withIdentifier: "preLoginToMap", sender: self)
       // }
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
        emailTextfield.backgroundColor = .white
        passwordTextfield.backgroundColor = .white
        emailTextfield.textAlignment = .center
        passwordTextfield.textAlignment = .center
        self.navigationItem.title = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = AppDelegate.user
        emailTextfield.text = user?.profile.email
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
