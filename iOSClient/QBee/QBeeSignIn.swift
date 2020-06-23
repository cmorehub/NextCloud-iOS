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
    
    func checkTextField() -> Bool{
        if (EmailAddressTextField.text != "" || PasswordTextField.text != ""){
            return true
        }
        view.showToast(text: "Please input your Email or Password")
        return false
    }
    
    @IBAction func SignInButtonTouchUpInside(_ sender: Any) {
        (sender as! UIButton).isEnabled = false
        if checkTextField(){
            QBeeAPI.shared.login(mail: EmailAddressTextField.text!, pwd: PasswordTextField.text!, completionHandler: {( error,description)->() in
                    if error == "0"{
                        //Successfully
                        QBeeAPI.shared.QBeeUser.updateValue(self.EmailAddressTextField.text!, forKey: "Account")
                        QBeeAPI.shared.QBeeUser.updateValue(self.PasswordTextField.text!, forKey: "Password")
                        if description.count>0 {
                            let datas = description as! [NSDictionary]
                            for data in datas
                            {
                                
                                print(data["mac"] as! String)
                                
                                QBeeAPI.shared.QBeeBoxMAC.add(data["mac"]as! String)
                                if let remote = data["remote"] as? String
                                {
                                    print(remote)
                                }
                                else
                                {
                                        print("NULL")
                                }
                            }
                            var url="http://iottalk.cmoremap.com.tw:6325"
                                    let user="bibby"
                                    let password="97497929"
                                    if url.substring(from: url.count-1, length: 1) == "/"
                                    {
                                        url=url.substring(from: 0, length: url.count-1)!
                                    }
                                    let oc=OCNetworking.sharedManager()
                                    
                                    oc?.getAppPassword(url, username: user, password: password, completion: { (token, message, errorCode) in
                                        if (errorCode == 0) {
                                            let account = String(format: "%@ %@", user,url)
                                            if NCManageDatabase.sharedInstance.getAccounts() == nil
                                            {
                                                NCUtility.sharedInstance.removeAllSettings()
                                            }
                                            CCUtility.setIntro(true)
                                            NCManageDatabase.sharedInstance.deleteAccount(account)
                                            NCManageDatabase.sharedInstance.addAccount(account, url: url, user: user, password: token!)
                                            let tableAccount = NCManageDatabase.sharedInstance.setAccountActive(account)
                                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                                
                                            // = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                            appDelegate.settingActiveAccount(tableAccount?.account, activeUrl: tableAccount?.url, activeUser:tableAccount?.user, activeUserID: tableAccount?.userID, activePassword: CCUtility.getPassword(tableAccount?.account))
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "initializeMain"), object: nil, userInfo: nil)
                                            
                                            let splitController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                                            splitController?.modalPresentationStyle = .fullScreen
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "initializeMain"), object: nil, userInfo: nil)
                                            splitController!.view.alpha = 0
                                            appDelegate.window.rootViewController = splitController!
                                            appDelegate.window.makeKeyAndVisible()
                                            UIView.animate(withDuration: 0.5) {
                                                splitController!.view.alpha = 1
                                            }
                                        }
                                        else
                                        {
                                            if (errorCode != NSURLErrorServerCertificateUntrusted) {
                                                self.view.showToast(text: "Server Certificate Untrusted!")
                                                
                            //                    var messageAlert = String(format: "%@.\n%@", NSLocalizedString(@"_not_possible_connect_to_server_", nil),message)
                            //
                            //
                            //                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_error_", nil) message:messageAlert preferredStyle:UIAlertControllerStyleAlert];
                            //                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_ok_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                            //
                            //                    [alertController addAction:okAction];
                            //                    [self presentViewController:alertController animated:YES completion:nil];
                                           }
                                            
                                            
                                        }
                                    })
                            
                            
                            
                        }
                        else
                        {
                            self.view.showToast(text: "No Device Bounded")
                            self.performSegue(withIdentifier: "SignInSuccessful", sender: self)
                            
                        }
                        
                    }else{
                        //Incorrect account and password
                        self.view.showToast(text: description[0] as! String)
                        print("=====QBeeSignIn Sign in error=====")
                        print(description)
                        print("==========")
                        return
                    }
            })
        }
    }
    
}

