//
//  registerViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import Firebase
import FirebaseAuth

final class registerViewController: UIViewController {
    
    @IBOutlet private weak var emailTextfield: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    @IBOutlet private weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
        emailTextfield.backgroundColor = .lightGray
        passwordTextfield.backgroundColor = .lightGray
        emailTextfield.textAlignment = .center
        passwordTextfield.textAlignment = .center
    }

    @IBAction func registerPressed(_ sender: Any) {
        if let email = emailTextfield.text , let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    self?.performSegue(withIdentifier: "registerToMap", sender: self)
                }                
            }
        }
    }
}



