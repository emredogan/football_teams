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
    @IBOutlet weak var welcomeAnimationView: AnimationView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var getStartedStackView: UIStackView!
    
    @IBOutlet weak var userNameTextView: UITextField!
    
    @IBOutlet weak var passwordTextView: UITextField!
    
    @IBOutlet weak var faceIDImage: UIImageView!
    
    
    private let verificationService: VerificationService
    
    init() {
        verificationService = VerificationService()
        super.init()
        //super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        verificationService = VerificationService()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLoginButton()
        prepareFaceIDButton()

        playAnimation(name: "football", shouldLoop: false)
    }

    
    @objc func faceIDTapped() {
        let context = LAContext()
        var error: NSError? = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authorize Face ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {[weak self] success, error in
                DispatchQueue.main.async {
                    guard success, error == nil else {
                        return
                    }
                    
                    // SHOW OTHER SCREEN
                    print("SUCCESS")
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! TeamsViewController
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        } else {
            // can't use
            print("NOT POSSIBLE")
        }
        
    }
    
    
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        do {
            let userName = try verificationService.verifyUsername(userNameTextView.text)
            let password = try verificationService.verifyPassword(passwordTextView.text)
            
            if(userName == "EMRE DOGAN" && password == "123456") {
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! TeamsViewController
                self.navigationController?.pushViewController(viewController, animated: true)
                
                
            }
            
        } catch VerifyError.emptyValue{
            
            let alert = UIAlertController(title: "Error", message: (VerifyError.emptyValue.errorDesc), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch VerifyError.nameTooShort{
            
            let alert = UIAlertController(title: "Error", message: (VerifyError.nameTooShort.errorDesc), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch VerifyError.nameTooLong{
            
            let alert = UIAlertController(title: "Error", message: (VerifyError.nameTooLong.errorDesc), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch VerifyError.passwordTooShort{
            
            let alert = UIAlertController(title: "Error", message: (VerifyError.passwordTooShort.errorDesc), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch VerifyError.passwordTooLong{
            
            let alert = UIAlertController(title: "Error", message: (VerifyError.passwordTooLong.errorDesc), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch {
            print(error)
        }
    }
    
    func prepareLoginButton() {
        // Do any additional setup after loading the view.
        loginButton.layer.cornerRadius = 15
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.black.cgColor
    }
    
    private func prepareFaceIDButton() {
        let tapGestureRecognizerFaceID = UITapGestureRecognizer(target: self, action: #selector(faceIDTapped))
        
        faceIDImage.isUserInteractionEnabled = true
        faceIDImage.addGestureRecognizer(tapGestureRecognizerFaceID)
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
