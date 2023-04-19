import XCTest
@testable import StasisTest

class CryptoHelperTests: XCTestCase {

    var sut: CryptoHelper!

    override func setUp() {
        super.setUp()
        sut = CryptoHelper()
    }

    override func tearDown() {
        sut.deleteKeyPair()
        sut = nil
        super.tearDown()
    }

    func testGenerateRSAKeyPair() {
        let keyPair = sut.generateRSAKeyPair()

        XCTAssertNotNil(keyPair)
        XCTAssertNotNil(keyPair?.privateKey)
        XCTAssertNotNil(keyPair?.publicKey)
    }

    func testEncryptPrivateKey() {
        let keyPair = sut.generateRSAKeyPair()
        let password = "password"
        let encryptedPrivateKey = sut.encryptPrivateKey(privateKeyData: keyPair!.privateKey, password: password)

        XCTAssertNotNil(encryptedPrivateKey)
        XCTAssertNotEqual(encryptedPrivateKey, keyPair?.privateKey)
    }

    func testDecryptPrivateKey() {
        let keyPair = sut.generateRSAKeyPair()
        let password = "password"
        let encryptedPrivateKey = sut.encryptPrivateKey(privateKeyData: keyPair!.privateKey, password: password)
        let decryptedPrivateKey = sut.decryptPrivateKey(encryptedPrivateKey: encryptedPrivateKey!, password: password)

        XCTAssertNotNil(decryptedPrivateKey)
        XCTAssertEqual(decryptedPrivateKey, keyPair?.privateKey)
    }

    func testSaveAndLoadKeyPair() {
        let keyPair = sut.generateRSAKeyPair()
        sut.saveKeyPair(privateKey: keyPair!.privateKey, publicKey: keyPair!.publicKey)

        let loadedKeyPair = sut.loadKeyPair()
        XCTAssertNotNil(loadedKeyPair)
        XCTAssertEqual(loadedKeyPair?.privateKey, keyPair?.privateKey)
        XCTAssertEqual(loadedKeyPair?.publicKey, keyPair?.publicKey)

        sut.deleteKeyPair()
        XCTAssertNil(sut.loadKeyPair())
    }

    func testPublicKeyToQRCode() {
        let keyPair = sut.generateRSAKeyPair()
        let publicKeyPEM = sut.publicKeyToPEM(publicKey: keyPair!.publicKey)
        let qrCode = sut.publicKeyToQRCode(publicKeyPEM: publicKeyPEM!)

        XCTAssertNotNil(qrCode)
        XCTAssertTrue(qrCode!.size.width > 0)
        XCTAssertTrue(qrCode!.size.height > 0)
    }

    func testPublicKeyToPEM() {
        let keyPair = sut.generateRSAKeyPair()
        let publicKeyPEM = sut.publicKeyToPEM(publicKey: keyPair!.publicKey)

        XCTAssertNotNil(publicKeyPEM)
        XCTAssertTrue(publicKeyPEM!.starts(with: "-----BEGIN PUBLIC KEY-----"))
        XCTAssertTrue(publicKeyPEM!.contains(keyPair!.publicKey.base64EncodedString()))
        XCTAssertTrue(publicKeyPEM!.hasSuffix("-----END PUBLIC KEY-----"))
    }

    func testExtractPublicKey() {
        let keyPair = sut.generateRSAKeyPair()
        let privateKeyData = keyPair!.privateKey
        let extractedPublicKey = sut.extractPublicKey(from: privateKeyData)

        XCTAssertNotNil(extractedPublicKey)
    }
    
    func testExtractPublicKeyFromEncrypted() {
        let keyPair = sut.generateRSAKeyPair()
        let privateKeyData = keyPair!.privateKey
        let publicKeyData = keyPair!.publicKey
        let password = "password"
        let encryptedPrivateKey = sut.encryptPrivateKey(privateKeyData: privateKeyData, password: password)
        XCTAssertNotNil(encryptedPrivateKey)
        let decryptedPrivateKey = sut.decryptPrivateKey(encryptedPrivateKey: encryptedPrivateKey!, password: password)
        XCTAssertNotNil(decryptedPrivateKey)
        let extractedPublicKey = sut.extractPublicKey(from: decryptedPrivateKey!)
        
        
        XCTAssertNotNil(extractedPublicKey)
        XCTAssertEqual(extractedPublicKey, publicKeyData)
    }

    
    func testExtractPublicKeyFromEncryptedAfterSave() {
        let keyPair = sut.generateRSAKeyPair()
        let privateKeyData = keyPair!.privateKey
        let publicKeyData = keyPair!.publicKey
        let password = "password"
        let encryptedPrivateKey = sut.encryptPrivateKey(privateKeyData: privateKeyData, password: password)
        XCTAssertNotNil(encryptedPrivateKey)
        
        sut.saveKeyPair(privateKey: encryptedPrivateKey!, publicKey: publicKeyData)
        let loadedKeyPair = sut.loadKeyPair()
        
        XCTAssertNotNil(loadedKeyPair)
        
        let (loadedPrivateKey, _) = loadedKeyPair!
        
        
        let decryptedPrivateKey = sut.decryptPrivateKey(encryptedPrivateKey: loadedPrivateKey, password: password)
        XCTAssertNotNil(decryptedPrivateKey)
        let extractedPublicKey = sut.extractPublicKey(from: decryptedPrivateKey!)
        
        
        XCTAssertNotNil(extractedPublicKey)
        XCTAssertEqual(extractedPublicKey, publicKeyData)
    }
}
