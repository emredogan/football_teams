//
//  WelcomeViewController.swift
//  Football_API
//
//  Created by Emre Dogan on 04/05/2022.
//

import UIKit
import Lottie
import LocalAuthentication

class WelcomeViewController: UIViewController {
    
    // MARK: - IBOUTLETS
    @IBOutlet weak var welcomeAnimationView: AnimationView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var getStartedStackView: UIStackView!
    @IBOutlet weak var userNameTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var faceIDImage: UIImageView!
    
    // MARK: - VARIABLES
    private let verificationService: VerificationService = VerificationService()
    static let validUsername = "EMREDOGAN"
    static let validPassword = "123456"
    
    // MARK: - LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLoginButton()
        prepareFaceIDButton()
        playAnimation(name: "football", shouldLoop: false)
    }
    
    // MARK: - PREPARE USER INTERFACE
    func prepareLoginButton() {
        loginButton.layer.cornerRadius = 15
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func prepareFaceIDButton() {
        let tapGestureRecognizerFaceID = UITapGestureRecognizer(target: self, action: #selector(faceIDTapped))
        
        faceIDImage.isUserInteractionEnabled = true
        faceIDImage.addGestureRecognizer(tapGestureRecognizerFaceID)
    }
    
    // MARK: - HANDLE VIEW ACTIONS
    @objc func faceIDTapped() {
        let context = LAContext()
        var error: NSError? = nil
        
        // Check if the device can handle the bio functionality
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authorize Face ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[weak self] success, error in
                DispatchQueue.main.async {
                    guard success, error == nil else {
                        return
                    }
                    
                    // SHOW OTHER SCREEN
                    self?.pushViewController(viewController: TeamsViewController.self)
                }
            }
        } else {
            self.popupAlert(message: "Not possible to use biometrics")
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        do {
            let userName = try verificationService.verifyUsername(userNameTextView.text)
            let password = try verificationService.verifyPassword(passwordTextView.text)
            try verificationService.verifyCredentials(password, userName)
            
            if(userName.uppercased() == WelcomeViewController.validUsername && password == WelcomeViewController.validPassword) {
                self.pushViewController(viewController: TeamsViewController.self)
            }
        }catch let error as VerifyError {
            popupAlert(message: error.errorDesc)
        } catch {
            popupAlert(message: "Error while verifying the user")
        }
    }
    
    // MARK: APP FUNCTIONALITY
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
