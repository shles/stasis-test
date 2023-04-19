//
//  CryptoHelper.swift
//  StasisTest
//
//  Created by Artemis Shlesberg on 4/18/23.
//

import Foundation
import Security
import CryptoKit
import CryptoSwift
import UIKit
import CoreImage

class CryptoHelper {
    
    let public_tag = "com.shlesberg.cryptoTest.publicKey"
    let private_tag = "com.shlesberg.cryptoTest.privateKey"
    
    func generateRSAKeyPair() -> (privateKey: Data, publicKey: Data)? {
        let publicKeyAttributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        let privateKeyAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: false
        ]
        
        let parameters: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPublicKeyAttrs as String: publicKeyAttributes,
            kSecPrivateKeyAttrs as String: privateKeyAttributes
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Error generating RSA key pair. \(String(describing: error))")
            return nil
        }
        
        guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data?,
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            print("Error extracting private and public key data. \(String(describing: error))")
            return nil
        }
        
        return (privateKey: privateKeyData, publicKey: publicKeyData)
    }
    func encryptPrivateKey(privateKeyData: Data, password: String) -> Data? {
        
        // Generate random 16-byte salt
        let salt = generateRandomBytes(count: 16)

        // Generate a crypto key using the scrypt algorithm with parameters (N = 2048, r = 8, p = 1, dkLen = 32) with a 16-byte salt
        guard let scrypt = try? Scrypt(password: Array(password.utf8), salt: Array(salt), dkLen: 32, N: 2048, r: 8, p: 1),
              let cryptoKey = try? scrypt.calculate() else {
            print("Error generating crypto key")
            return nil
        }

        // Encrypt the private key with the crypto key using the AES algorithm with block mode = CBC and 128-bit initialization vector
        let iv = generateRandomBytes(count: 16)
        guard let cipherText = try? AES(key: cryptoKey, blockMode: CBC(iv: Array(iv)), padding: .pkcs7).encrypt(Array(privateKeyData)) else {
            print("Error encrypting private key")
            return nil
        }

        // Sequentially combine salt, cipherText, and IV into a single data block
        let encryptedPrivateKeyData = Data(salt) + Data(cipherText) + iv

        return encryptedPrivateKeyData
    }

    // Decrypt private key
    func decryptPrivateKey(encryptedPrivateKey: Data, password: String) -> Data? {
        
        
        let salt = encryptedPrivateKey[0..<16]
        let cipherText = encryptedPrivateKey[16..<(encryptedPrivateKey.count - 16)]
        let iv = encryptedPrivateKey[(encryptedPrivateKey.count - 16)...]
        
        // Generate a crypto key using the scrypt algorithm with parameters (N = 2048, r = 8, p = 1, dkLen = 32) with a 16-byte salt
        guard let scrypt = try? Scrypt(password: Array(password.utf8), salt: Array(salt), dkLen: 32, N: 2048, r: 8, p: 1),
              let cryptoKey = try? scrypt.calculate() else {
            print("Error generating crypto key")
            return nil
        }
        
        // Decrypt the private key using the crypto key and the AES algorithm with block mode = CBC and 128-bit initialization vector
        do {
            let decryptedPrivateKeyData = try AES(key: cryptoKey, blockMode: CBC(iv: Array(iv)), padding: .pkcs7).decrypt(Array(cipherText))
            return Data(decryptedPrivateKeyData)
        } catch {
            print("Error decrypting private key. \(error)")
            return nil
        }
    }

    
    private func generateRandomBytes(count: Int) -> Data {
        var randomBytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)

        if status != errSecSuccess {
            print("Error generating random bytes: \(status)")
            return Data()
        }

        return Data(randomBytes)
    }

    // Save key pair to keychain
    func saveKeyPair(privateKey: Data, publicKey: Data) {
        saveKeyToKeychain(tag: private_tag, keyData: privateKey)
        saveKeyToKeychain(tag: public_tag, keyData: publicKey)
    }


    private func saveKeyToKeychain(tag: String, keyData: Data) {
        let keyTag = tag.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecValueData as String: keyData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving key to keychain: \(status)")
        }
    }

    // Load key pair from keychain
    func loadKeyPair() -> (privateKey: Data, publicKey: Data)? {
        if let privateKeyData = loadKeyFromKeychain(tag: private_tag),
           let publicKeyData = loadKeyFromKeychain(tag: public_tag) {
            return (privateKeyData, publicKeyData)
        }
        return nil
    }
    
    func createSecKeyFromData(keyData: Data, isPublic: Bool) -> SecKey? {
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate

        let keyAttributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: keyClass,
            kSecAttrKeySizeInBits as String: 2048,
            kSecAttrIsPermanent as String: false
        ]

        return SecKeyCreateWithData(keyData as CFData, keyAttributes as CFDictionary, nil)
    }

    private func loadKeyFromKeychain(tag: String) -> Data? {
        let keyTag = tag.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var keyData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &keyData)
        if status != errSecSuccess {
            print("Error loading key from keychain: \(status)")
            return nil
        }

        return keyData as? Data
    }

    // Delete key pair from keychain
    func deleteKeyPair() {
        deleteKeyFromKeychain(tag: private_tag)
        deleteKeyFromKeychain(tag: public_tag)
    }

    private func deleteKeyFromKeychain(tag: String) {
        let keyTag = tag.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyTag
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            print("Error deleting key from keychain: \(status)")
        }
    }
    
    // Convert PEM DER ASN.1 PKCS#1 public key to a QR code
    func publicKeyToQRCode(publicKeyPEM: String) -> UIImage? {
        guard let data = publicKeyPEM.data(using: .isoLatin1) else {
               print("Error creating data from PEM string")
               return nil
           }
           
           let filter = CIFilter(name: "CIQRCodeGenerator")
           filter?.setValue(data, forKey: "inputMessage")
           filter?.setValue("H", forKey: "inputCorrectionLevel")
           
           guard let ciImage = filter?.outputImage else {
               print("Error generating QR code image")
               return nil
           }
           
           let scaleX = UIScreen.main.bounds.width / ciImage.extent.width
           let scaleY = scaleX * ciImage.extent.height / ciImage.extent.width
           let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
           
           guard let cgImage = CIContext().createCGImage(transformedImage, from: transformedImage.extent) else {
               print("Error creating CGImage from CIImage")
               return nil
           }
           
           let qrCodeImage = UIImage(cgImage: cgImage)
           print("QR code generated successfully")
           return qrCodeImage
    }
    
    // Convert public key to PEM DER ASN.1 PKCS#1 format
    func publicKeyToPEM(publicKey: Data) -> String? {
            let publicKeyBase64 = publicKey.base64EncodedString()//options: .lineLength64Characters)
            let pem = "-----BEGIN PUBLIC KEY-----\n\(publicKeyBase64)\n-----END PUBLIC KEY-----"
            return pem
    }

    func extractPublicKey(from privateKeyData: Data) -> Data? {
        
        guard let privateSecKey = createSecKeyFromData(keyData: privateKeyData, isPublic: false) else {
            return nil
        }
        
        guard let publicSecKey = SecKeyCopyPublicKey(privateSecKey) else {
            return nil
        }
        
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicSecKey, &error) as Data? else {
            print("Error extracting private and public key data. \(String(describing: error))")
            return nil
        }
        
        return publicKeyData
    }

}
