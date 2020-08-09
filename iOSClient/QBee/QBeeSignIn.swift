//
//  QBeeSignIn.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
import UIKit
import Foundation


class QBeeSignIn: UIViewController {
    @IBOutlet weak var EmailAddressTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK:-
    //MARK:確認EmailAddress和Password欄位是否為空
    func checkTextField() -> Bool{
        if (EmailAddressTextField.text != "" && PasswordTextField.text != ""){
            return true
        }
        view.showToast(text: "Please input your Email or Password")
        return false
    }
    //MARK:-
    //MARK:當Sign in按鈕按下時
    @IBAction func SignInButtonTouchUpInside(_ sender: Any) {
        (sender as! UIButton).isEnabled = false//讓使用者不會重複按按鈕,暫時不給按,直到response回來
        if checkTextField(){
            QBeeAPI.shared.login(mail: EmailAddressTextField.text!, pwd: PasswordTextField.text!, completionHandler: {( error,description)->() in
                    if error == "0"{
                        //Successfully
                        QBeeAPI.shared.QBeeUser.updateValue(self.EmailAddressTextField.text!, forKey: "Account")
                        QBeeAPI.shared.QBeeUser.updateValue(self.PasswordTextField.text!, forKey: "Password")
                        if description.count>0 {
                            
                            ///TIEN 未來有多台裝置的時候 需要修改
                            for (BoxMAC, _) in QBeeAPI.shared.AccountBindQBee {
                                
//                                RemoteItRest.shared.connect(user: RemoteItConnectConstants.user, password: RemoteItConnectConstants.password, apiKey: RemoteItConnectConstants.apiKey, deviceAddress: BoxMAC ) { (url, description) in
//                                     if let url = url{
//                                         print(url)
//                                         self.url = url.absoluteString
//                                         //self.view.showToast(text: url as! String)
//                                         self.toNextCloudTest()
//                                         //self.toNextcloud()
//                                     }else{
//                                         print("No Url Error Code: \(description)")
//                                         self.view.showToast(text: description)
//                                     }
//                                 }
                                
                                RemoteItP2P.shared.connect(user: RemoteItConnectConstants.user, password: RemoteItConnectConstants.password, apiKey: RemoteItConnectConstants.apiKey, deviceAddress: BoxMAC ) { (url, description) in
                                    if let url = url{
                                        print("============QBeeSignIn url ==\(url)")
                                        //self.url = url.absoluteString
                                        ConnectNextCloud(viewController: self, url: url.absoluteString).toNextCloudTest()
                                        //self.toNextCloudTest()

                                    }else{
                                        print("No Url Error Code: \(description)")
                                        DispatchQueue.main.async {
                                            self.view.showToast(text: description)
                                        }
                                         RemoteItRest.shared.connect(user: RemoteItConnectConstants.user, password: RemoteItConnectConstants.password, apiKey: RemoteItConnectConstants.apiKey, deviceAddress: BoxMAC ) { (url, description) in
                                                 if let url = url{
                                                     print(url)
                                                     //self.url = url.absoluteString
                                                     ConnectNextCloud(viewController: self, url: url.absoluteString).toNextCloudTest()
                                                     //self.toNextCloudTest()
                                                     //self.toNextcloud()
                                                 }else{
                                                     print("No Url Error Code: \(description)")
                                                     self.view.showToast(text: description)
                                                 }
                                             }
                                    }
                                }
                                break;
                            }
                            
                        }else{
                            self.view.showToast(text: "No Device Bounded")
                            self.performSegue(withIdentifier: "SignInSuccessful", sender: self)
                        }
                    }else{
                        //Incorrect account and password
                        self.view.showToast(text: description[0] as! String)
                        print("=====QBeeSignIn Sign in error=====")
                        print(description)
                        (sender as! UIButton).isEnabled = true
                        //return
                    }
            })
        }
        (sender as! UIButton).isEnabled = true
    }
    
    
}

