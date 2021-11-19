//
//  ViewController.swift
//  Nkata
//
//  Created by New Account on 11/14/21.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //let color = CustomColor()
        
        self.view.backgroundColor = myDesignColor().lemonYellow
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
     validateAuth()
    }
    
    private func validateAuth(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            //Possibly refactor cos it occurs twice
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: false)
        }
    }

    

}

