//
//  LogInViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import SnapKit
import FirebaseAuth
import JGProgressHUD

class LogInViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)
    
    var topView: UIView!
    var fiveImage: UIImageView!
    var vjestinaLabel: UILabel!
    var stackView: UIStackView!
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    var logInButton: UIButton!
    
    var bottomStackView: UIStackView!
    var noAccountLabel: UILabel!
    var goToRegisterBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        buildViews()
    }
    
    func buildViews() {
        createViews()
        styleViews()
        defineLayoutForViews()
    }
    
    func createViews() {
        topView = UIView()
        fiveImage = UIImageView()
        vjestinaLabel = UILabel()
        view.addSubview(topView)
        topView.addSubview(fiveImage)
        topView.addSubview(vjestinaLabel)
        
        emailTextField = UITextField()
        passwordTextField = UITextField()
        logInButton = UIButton(type: .system)
        stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, logInButton])
        view.addSubview(stackView)
        
        noAccountLabel = UILabel()
        goToRegisterBtn = UIButton()
        bottomStackView = UIStackView(arrangedSubviews: [noAccountLabel, goToRegisterBtn])
        view.addSubview(bottomStackView)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    func styleViews() {
        topView.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1)
        topView.layer.cornerRadius = 30
        
        fiveImage.image = UIImage(named: "FivePng")
        fiveImage.contentMode = .scaleAspectFit
        
//        UIFont(name: "AvenirNext-Regular", size: 38)
        vjestinaLabel.font = UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.thin)
        vjestinaLabel.text = "iOS Vještina"
        vjestinaLabel.textColor = .white
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.returnKeyType = .continue
        emailTextField.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.1)
        
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.returnKeyType = .done
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.1)
        
        logInButton.setTitle("Log In", for: .normal)
        logInButton.setTitleColor(.white, for: .normal)
        logInButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        logInButton.layer.cornerRadius = 7
        logInButton.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1)
        logInButton.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillEqually
        
        noAccountLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        noAccountLabel.text = "Don't have an account?"
        noAccountLabel.textColor = .black
        
        goToRegisterBtn.setTitle("Register now", for: .normal)
        goToRegisterBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        goToRegisterBtn.setTitleColor(UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1), for: .normal)
        goToRegisterBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToRegister(tapGestureRecognizer:))))
        
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 3
        bottomStackView.distribution = .fillProportionally
    }
    
    func defineLayoutForViews() {
        topView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-15)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(topView.snp.top).offset(300)
        }
        
        fiveImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(-60)
            $0.height.equalTo(350)
            $0.width.equalTo(450)
        }
        
        vjestinaLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-28)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(stackView.snp.top).offset(200)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(75)
            $0.trailing.equalToSuperview().inset(75)
            $0.bottom.equalToSuperview().inset(60)
        }
        
    }
    
    @objc func goToRegister(tapGestureRecognizer: UITapGestureRecognizer) {
        let registrationController = RegisterViewController()
        navigationController!.pushViewController(registrationController, animated: false)
        
    }
    
    @objc func handleLogIn() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty,
                !password.isEmpty, password.count >= 6 else {
            logInErrorAlert()
            return
        }
        
        //Log-in
        spinner.show(in: view)
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let _ = result, error == nil else {
                print("Failed to log in user.")
                return
            }
            print("loggedin")
            strongSelf.navigationController?.dismiss(animated: true)
            
        })
        
    }
    
    func logInErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Please enter all information to log in.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension LogInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
