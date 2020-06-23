//
//  QBeeVerifyYourAccount.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
import UIKit
import Foundation

class QBeeVerifyYourAccount: UIViewController {
    
    var EmailAddress = ""
    
    @IBOutlet weak var EmailState: UITextView!
    @IBOutlet weak var VerificationCodeTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    @IBOutlet weak var VerifyYourAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            self.EmailState.text = "We have sent you a verification code to \(self.EmailAddress),please check your email"
            
        
    }
    

    
    //MARK:-
    //MARK:確認使用者輸入的密碼與確認密碼是否一致
    ///驗證碼
    func CheckVerificationCode() -> Void {
        guard let text = VerificationCodeTextField.text ,!text.isEmpty else{
            view.showToast(text: "Your Verification Code is Empty")
            return
        }
    }
    
    func CheckPassword() -> Bool {
        if (VerificationCodeTextField.text == ""){
            view.showToast(text: "Please input your Verification Code !")
            return false
        }
        else if (PasswordTextField.text == "" || ConfirmPasswordTextField.text == ""){
            view.showToast(text: "Please input your Password and Confirm Password !")
            return false
        }
        else if PasswordTextField.text != ConfirmPasswordTextField.text{
            view.showToast(text: "Your Input Password not absolute")
            return false
        }
        else if PasswordTextField.text == ConfirmPasswordTextField.text{
            return true
        }
        return false
    }
    //MARK:-
    //MARK:按下Button的事件
    @IBAction func ButtonTouchUpInside(_ sender: Any) {
        //若密碼錯誤
        guard CheckPassword() else{//若條件為False則不繼續往下執行
            return
        }

        print("register ButtonTouchUpInside")
        QBeeAPI.shared.codeCheck(mail: self.EmailAddress, code: self.VerificationCodeTextField.text!, completionHandler: {( error,description)->() in
                if error == "0"{
                    //Verification code confirmation
                    print("register asdasd")
                    self.view.showToast(text: description)
                    print("register \(description)")
                    QBeeAPI.shared.register(mail: self.EmailAddress, pwd: self.PasswordTextField.text!, completionHandler: {(error,description)->() in

                        print("register pwd")
                        guard error == "0" else{
                            //Register Account error
                            self.view.showToast(text: description)
                            print(description)
                            print("register pwd 0")
                            return
                        }
                        print("register registeration successfully")
                        //account registeration successfully
                        self.view.showToast(text: description)
                        print(description)
                        self.performSegue(withIdentifier: "RegisterUserButton", sender: self)
                    })
                }else{
                    
                    //Verification code error
                    self.view.showToast(text: description)
                    print(description)
                }
        })
        
    }
}
