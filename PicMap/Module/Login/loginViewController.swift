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

final class loginViewController: UIViewController {
 
    @IBOutlet private weak var emailTextfield: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    @IBOutlet private weak var loginBtn: UIButton!
    @IBOutlet private weak var registerBtn: UIButton!

    @IBAction func googlebb(_ sender: Any) {
        let user = AppDelegate.user
        emailTextfield.text = user?.profile.email
    }
    
    @IBOutlet private weak var GsiBtn: GIDSignInButton!
	
	@Inject private var repository: Repository
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGoogleSign()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = AppDelegate.user
        emailTextfield.text = user?.profile.email
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)

    }
    
    private func setupView() {
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
        emailTextfield.backgroundColor = .lightGray
        passwordTextfield.backgroundColor = .lightGray
        emailTextfield.textAlignment = .center
        passwordTextfield.textAlignment = .center
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationItem.title = ""
    }
    
    private func setupGoogleSign() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        GsiBtn.style = .standard
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error {
                    print(e)
                } else {
                    UserDefaults.standard.set(email, forKey: "userEmail")
                    self?.performSegue(withIdentifier: "loginToMap", sender: self)
                }
            }
        }
    }
   
}
