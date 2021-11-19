//
//  LoginViewController.swift
//  Nkata
//
//  Created by New Account on 11/14/21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    //creating a scroll view
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    //Email field
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = myDesignColor().flax.cgColor
        field.backgroundColor = .white
        field.placeholder = "Email Address...."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        return field
    }()

    //Password
    private let password: UITextField = {
        let passwordField = UITextField()
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.returnKeyType = .done
        passwordField.layer.cornerRadius = 12
        passwordField.layer.borderWidth = 1
        passwordField.isSecureTextEntry = true
        passwordField.layer.borderColor = myDesignColor().flax.cgColor
        passwordField.backgroundColor = .white
        passwordField.placeholder = "Password...."
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.leftViewMode = .always
        return passwordField
    }()
    //Button
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
        
    }()
    //Created an image View to hold to Logo
    private let imageView: UIImageView = {
    let imageView = UIImageView()
        imageView.image = UIImage(named: "NkataLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView }()

    private let fBloginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()

  //  private let fBloginButton = FBLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        self.view.backgroundColor = myDesignColor().deepChampagn
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        password.delegate = self
        fBloginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(password)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fBloginButton)
   

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 20, width: size, height: size)
        
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 20, width: scrollView.width - 60, height: 52)
        password.frame = CGRect(x: 30, y: emailField.bottom + 20, width: scrollView.width - 60, height: 52)
        loginButton.frame = CGRect(x: 30, y: password.bottom + 20, width: scrollView.width - 60, height: 52)
        fBloginButton.frame = CGRect(x: 30, y: loginButton.bottom + 20, width: scrollView.width - 60, height: 52)
     
        fBloginButton.frame.origin.y = loginButton.bottom + 20
    }


    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        password.resignFirstResponder()
        guard let email = emailField.text, let password = password.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else{
            alertUserLoginError()
            return
        }
        //Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else{
            print("User with email: \(email) does not exist")
            return
            }
            let user = result.user
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Oops", message: "Please enter all information to login", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    @objc private func didTapRegister(){
        let regVC = RegisterViewController()
        regVC.title = "Create Account"
        navigationController?.pushViewController(regVC, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            password.becomeFirstResponder()
        }else if textField == password {
            loginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {

    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to login with Facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any],
                    error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            print("\(result)")
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                      print("Failed to get email and name from fb result")
                      return
            }
            let nameComponents = userName.components(separatedBy: " ")
            let firstName: String
            let lastName: String
            if nameComponents.count == 3 {
                firstName = nameComponents[0]
                lastName = nameComponents[2]
            }else if nameComponents.count == 2 {
                firstName = nameComponents[0]
                lastName = nameComponents[1]
            }else if nameComponents.count == 1 {
                firstName = nameComponents[0]
                lastName = ""
            }else {
                return
            }
            //checking if username exist Inserting the data from facebook to the chatt app if it does not exist
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                }
            })
            
            //Obtain a firebase credential to sign the user in
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self] authResult, error in
                guard let strngSelf = self else {return}
                
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook login credention failed, MFA may be needed - \(error)")
                    }
                    return
                }
                print("Successfully logged user in")
                strngSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            
        })
        
    }
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no Operation
    }
   
}

