//
//  RegisterViewController.swift
//  Nkata
//
//  Created by New Account on 11/14/21.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    //creating a scroll view
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    //FirstName field
    private let firstNameField: UITextField = {
        let firstName = UITextField()
        firstName.autocapitalizationType = .none
        firstName.autocorrectionType = .no
        firstName.returnKeyType = .continue
        firstName.layer.cornerRadius = 12
        firstName.layer.borderWidth = 1
       
        firstName.layer.borderColor = myDesignColor().flax.cgColor
        firstName.backgroundColor = .white
        firstName.placeholder = "FirstName...."
        firstName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        firstName.leftViewMode = .always
        return firstName
    }()
    
    //LastName
    private let lastNameField: UITextField = {
        let lastName = UITextField()
        lastName.autocapitalizationType = .none
        lastName.autocorrectionType = .no
        lastName.returnKeyType = .continue
        lastName.layer.cornerRadius = 12
        lastName.layer.borderWidth = 1
       
        lastName.layer.borderColor = myDesignColor().flax.cgColor
        lastName.backgroundColor = .white
        lastName.placeholder = "LastName...."
        lastName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        lastName.leftViewMode = .always
        return lastName
    }()
    
    //EmailField
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
    private let RegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
        
    }()
    
    
    //Created an image View to hold to Logo
    private let imageView: UIImageView = {
    let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = myDesignColor().brown.cgColor
        return imageView }()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Register"
        view.backgroundColor = myDesignColor().maxYellowRed
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        RegisterButton.addTarget(self, action: #selector(RegisterButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        password.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(password)
        scrollView.addSubview(RegisterButton)
        //enable interraction of image to scrollview
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
    }
    
    @objc func didTapChangeProfilePic(){
        print("Touched an Image")
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2, y: 20, width: size, height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        
        firstNameField.frame = CGRect(x: 30, y: imageView.bottom + 20, width: scrollView.width - 60, height: 52)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 10, width: scrollView.width - 60, height: 52)
        emailField.frame = CGRect(x: 30, y: lastNameField.bottom + 10, width: scrollView.width - 60, height: 52)
        password.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scrollView.width - 60, height: 52)
        RegisterButton.frame = CGRect(x: 30, y: password.bottom + 10, width: scrollView.width - 60, height: 52)
    }


    @objc private func RegisterButtonTapped(){
        emailField.resignFirstResponder()
        password.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = password.text, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, password.count >= 6 else{
            alertUserLoginError()
            return
        }
        //Firebase Login
        
        DatabaseManager.shared.userExists(with: email, completion: {[weak self] exists in
            guard let strongSelf = self else {
                return
            }
            guard !exists else{
                // user already exists
                strongSelf.alertUserLoginError(message: "Seems the email address already exist")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                
                guard let strongSelf = self else{
                   
                    return
                }
                
                guard authResult != nil, error == nil else{
                    print("Error cureating user")
                    return
                }
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            
        })
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create an account"){
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    @objc private func didTapRegister(){
        let regVC = RegisterViewController()
        regVC.title = "Create Account"
        navigationController?.pushViewController(regVC, animated: true)
    }

}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            password.becomeFirstResponder()
        }else if textField == password {
            RegisterButtonTapped()
        }
        return true
    }
    
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How will would you like t select a picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in self?.presentCamera()}))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in self?.presentPhotoPicker()}))
        
        present(actionSheet, animated: true)
        
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
       // print(info)
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
