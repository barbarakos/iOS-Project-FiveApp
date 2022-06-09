//
//  RegisterViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class RegisterViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .dark)

    var currentChoice: String!
    
    var topView: UIView!
    var fiveImage: UIImageView!
    var vjestinaLabel: UILabel!
    var stackView: UIStackView!
    var emailTextField: UITextField!
    var usernameTextField: UITextField!
    var passwordTextField: UITextField!
    var flow: UISegmentedControl!
    var keyTextField: UITextField!
    var registerBtn: UIButton!
    
    var bottomStackView: UIStackView!
    var haveAccountLabel: UILabel!
    var goToLogInBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationItem.setHidesBackButton(true, animated: true)
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
        usernameTextField = UITextField()
        passwordTextField = UITextField()
        keyTextField = UITextField()
        keyTextField.isHidden = true
        flow = UISegmentedControl(items: ["Student", "Admin"])
        currentChoice = "Student"
        flow.addTarget(self, action: #selector(flowChange), for: .valueChanged)
        registerBtn = UIButton(type: .system)
        stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, flow, keyTextField, registerBtn])
        view.addSubview(stackView)
        
        haveAccountLabel = UILabel()
        goToLogInBtn = UIButton()
        bottomStackView = UIStackView(arrangedSubviews: [haveAccountLabel, goToLogInBtn])
        view.addSubview(bottomStackView)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        keyTextField.delegate = self
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
        
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .fillProportionally
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.returnKeyType = .continue
        emailTextField.frame.size.height = 40
        emailTextField.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.1)
        
        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        usernameTextField.returnKeyType = .continue
        usernameTextField.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.1)
        
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.returnKeyType = .done
        passwordTextField.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.1)
        
        keyTextField.placeholder = "Enter admin key"
        keyTextField.isSecureTextEntry = true
        keyTextField.borderStyle = .roundedRect
        keyTextField.autocapitalizationType = .none
        keyTextField.autocorrectionType = .no
        keyTextField.returnKeyType = .done
        keyTextField.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.1)
        
        flow.layer.cornerRadius = 5
        flow.selectedSegmentIndex = 0
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        flow.setTitleTextAttributes(titleAttributes, for: .normal)
        flow.setTitleTextAttributes(titleAttributes, for: .selected)
        flow.selectedSegmentTintColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1)
        flow.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.3)
        
        registerBtn.setTitle("Register", for: .normal)
        registerBtn.setTitleColor(.white, for: .normal)
        registerBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        registerBtn.layer.cornerRadius = 7
        registerBtn.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1)
        registerBtn.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        
        haveAccountLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        haveAccountLabel.text = "Already have an account?"
        haveAccountLabel.textColor = .black
        
        goToLogInBtn.setTitle("Log In", for: .normal)
        goToLogInBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        goToLogInBtn.setTitleColor(UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1), for: .normal)
        goToLogInBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToLogIn(tapGestureRecognizer:))))
        
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 3
        bottomStackView.distribution = .fillProportionally
    }
    
    @objc private func flowChange() {
        if currentChoice == "Admin" {
            currentChoice = "Student"
            keyTextField.isHidden = true
            stackView.snp.remakeConstraints {
                $0.top.equalTo(topView.snp.bottom).offset(40)
                $0.leading.equalToSuperview().offset(40)
                $0.trailing.equalToSuperview().inset(40)
                $0.height.equalTo(315)
            }
        } else {
            currentChoice = "Admin"
            keyTextField.isHidden = false
            stackView.snp.remakeConstraints {
                $0.top.equalTo(topView.snp.bottom).offset(40)
                $0.leading.equalToSuperview().offset(40)
                $0.trailing.equalToSuperview().inset(40)
                $0.height.equalTo(390)
            }
        }
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
            $0.height.equalTo(315)
        }
        
        emailTextField.snp.makeConstraints {
            $0.height.equalTo(57)
        }
        
        usernameTextField.snp.makeConstraints {
            $0.height.equalTo(57)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(57)
        }
        
        keyTextField.snp.makeConstraints {
            $0.height.equalTo(57)
        }
        
        flow.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        registerBtn.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(90)
            $0.trailing.equalToSuperview().inset(90)
            $0.bottom.equalToSuperview().inset(60)
        }
        
    }
    
    @objc func goToLogIn(tapGestureRecognizer: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: false)
    }
    
    @objc func handleRegister() {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text, !email.isEmpty,
              !password.isEmpty, !username.isEmpty else {
            errorAlert(message: "Please enter all information to register.")
            return
        }
        guard let password = passwordTextField.text, password.count >= 6 else {
            errorAlert(message: "Password has to be at least 6 characters long.")
            return
        }
        
        let flowChosen = flow.titleForSegment(at: flow.selectedSegmentIndex)
        if flowChosen == "Admin" {
            guard let key = keyTextField.text else {
                return
            }
            if key != "QfTjWnZr4u7x!A%D*G-JaNdRgUkXp2s5v8y/B?E(H+MbPeShVmYq3t6w9z$C&F)J" {
                errorAlert(message: "Incorrect key for admin!")
                return
            }
        }
        
        //Registration
        spinner.show(in: view)
        DatabaseManager.shared.userWithEmailExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                strongSelf.errorAlert(message: "User with that email already exists!")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
                guard let strongSelf = self else {
                    return
                }
                guard let _ = result, error == nil else {
                    print("Error creating user")
                    return
                }
                
                let admin: Bool
                if flowChosen == "Admin" {
                    admin = true
                } else {
                    admin = false
                }
                
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.set(admin, forKey: "admin")
                
                let appUser = AppUser(username: username, email: email, admin: admin)
                DatabaseManager.shared.createUser(with: appUser, completion: { sucess in
                    if sucess {
                        //uploading image
                        var image = UIImage(named: "defaultProfilePic")
                        if admin == true {
                            image = UIImage(named: "FiveProfilePic")
                        }
                        guard let data = image!.pngData() else {
                            return
                        }
                        let fileName = appUser.profilePicFileName
                        StorageManager.shared.uploadProfilePic(with: data, fileName: fileName, completionHandler: { result in
                            switch result {
                            case .success(let downloadURL):
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture")
                            case .failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    }
                })
                
                strongSelf.navigationController?.dismiss(animated: true)
                
            })
        })
    }
    
    func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
