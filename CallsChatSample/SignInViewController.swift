//
//  SignInViewController.swift
//  CallsChatSample
//
//  Created by Minhyuk Kim on 2024/05/31.
//

import UIKit
import SendbirdUIKit
import SendBirdCalls

class SignInViewController: UIViewController {
//    @IBOutlet weak var appIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var accessTokenTextField: UITextField!

    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.userIdTextField.text = UserDefaults.standard.value(forKey: "userId") as? String
        self.accessTokenTextField.text = UserDefaults.standard.value(forKey: "accessToken") as? String
//        self.appIdTextField.text = UserDefaults.standard.value(forKey: "applicationId") as? String
        self.versionLabel.text = "SDK Calls v\(SendBirdCall.sdkVersion) UIKit v\(SendbirdUI.shortVersion)"
    }
    
    // MARK: - ManualSignInDelegate
    @IBAction func didTapSignIn() {
//        guard let appId = self.appIdTextField.text else {
//            self.presentErrorAlert(message: "Please enter valid app ID")
//            return
//        }
        guard let userId = self.userIdTextField.text else {
            self.presentErrorAlert(message: "Please enter valid user ID")
            return
        }
        let accessToken = self.accessTokenTextField.text?.isEmpty == true ? nil : self.accessTokenTextField.text

        self.signIn(userId: userId, accessToken: accessToken)
    }

    func signIn(userId: String, accessToken: String?) {
        SendBirdCall.executeOn(queue: .main)
        
        SBUModuleSet.GroupChannelModule.InputComponent = CustomInputComponent.self
        SBUModuleSet.GroupChannelModule.ListComponent = CustomListComponent.self
        SBUViewControllerSet.GroupChannelViewController = CustomGroupChannelViewController.self
        
        self.signInButton.isEnabled = false
        
        let config = ConnectionManager.Config(userId: userId, accessToken: accessToken)
        ConnectionManager.connect(config: config) { error in
            
            self.signInButton.isEnabled = true
            
            if let error = error {
                self.presentErrorAlert(message: error.localizedDescription)
                return
            }
            
            let mainVC = MainChannelTabbarController()
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension SignInViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
            textField.layer.borderWidth = 0.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
        textField.resignFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            textField.layer.borderWidth = 1.0
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}
