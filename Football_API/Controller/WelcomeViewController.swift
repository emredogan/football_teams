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
    @IBOutlet weak var bioIDImage: UIImageView!
    
    // MARK: - VARIABLES
    private let verificationService: VerificationService = VerificationService()
    private let context = LAContext()
    
    static let validUsername = "EMREDOGAN"
    static let validPassword = "123456"
    
    // MARK: - LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLoginButton()
        prepareBiometricIDButton()
        playAnimation(name: "football", shouldLoop: false)
    }
    
    // MARK: - PREPARE USER INTERFACE
    func prepareLoginButton() {
        loginButton.layer.cornerRadius = 15
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func prepareBiometricIDButton() {
        switch(biometricType()) {
        case .none:
            bioIDImage.isHidden = true
        case .face:
            bioIDImage.image = UIImage(named: "faceID")
        case .touch:
            bioIDImage.image = UIImage(named: "touchID")
        }
        
        let tapGestureRecognizerFaceID = UITapGestureRecognizer(target: self, action: #selector(faceIDTapped))
        
        bioIDImage.isUserInteractionEnabled = true
        bioIDImage.addGestureRecognizer(tapGestureRecognizerFaceID)
    }
    
    // MARK: - HANDLE VIEW ACTIONS
    @objc func faceIDTapped() {
        
        let reason = "Please authorize Biometrics ID"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[weak self] success, error in
            DispatchQueue.main.async {
                guard success, error == nil else {
                    return
                }
                self?.pushViewController(viewController: TeamsViewController.self)
            }
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        do {
            let userName = try verificationService.verifyUsername(userNameTextView.text)
            let password = try verificationService.verifyPassword(passwordTextView.text)
            let isValid = try verificationService.verifyCredentials(userName, password)
            
            if isValid {
                self.pushViewController(viewController: TeamsViewController.self)
            }
            
        } catch let error as VerifyError {
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
    
    func biometricType() -> BiometricType {
        if #available(iOS 11, *) {
            let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(context.biometryType) {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
            default:
                return .none
            }
        } else {
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
        }
    }
    
    enum BiometricType {
        case none
        case touch
        case face
    }
}
