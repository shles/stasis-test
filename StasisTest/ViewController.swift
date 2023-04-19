//
//  ViewController.swift
//  StasisTest
//
//  Created by Artemis Shlesberg on 4/18/23.
//

import UIKit

import UIKit

class CryptoViewController: UIViewController {
    
    let viewModel = ViewModel()
    
    var qrCodeImageView: UIImageView!
    var deleteButton: UIButton!
    var exportButton: UIButton!
    var generateButton: UIButton!
    var importButton: UIButton!
    var emptyLable: UILabel!
    var keyTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        keyTitle = UILabel()
        keyTitle.text = "Public key:"
        view.addSubview(keyTitle)
        
        self.title = "My key storage"
        qrCodeImageView = UIImageView()
        qrCodeImageView.contentMode = .scaleAspectFit
        view.addSubview(qrCodeImageView)
        
        deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        deleteButton.layer.cornerRadius = 8
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        view.addSubview(deleteButton)
        
        exportButton = UIButton(type: .system)
        exportButton.setTitle("Export", for: .normal)
        exportButton.setTitleColor(.white, for: .normal)
        exportButton.backgroundColor = .systemBlue
        exportButton.layer.cornerRadius = 8
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
        view.addSubview(exportButton)
        
        generateButton = UIButton(type: .system)
        generateButton.setTitle("Generate new key", for: .normal)
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.backgroundColor = .systemBlue
        generateButton.layer.cornerRadius = 8
        generateButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        view.addSubview(generateButton)
        
        importButton = UIButton(type: .system)
        importButton.setTitle("Import existing key", for: .normal)
        importButton.setTitleColor(.white, for: .normal)
        importButton.backgroundColor = .systemBlue
        importButton.layer.cornerRadius = 8
        importButton.addTarget(self, action: #selector(importButtonTapped), for: .touchUpInside)
        view.addSubview(importButton)
        
        emptyLable = UILabel()
        emptyLable.text = "No existing key"
        view.addSubview(emptyLable)
        
        layoutViews()
        viewModel.onUpdateState = { [weak self] in
            self?.updateState(state: $0)
        }
        viewModel.loadKey()
    }
    
    func updateState(state: ViewModel.ViewState) {
        switch state {
        case.noKey:
            qrCodeImageView.isHidden = true
            qrCodeImageView.image = nil
            keyTitle.isHidden = true
            deleteButton.isHidden = true
            exportButton.isHidden = true
            emptyLable.isHidden = false
            generateButton.isHidden = false
        case.key(let qrImage):
            qrCodeImageView.isHidden = false
            qrCodeImageView.image = qrImage
            keyTitle.isHidden = false
            deleteButton.isHidden = false
            exportButton.isHidden = false
            emptyLable.isHidden = true
            generateButton.isHidden = true
        }
    }
    
    func layoutViews() {
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        importButton.translatesAutoresizingMaskIntoConstraints = false
        emptyLable.translatesAutoresizingMaskIntoConstraints = false
        keyTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            qrCodeImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrCodeImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            qrCodeImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            qrCodeImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            keyTitle.leadingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor, constant: 4),
            keyTitle.bottomAnchor.constraint(equalTo: qrCodeImageView.topAnchor, constant: -8),
            
            emptyLable.centerXAnchor.constraint(equalTo: qrCodeImageView.centerXAnchor),
            emptyLable.centerYAnchor.constraint(equalTo: qrCodeImageView.centerYAnchor),
            
            deleteButton.leadingAnchor.constraint(equalTo: qrCodeImageView.leadingAnchor),
            deleteButton.topAnchor.constraint(equalTo: qrCodeImageView.bottomAnchor, constant: 20),
            deleteButton.widthAnchor.constraint(equalTo: qrCodeImageView.widthAnchor, multiplier: 0.5, constant: -10),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
            
            exportButton.trailingAnchor.constraint(equalTo: qrCodeImageView.trailingAnchor),
            exportButton.topAnchor.constraint(equalTo: deleteButton.topAnchor),
            exportButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor),
            exportButton.heightAnchor.constraint(equalTo: deleteButton.heightAnchor),
            
            generateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            generateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            generateButton.topAnchor.constraint(equalTo: exportButton.topAnchor),
            generateButton.heightAnchor.constraint(equalToConstant: 44),
            
            importButton.leadingAnchor.constraint(equalTo: generateButton.leadingAnchor),
            importButton.trailingAnchor.constraint(equalTo: generateButton.trailingAnchor),
            importButton.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 20),
            importButton.heightAnchor.constraint(equalTo: generateButton.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete key",
            message: "You won't be able to revert this action",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.viewModel.deleteKey()
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func exportButtonTapped() {
        viewModel.exportKey()
        showExportAlert()
    }
    
    @objc func generateButtonTapped() {
        let generateKeyVC = GenerateKeyViewController(viewModel: GenerateViewModel()) { [weak self] in
            self?.viewModel.loadKey()
        }
        let navVC = UINavigationController(rootViewController: generateKeyVC)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func importButtonTapped() {
        let importKeyVC = ImportKeyViewController(viewModel: ImportKeyViewModel(), onConfirm: { [weak self] in
            self?.viewModel.loadKey()
        })
        let navVC = UINavigationController(rootViewController: importKeyVC)
        present(navVC, animated: true, completion: nil)
    }
    
    func showExportAlert() {
        let alert = UIAlertController(
            title: "Copied to clipboard",
            message: "",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}

