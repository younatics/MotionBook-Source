//
//  PurchaseViewController.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 9..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import SwiftyStoreKit
import UIKit
import Pastel

extension PurchaseViewController {
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.view.tintColor = UIColor(hexString: MainColor)
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> UIAlertController {
        
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please try again"
            return alertWithTitle("Could not retrieve product info", message: errorString)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let product):
//            print("Purchase Success: \(product.productId)")
            switch product.productId {
            case "com.seungyounyi.MotionBook.unlockExamples":
                self.buyDone()
                
                Log.purchase(price: 0.99, name: "Unlock example", location: self, id: product.productId)
                return alertWithTitle("Thank You", message: "You can now use all examples")
                
            case "com.seungyounyi.MotionBook.cheers499":
                Log.purchase(price: 4.99, name: "Cheers 4.99$", location: self, id: product.productId)
                return alertWithTitle("Thank You", message: "I will do my best to improve MotionBook")

            case "com.seungyounyi.MotionBook.cheers999":
                Log.purchase(price: 9.99, name: "Cheers 9.99$", location: self, id: product.productId)
                return alertWithTitle("Thank You", message: "I will do my best to improve MotionBook")

            case "com.seungyounyi.MotionBook.cheers4999":
                Log.purchase(price: 49.99, name: "Cheers 49.99$", location: self, id: product.productId)
                return alertWithTitle("Thank You", message: "I will do my best to improve MotionBook")

            case "com.seungyounyi.MotionBook.cheers9999":
                Log.purchase(price: 99.99, name: "Cheers 99.99$", location: self, id: product.productId)
                return alertWithTitle("Thank You", message: "I will do my best to improve MotionBook")

            case "com.seungyounyi.MotionBook.cheers99999":
                Log.purchase(price: 999.99, name: "Cheers 999.99$", location: self, id: product.productId)
                return alertWithTitle("Thank You", message: "I will do my best to improve MotionBook")

            case "com.seungyounyi.MotionBook.cheers999":
                Log.purchase(price: 9.99, name: "Cheers 9.99$", location: self, id: product.productId)
                return alertWithTitle("Thank You", message: "I will do my best to improve MotionBook")

            default:
                break
            }
            return alertWithTitle("Thank You", message: "Purchase completed")
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: "Unknown error. Please try again")
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Could service was revoked")
            }
        }
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
//            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please try again")
        } else if results.restoredPurchases.count > 0 {
//            print("Restore Success: \(results.restoredPurchases)")
            for purchase in results.restoredPurchases {
                if purchase.productId == "com.seungyounyi.MotionBook.unlockExamples" {
                    self.buyDone()
                }
            }

            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
//            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func buyDone() {
        let settings = Settings()
        settings.setInappPurchased(value: true)
        
        self.unlockButton.isEnabled = false
        self.unlockImageView.removeFromSuperview()
        
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success( _):
//            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotly")
        case .error(let error):
//            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData :
                return alertWithTitle("Receipt verification", message: "No receipt data, application will try to get a new one. Try again.")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed")
            }
        }
    }
    
    func alertForVerifySubscription(_ result: VerifySubscriptionResult) -> UIAlertController {
        
        switch result {
        case .purchased(let expiryDate):
//            print("Product is valid until \(expiryDate)")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate):
//            print("Product is expired since \(expiryDate)")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
//            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyPurchase(_ result: VerifyPurchaseResult) -> UIAlertController {
        
        switch result {
        case .purchased:
            print("Product is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("This product has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
}

enum RegisteredPurchase: String {
    case unlockExamples
    case cheers499
    case cheers999
    case cheers4999
    case cheers9999
    case cheers99999
}



class PurchaseViewController: BaseViewController {
    var pastelView: PastelView!
    let appBundleId = "com.seungyounyi.MotionBook"
    
    let unlockSuffix = RegisteredPurchase.unlockExamples
    let cheers1Suffix = RegisteredPurchase.cheers499
    let cheers2Suffix = RegisteredPurchase.cheers999
    let cheers3Suffix = RegisteredPurchase.cheers4999
    let cheers4Suffix = RegisteredPurchase.cheers9999
    let cheers5Suffix = RegisteredPurchase.cheers99999

    var tableView: UITableView!
    var unlockImageView: UIImageView!
    var unlockButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.pastelView.startAnimation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func restoreButtonClicked() {
        self.restorePurchases()
    }
    
    @objc func closeButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func restorePurchases() {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            for product in results.restoredPurchases where product.needsFinishTransaction {
                // Deliver content from server, then:
                SwiftyStoreKit.finishTransaction(product.transaction)
            }
            self.showAlert(self.alertForRestorePurchases(results))
        }
    }

    func purchase(_ purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(appBundleId + "." + purchase.rawValue, atomically: true) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let product) = result {
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }

    func getInfo(_ purchase: RegisteredPurchase) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            self.showAlert(self.alertForProductRetrievalInfo(result))
        }
    }
    

    @objc func cheersButtonClicked(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            Log.checkOut(price: 9.99)
            self.purchase(cheers2Suffix)
        case 2:
            Log.checkOut(price: 49.99)
            self.purchase(cheers3Suffix)
        case 3:
            Log.checkOut(price: 99.99)
            self.purchase(cheers4Suffix)
        case 4:
            Log.checkOut(price: 999.99)
            self.purchase(cheers5Suffix)
        default:
            break
        }
    }
    
    @objc func unlockButtonClicked() {
        Log.checkOut(price: 0.99)
        self.purchase(unlockSuffix)
    }
    
    func initView() {
        self.view.backgroundColor = UIColor(hexString:"FAFAFA")
        
        let buttonWidth = (screenWidth - 50) / 2
        
        let cheers3Button = UIButton()
        cheers3Button.setTitleColor(UIColor(hexString: TitleColor), for: .normal)
        cheers3Button.setTitleColor(UIColor(hexString: TitleColor).withAlphaComponent(0.3), for: .highlighted)
        cheers3Button.setTitle("Cheers 99.99$", for: .normal)
        cheers3Button.layer.cornerRadius = 4
        cheers3Button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cheers3Button.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
        cheers3Button.layer.borderWidth = 1
        cheers3Button.backgroundColor = UIColor.white
        cheers3Button.tag = 3
        cheers3Button.addTarget(self, action: #selector(cheersButtonClicked(_:)), for: .touchUpInside)
        self.view.addSubview(cheers3Button)
        
        cheers3Button.snp.makeConstraints { (m) in
            m.left.equalTo(self.view).offset(20)
            m.width.equalTo(buttonWidth)
            m.height.equalTo(50)
            m.bottom.equalTo(self.view).offset(-32.5)
        }
        
        let cheers4Button = UIButton()
        cheers4Button.setTitleColor(UIColor(hexString: TitleColor), for: .normal)
        cheers4Button.setTitleColor(UIColor(hexString: TitleColor).withAlphaComponent(0.3), for: .highlighted)
        cheers4Button.setTitle("Cheers 999.99$", for: .normal)
        cheers4Button.layer.cornerRadius = 4
        cheers4Button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cheers4Button.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
        cheers4Button.layer.borderWidth = 1
        cheers4Button.backgroundColor = UIColor.white
        cheers4Button.tag = 4
        cheers4Button.addTarget(self, action: #selector(cheersButtonClicked(_:)), for: .touchUpInside)

        self.view.addSubview(cheers4Button)
        
        cheers4Button.snp.makeConstraints { (m) in
            m.right.equalTo(self.view).offset(-20)
            m.width.equalTo(buttonWidth)
            m.height.equalTo(50)
            m.bottom.equalTo(self.view).offset(-32.5)
        }
        
        let cheers1Button = UIButton()
        cheers1Button.setTitleColor(UIColor(hexString: TitleColor), for: .normal)
        cheers1Button.setTitleColor(UIColor(hexString: TitleColor).withAlphaComponent(0.3), for: .highlighted)
        cheers1Button.setTitle("Cheers 9.99$", for: .normal)
        cheers1Button.layer.cornerRadius = 4
        cheers1Button.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
        cheers1Button.layer.borderWidth = 1
        cheers1Button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cheers1Button.backgroundColor = UIColor.white
        cheers1Button.tag = 1
        cheers1Button.addTarget(self, action: #selector(cheersButtonClicked(_:)), for: .touchUpInside)
        
        self.view.addSubview(cheers1Button)
        
        cheers1Button.snp.makeConstraints { (m) in
            m.left.equalTo(self.view).offset(20)
            m.width.equalTo(buttonWidth)
            m.height.equalTo(50)
            m.bottom.equalTo(cheers3Button.snp.top).offset(-10)
        }

        let cheers2Button = UIButton()
        cheers2Button.setTitleColor(UIColor(hexString: TitleColor), for: .normal)
        cheers2Button.setTitleColor(UIColor(hexString: TitleColor).withAlphaComponent(0.3), for: .highlighted)
        cheers2Button.setTitle("Cheers 49.99$", for: .normal)
        cheers2Button.layer.cornerRadius = 4
        cheers2Button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cheers2Button.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
        cheers2Button.layer.borderWidth = 1
        cheers2Button.backgroundColor = UIColor.white
        cheers2Button.tag = 2
        cheers2Button.addTarget(self, action: #selector(cheersButtonClicked(_:)), for: .touchUpInside)
        
        self.view.addSubview(cheers2Button)
        
        cheers2Button.snp.makeConstraints { (m) in
            m.right.equalTo(self.view).offset(-20)
            m.width.equalTo(buttonWidth)
            m.height.equalTo(50)
            m.bottom.equalTo(cheers4Button.snp.top).offset(-10)
        }
        
        let bottomLabel = UILabel()
        bottomLabel.text = "CHEERS TO DEVELOPER 💕"
        bottomLabel.textColor = UIColor(hexString: "A6AEB7")
        bottomLabel.font = UIFont.semiboldSystemFont(ofSize: 12)
        
        self.view.addSubview(bottomLabel)
        
        bottomLabel.snp.makeConstraints { (m) in
            m.left.equalTo(cheers1Button)
            m.bottom.equalTo(cheers1Button.snp.top).offset(-20)
        }
        
        self.pastelView = PastelView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 207))
        self.pastelView.animationDuration = 2.0
        self.pastelView.setColors(GradationColors)
        self.pastelView.startAnimation()

        self.view.insertSubview(self.pastelView, at: 0)
        
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "icNavbarClose"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { (m) in
            m.left.equalTo(self.view).offset(15)
            m.top.equalTo(self.view).offset(DynamicPurchaseCloseButtonOffset)
            m.width.height.equalTo(30)
        }
        
        let restoreButton = UIButton()
        restoreButton.setTitle("Restore", for: .normal)
        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        restoreButton.setTitleColor(UIColor.white, for: .normal)
        restoreButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .highlighted)
        restoreButton.addTarget(self, action: #selector(restoreButtonClicked), for: .touchUpInside)
        self.view.addSubview(restoreButton)
        
        restoreButton.snp.makeConstraints { (m) in
            m.right.equalTo(self.view).offset(-20)
            m.centerY.equalTo(closeButton)
        }
        
        let mainLabel = UILabel()
        mainLabel.font = UIFont.semiboldSystemFont(ofSize: 40)
        
        if screenWidth <= 320.0 {
            mainLabel.font = UIFont.semiboldSystemFont(ofSize: 30)
        }
        mainLabel.textColor = UIColor.white
        mainLabel.numberOfLines = 4
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        
        let attrString = NSMutableAttributedString(string: "Motion,\nquality and\naesthetic\nare in your hands")
        attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        mainLabel.attributedText = attrString
        self.view.addSubview(mainLabel)
        
        mainLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self.view).offset(20)
            m.top.equalTo(self.view).offset(87)
        }
        
        self.unlockButton = UIButton()
        self.unlockButton.addTarget(self, action: #selector(unlockButtonClicked), for: .touchUpInside)
        self.unlockButton.backgroundColor = UIColor.white
        self.unlockButton.layer.cornerRadius = 4
        self.unlockButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.unlockButton.setTitle("Unlock all examples 0.99$", for: .normal)
        self.unlockButton.setTitle("Unlocked all examples and explains", for: .disabled)
        self.unlockButton.setTitleColor(UIColor(hexString: MainColor), for: .normal)
        self.unlockButton.setTitleColor(UIColor.lightGray, for: .disabled)
        self.unlockButton.setTitleColor(UIColor(hexString: MainColor).withAlphaComponent(0.3), for: .highlighted)
        self.view.addSubview(self.unlockButton)
        
        self.unlockButton.snp.makeConstraints { (m) in
            m.left.equalTo(self.view).offset(20)
            m.right.equalTo(self.view).offset(-20)
            m.bottom.equalTo(pastelView).offset(-20)
            m.height.equalTo(50)
        }
        
        unlockImageView = UIImageView(image: UIImage(named: "icEnterColor"))
        self.unlockButton.addSubview(unlockImageView)
        
        unlockImageView.snp.makeConstraints { (m) in
            m.right.equalTo(unlockButton).offset(-20)
            m.centerY.equalTo(unlockButton)
            m.width.height.equalTo(14)
        }
    }

}
