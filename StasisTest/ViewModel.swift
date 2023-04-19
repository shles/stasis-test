//
//  ViewModel.swift
//  StasisTest
//
//  Created by Artemis Shlesberg on 4/19/23.
//

import Foundation
import UIKit

class ViewModel {
    
    enum ViewState {
        case key(UIImage)
        case noKey
    }
    
    var state: ViewState = .noKey
    
    private let cryptoHelper = CryptoHelper()
    var onUpdateState: ((ViewState) -> ())?
    
    init() {
        loadKey()
    }

    func loadKey() {
        if let (_, publicKey) = cryptoHelper.loadKeyPair() {
            let publicKeyPEM = cryptoHelper.publicKeyToPEM(publicKey: publicKey)
            if let pem = publicKeyPEM, let qrCode = cryptoHelper.publicKeyToQRCode(publicKeyPEM: pem) {
                state = .key(qrCode)
            } else {
                print("Error generating QR code")
                state = .noKey
            }
        } else {
            state = .noKey
        }
        onUpdateState?(state)
    }
    
    func exportKey() {
        if let (privateKey, _) = cryptoHelper.loadKeyPair() {
            UIPasteboard.general.string = privateKey.base64EncodedString()
        }
    }
    
    func deleteKey() {
        cryptoHelper.deleteKeyPair()
        loadKey()
    }
}
