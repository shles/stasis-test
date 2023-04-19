//
//  GenerateViewController.swift
//  StasisTest
//
//  Created by Artemis Shlesberg on 4/18/23.
//

import Foundation
import UIKit

class GenerateKeyViewController: UIViewController {
    
    var onConfirm: (() -> Void)!
    
    var passwordField: UITextField!
    var confirmPasswordField: UITextField!
    var confirmButton: UIButton!
    var loader: UIActivityIndicatorView!

    var viewModel: GenerateViewModel!
    
    convenience init(viewModel: GenerateViewModel, onConfirm: @escaping () -> Void) {
        self.init()
        self.viewModel = viewModel
        self.onConfirm = onConfirm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Generate key"
        passwordField = UITextField()
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = "Enter password"
        view.addSubview(passwordField)
        
        confirmPasswordField = UITextField()
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.borderStyle = .roundedRect
        confirmPasswordField.placeholder = "Confirm password"
        view.addSubview(confirmPasswordField)
        
        confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Generate and Save Key", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        view.addSubview(confirmButton)
        
        loader = UIActivityIndicatorView(style: .gray)
        view.addSubview(loader)
        
        layoutViews()
    }
    
    func layoutViews() {
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordField.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44),
            passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            confirmPasswordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            confirmPasswordField.widthAnchor.constraint(equalTo: passwordField.widthAnchor),
            
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 20),
            confirmButton.widthAnchor.constraint(equalTo: confirmPasswordField.widthAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            
            loader.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: confirmButton.centerXAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func confirmButtonTapped() {
        
        guard let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty,
              password == confirmPassword else {
            showAlert()
            return
        }
        
        self.loader.startAnimating()
        self.confirmButton.isHidden = true
        self.loader.isHidden = false
        DispatchQueue(label: "background").async {
            self.viewModel.generateKeyPair(password: password)
            DispatchQueue.main.async {
                self.loader.stopAnimating()
                self.confirmButton.isHidden = false
                self.loader.isHidden = true
                
                self.onConfirm()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    
    func showAlert() {
        let alert = UIAlertController(
            title: "Passwords don't match",
            message: "Use the same password",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
