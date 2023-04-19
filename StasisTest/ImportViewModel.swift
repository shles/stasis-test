//
//  ImportViewModel.swift
//  StasisTest
//
//  Created by Artemis Shlesberg on 4/18/23.
//

import Foundation

class ImportKeyViewModel {
    struct AlertData {
        var alertTitle: String = ""
        var alertMessage: String = ""
        var success = false
        var action: (() -> ())?
    }
    var encryptedPrivateKeyData: Data?
    var decryptedPrivateKey: Data?
    var extractedPublickKey: Data?

    let cryptoHelper = CryptoHelper()
    
    var showAlert: ((AlertData) -> ())!


    func importKey(base64PrivateKey: String, password: String) {
        
        DispatchQueue(label: "background").async {
            
            
            guard let encryptedPrivateKeyData = Data(base64Encoded: base64PrivateKey), encryptedPrivateKeyData.count >= 288 else {
                let alertData = AlertData(alertTitle: "Invalid Base64", alertMessage: "Please provide a valid base64 representation of the encrypted private key.")
                self.showAlert?(alertData)
                return
            }
            
            self.encryptedPrivateKeyData = encryptedPrivateKeyData
            
            guard let privateKeyData = self.cryptoHelper.decryptPrivateKey(encryptedPrivateKey: encryptedPrivateKeyData, password: password),
                  let publicKeyData = self.cryptoHelper.extractPublicKey(from: privateKeyData) else {
                let alertData = AlertData(alertTitle: "Decryption Failed", alertMessage: "Unable to decrypt the private key with the provided password.")
                self.showAlert?(alertData)
                return
            }
            
            self.decryptedPrivateKey = privateKeyData
            self.extractedPublickKey = publicKeyData
            
            guard let _ = self.cryptoHelper.loadKeyPair() else {
                // there is no existing key
                // Save the imported private key along with its public key counterpart
                self.cryptoHelper.saveKeyPair(privateKey: encryptedPrivateKeyData, publicKey: publicKeyData)
                let alertData = AlertData(alertTitle: "Key Imported", alertMessage: "Private key successfully imported.", success: true)
                self.showAlert?(alertData)
                return
            }
            
            let alertData = AlertData(alertTitle: "Replace Existing Key?", alertMessage: "An existing private key is already saved. Do you want to replace it with the new one?") { [weak self] in
                self?.replaceKey()
            }
            self.showAlert?(alertData)
        }
    }

    func replaceKey() {
        if let privateKeyData = encryptedPrivateKeyData,
           let publicKeyData = extractedPublickKey {
            cryptoHelper.saveKeyPair(privateKey: privateKeyData, publicKey: publicKeyData)
            let alertData = AlertData(
                alertTitle: "Key Replaced",
                alertMessage: "Existing private key successfully replaced.", success: true)
            showAlert?(alertData)
        } else {
            let alertData = AlertData(alertTitle: "Public Key Extraction Failed", alertMessage: "Unable to extract the public key from the imported private key.")
            showAlert?(alertData)
        }
    }
}
