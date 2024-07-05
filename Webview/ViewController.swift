//
//  ViewController.swift
//  Webview
//
//  Created by Rishabh Jaiswal on 08/07/22.
//

import UIKit
import PayUCustomBrowser
import PayUParamsKit

class ViewController: UIViewController, PUCBWebVCDelegate {
    
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var saltTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var productInfoTextField: UITextField!
    @IBOutlet weak var surlTextField: UITextField!
    @IBOutlet weak var furlTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var environmentTextField: UITextField!
    @IBOutlet weak var userCredentialTextField: UITextField!
    @IBOutlet weak var txnIDTextField: UITextField!
    
    
    let createRequest = PayUPaymentCreateRequest()
    
    // MARK: - Variables -
    let keySalt = [["Pq4ECu", "8flg7BGF", Environment.test],
                   ["YdzpYV", "Vm4oqzit", Environment.production],
                   ["smsplus", "1b1b0", Environment.production],
                   ["Rgz9KU", "oaehOa6Y", Environment.test],
                   ["YECQmr", "f5Kbm3Yul47jcKiJ0hmB6ELRBWW7FBGG", Environment.test],
                   ["w1A2Ax", "f8hk6i6UXtBmGTER8F85n86mBfAps3gz", Environment.production],
                   ["2qWimx", "WbuCTeAMwq0siCKqRHHm5BHBrQwmhgOT", Environment.production],
                   ["gtKFFx", "4R38IvwiV57FwVpsgOvTXBdLE4tHUXFW", Environment.test]]

    let indexKeySalt = 2
    
    var amount: String = "1"
    var productInfo: String = "Nokia"
    var surl: String = "https://cbjs.payu.in/sdk/success"
    var furl: String = "https://cbjs.payu.in/sdk/failure"
    var firstName: String = "Umang"
    var email: String = "umang@arya.com"
    var phoneNumber: String = "919324718611"
    var userCredential: String = "uQXimM:9716924292@lenskartomni1.com"
 

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpValuesInTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txnIDTextField.text = ViewController.txnId()
        
    }
    
    class func stringyfy(environment: Any?) -> String {
        guard let environment = environment as? Environment else {
            return "Production"
        }
        switch environment {
        case .test:
            return "Test"
        default:
            return "Production"
        }
    }
    
    class func environment(environment: String) -> Environment {
        if environment == "Test" {
            return  Environment.test
        } else {
            return  Environment.production
        }
    }
    class func txnId() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMddHHmmss"
        let txnID = "iOS" + formatter.string(from: Date())
        return txnID
    }
    
    private func setUpValuesInTextFields() {
        keyTextField.text = keySalt[indexKeySalt][0] as? String
        saltTextField.text = keySalt[indexKeySalt][1] as? String
        amountTextField.text = amount
        productInfoTextField.text = productInfo
        surlTextField.text = surl
        furlTextField.text = furl
        firstNameTextField.text = firstName
        emailTextField.text = email
        phoneTextField.text = phoneNumber
        environmentTextField.text = ViewController.stringyfy(environment: keySalt[indexKeySalt][2] as? Environment)
        userCredentialTextField.text = userCredential

    }
    
    
    
    
    private func getPaymentParam() -> PayUPaymentParam{
        let paymentParam = PayUPaymentParam(key: keyTextField.text ?? "",
                                            transactionId: txnIDTextField.text ?? "",
                                            amount: amountTextField.text ?? "",
                                            productInfo: productInfoTextField.text ?? "",
                                            firstName: firstNameTextField.text ?? "",
                                            email: emailTextField.text ?? "",
                                            phone: phoneTextField.text ?? "",
                                            surl: surlTextField.text ?? "",
                                            furl: furlTextField.text ?? "",
                                            environment: ViewController.environment(environment: environmentTextField.text ?? ""))
        
//        let nb = NetBanking()
//        nb.paymentOptionID = "ICIB"
//        paymentParam.paymentOption = nb
        
//        let wallet = Wallet()
//        wallet.paymentOptionID = "PAYTM"
//        paymentParam.paymentOption = wallet
        
    
        let ccdc = CCDC()
                 ccdc.cardNumber = "6522029802382767"
                 ccdc.expiryYear =  2029
                 ccdc.expiryMonth = 01
                 ccdc.cvv = "050"
                 ccdc.nameOnCard = "RISHABH"
                 paymentParam.paymentOption = ccdc
        Helper.getHashes(params: paymentParam, salt: saltTextField.text ?? "")
        return paymentParam
    }
    func payUTransactionCancel() {
        print("error")
    }
    
    func payUSuccessResponse(_ response: Any!) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        print("error1.....   \(String(describing: response))")

    }
    
    func payUFailureResponse(_ response: Any!) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        print("error1.....   \(String(describing: response))")

    }
    
    
    func payUSuccessResponse(_ payUResponse: Any!, surlResponse: Any!) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        print("error1.....   \(String(describing: payUResponse))")
    }
    
    func payUFailureResponse(_ payUResponse: Any!, furlResponse: Any!) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        print("error1.....   \(String(describing: payUResponse))")
    }
    func payUConnectionError(_ notification: [AnyHashable : Any]!) {
        print("error3.....   \(String(describing: notification))")
    }
    //
    @IBAction func payNow(_ sender: UIButton) {
        PUCBConfiguration.getSingletonInstance()?.isAutoOTPSubmit = true
        createRequest.createRequest(paymentParam: getPaymentParam(), isEscapingNeeded: false) { request, postParam, error in
            if error == nil {
                print("Success")
                print("PostParam......\(request)")
                print("PostParam......\(postParam)")
                //It is good to go state. You can use request parameter in webview to open Payment Page
               
                var err: Error? = nil
                let webVC = try? PUCBWebVC(postParam: postParam, url: URL(string: "https://secure.payu.in/_payment"), merchantKey: "smsplus")
                webVC!.cbWebVCDelegate = self
                webVC!.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width,
                                           height: self.view.frame.height - 100)
                
                
                if err == nil {
                    //self.present(webVC!, animated: true, completion: nil)
                    //self.navigationController?.pushViewController(webVC!, animated: true)
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                    self.navigationController?.pushViewController(webVC!, animated: true)
                }
                else{
                    print("fjvjkf...\(err)")
                }
                
            } else {
                print("failure")
                //Something went wrong with Parameter, error contains the error Message string
            }
        }
        
    }
    
}
