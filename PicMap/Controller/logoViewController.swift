//
//  logoViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import Lottie


class logoViewController: UIViewController{
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var logoLb: UILabel!

    
    @IBOutlet var test123: AnimationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = UserDefaults.standard.string(forKey: "userEmail") {
            performSegue(withIdentifier: "preLoginToMap", sender: self)
        }
        
        test123.contentMode = .scaleAspectFit
        //test123.loopMode = .loop
        test123.play()
        registerBtn.layer.cornerRadius = 10
        loginBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
        loginBtn.clipsToBounds = true

    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        test123.contentMode = .scaleAspectFit
        //test123.loopMode = .loop
        test123.play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
    

