//
//  logoViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import SnapKit
import Lottie

final class logoViewController: UIViewController {
    
    @IBOutlet private weak var loginBtn: UIButton!
    @IBOutlet private weak var logoLb: UILabel!
    @IBOutlet private weak var logoViewContainer: UIView!
    
    private let lottieView = LottieAnimationView(name: "78072-map-pin-location")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLottieView()
        setupButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLottieView()
        setupButton()
    }
    
    private func setupButton() {
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
    }
    
    private func setupLottieView() {
        logoViewContainer.backgroundColor = .clear
        logoViewContainer.addSubview(lottieView)
        lottieView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.play()
        
    }
}
    

