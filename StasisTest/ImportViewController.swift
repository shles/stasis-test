//
//  ImportViewController.swift
//  StasisTest
//
//  Created by Artemis Shlesberg on 4/18/23.
//

import Foundation
import UIKit

class ImportKeyViewController: UIViewController {
    
    var viewModel: ImportKeyViewModel!
    var onConfirm: (() -> Void)!
    
    var privateKeyTextView: UITextView!
    var passwordField: UITextField!
    var importButton: UIButton!
    var loader: UIActivityIndicatorView!
    
    convenience init(viewModel: ImportKeyViewModel, onConfirm: @escaping () -> Void) {
        self.init()
        self.viewModel = viewModel
        self.onConfirm = onConfirm
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Import key"
        
        privateKeyTextView = UITextView()
        privateKeyTextView.font = UIFont.preferredFont(forTextStyle: .body)
        privateKeyTextView.layer.borderWidth = 1
        privateKeyTextView.layer.cornerRadius = 8
        privateKeyTextView.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(privateKeyTextView)
        
        passwordField = UITextField()
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = "Password"
        view.addSubview(passwordField)
        
        importButton = UIButton(type: .system)
        importButton.setTitle("Import Key", for: .normal)
        importButton.addTarget(self, action: #selector(importButtonTapped), for: .touchUpInside)
        view.addSubview(importButton)
        
        loader = UIActivityIndicatorView(style: .gray)
        view.addSubview(loader)
        
        layoutViews()
        viewModel.showAlert = { [weak self] in
            self?.onShowAlert(alertData: $0)
        }
    }
    
    func layoutViews() {
        privateKeyTextView.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        importButton.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            privateKeyTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            privateKeyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            privateKeyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            privateKeyTextView.heightAnchor.constraint(equalToConstant: 150),
            
            passwordField.topAnchor.constraint(equalTo: privateKeyTextView.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 44),
            
            importButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            importButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            importButton.widthAnchor.constraint(equalTo: passwordField.widthAnchor),
            importButton.heightAnchor.constraint(equalToConstant: 44),
            
            loader.centerYAnchor.constraint(equalTo: importButton.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: importButton.centerXAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    func onShowAlert(alertData: ImportKeyViewModel.AlertData) {
        
        DispatchQueue.main.async {
            
            self.loader.stopAnimating()
            self.importButton.isHidden = false
            self.loader.isHidden = true
            
        let alert = UIAlertController(title: alertData.alertTitle, message: alertData.alertMessage, preferredStyle: .alert)
        
        if let action = alertData.action {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Replace", style: .destructive, handler: { _ in
                action()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:  {[weak self] _ in
                if alertData.success {
                    self?.onConfirm()
                    self?.dismiss(animated: true)
                }
            }))
        }
        
            self.present(alert, animated: true)
        }
    }
    
    @objc func importButtonTapped() {

        loader.startAnimating()
        importButton.isHidden = true
        loader.isHidden = false
        
        viewModel.importKey(base64PrivateKey: privateKeyTextView.text.trimmingCharacters(in: .whitespacesAndNewlines), password: passwordField.text ?? "")
        
    }
}
