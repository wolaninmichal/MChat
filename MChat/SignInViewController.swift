//
//  SignInViewController.swift
//  MChat
//
//  Created by Michał Wolanin on 25/04/2023.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class SignInViewController: UIViewController {
    
    let googleButton =  GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureButton()
        configureGoogleSignIn()
        
    }
    
    public func configureButton(){
        view.addSubview(googleButton)
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButton.addTarget(self, action: #selector(didTapGoogleSignIn), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            googleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    public func configureGoogleSignIn(){
        let clientID = "574266226156-k3k84gq0er2jq8negh7rca94g5v0l20m.apps.googleusercontent.com"
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
    }
    
    @objc func didTapGoogleSignIn(){
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString,
                  let strongSelf = self else {
                print("error with sign in")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            AuthManager.shared.signIn(cred: credential)
        }
    }
    
}
    
