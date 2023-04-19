//
//  GenerateViewModel.swift
//  StasisTest
//
//  Created by Artemis Shlesberg on 4/19/23.
//

import Foundation

class GenerateViewModel {
    let cryptoHelper = CryptoHelper()
    
    
    func generateKeyPair(password: String) {
        guard let keyPair = cryptoHelper.generateRSAKeyPair() else {
            print("Error generating key pair")
            return
        }
        
        guard let encryptedPrivateKey = cryptoHelper.encryptPrivateKey(privateKeyData: keyPair.privateKey, password: password) else {
            print("Error encrypting key pair")
            return
        }

        cryptoHelper.saveKeyPair(privateKey: encryptedPrivateKey, publicKey: keyPair.publicKey)
        print("Key pair generated and saved")
    }
}
