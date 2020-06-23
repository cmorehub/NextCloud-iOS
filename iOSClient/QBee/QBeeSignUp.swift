//
//  QBeeSignUp.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
import UIKit
import Foundation

class QBeeSignUp: UIViewController {
    @IBOutlet weak var EmailAddress_UITextField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func CreateAccountButtonTouchUpInside(_ sender: Any) {
        if (isValidEmail(email: EmailAddress_UITextField.text!)){
            QBeeAPI.shared.mailCheck(mail: EmailAddress_UITextField.text!,completionHandler: {( error,description)->() in
                if error == "2"{
                    //Email has been verified
                    self.performSegue(withIdentifier: "EmailCheckButton", sender: self)
                }else if error == "0"{
                    //Email has been verified
                    print(description)
                    self.view.showToast(text: description)
                }else{
                    //Email has been Empty
                    print(description)
                    self.view.showToast(text: description)
                }
            })
        }
    }
    
    //MARK:-
    //MARK:確認Email為空值和格式是否正確
    func isValidEmail(email: String) -> Bool {
        //確認Email是否為空
        guard let text = EmailAddress_UITextField.text ,!text.isEmpty else{
            view.showToast(text: "Your Email is Empty")
            return false
        }
        //確認Email格式是否正確
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if (emailPred.evaluate(with: email)){
            return true
        }
        view.showToast(text: "Please check your Email Valid")
        return false
    }
    
    //MARK:-
    //MARK:將Email傳給下一個畫面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "EmailCheckButton"{
            if isValidEmail(email: EmailAddress_UITextField.text!){
                let EmailAddress = (segue.destination as! QBeeVerifyYourAccount)
                //更改QBeeVerifyYourAccount的變數EmailAddress的值
                EmailAddress.EmailAddress = EmailAddress_UITextField.text!
            }
        }
    }
}
//MARK:-
//MARK:END

