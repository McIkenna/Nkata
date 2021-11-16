//
//  ViewController.swift
//  Nkata
//
//  Created by New Account on 11/14/21.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        //let color = CustomColor()
        
        self.view.backgroundColor = myDesignColor().lemonYellow
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        if !isLoggedIn {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            
            present(nav, animated: false)
        }
    }

    

}

