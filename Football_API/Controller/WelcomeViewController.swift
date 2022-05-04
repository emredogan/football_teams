//
//  WelcomeViewController.swift
//  Football_API
//
//  Created by Emre Dogan on 04/05/2022.
//

import UIKit
import Lottie

class WelcomeViewController: UIViewController {
    @IBOutlet weak var welcomeAnimationView: AnimationView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var getStartedStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLoginButton()
        playAnimation(name: "football", shouldLoop: false)
        
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
    }
    
    func prepareLoginButton() {
        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = 15
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.black.cgColor
    }
    
    
    func playAnimation(name: String, shouldLoop: Bool) {
        let animation = Animation.named(name)
        welcomeAnimationView.isHidden = false
        welcomeAnimationView.animation = animation
        if(shouldLoop) {
            welcomeAnimationView.loopMode = .loop

        } else {
            welcomeAnimationView.loopMode = .playOnce
        }
        welcomeAnimationView.play()
    }
}
