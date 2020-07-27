//
//  QBeeSignIn.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
import UIKit
import Foundation
import NCCommunication

class QBeeSignIn: UIViewController {
    @IBOutlet weak var EmailAddressTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    private static var toNextCloudTestCount: Int = 0
    let toNextCloudTestfuncCountMAX = 10
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
                            let datas = description as! [NSDictionary]
                            for data in datas{
                                print("============asdasdasda==========")
                                print(data["mac"] as! String)
                                QBeeAPI.shared.QBeeBoxMAC.add(data["mac"]as! String)
                                //QBeeAPI.QBeeUserBoxMAC = data["mac"]as! String
                                if let remote = data["remote"] as? String{
                                    print(remote)
                                    QBeeAPI.shared.AccountBindQBee[data["mac"] as! String] = remote
                                }else{
                                    print("NULL")
                                }
                            }
                            for BoxMAC in QBeeAPI.shared.QBeeBoxMAC{
                                RemoteItRest.shared.connect(user: RemoteItRest.user, password: RemoteItRest.password, apiKey: RemoteItRest.apiKey, deviceAddress: BoxMAC as! String) { (url, description) in
                                    if let url = url{
                                        print(url)
                                        //self.view.showToast(text: url as! String)
                                        self.toNextCloudTest()
                                        //self.toNextcloud()
                                    }else{
                                        print("No Url Error Code: \(description)")
                                        self.view.showToast(text: description)
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
                        print("==========")
                        (sender as! UIButton).isEnabled = true
                        //return
                    }
            })
        }
        (sender as! UIButton).isEnabled = true
    }
    func toNextCloudTest(){
        var ProxyUrl = RemoteItRest.shared.RemoteItData["proxy"]!
        //bang.insert(contentsOf: "s", at: bang.index(bang.startIndex,offsetBy: 4))
        if (ProxyUrl.range(of:"://") != nil) {
            //have ://
            ProxyUrl = "https" + ProxyUrl.suffix(from: ProxyUrl.firstIndex(of: ":")!)
            
        }else{
            ProxyUrl = "https://" + ProxyUrl
        }
        print(ProxyUrl)
        let url = ProxyUrl
        NCCommunication.sharedInstance.getServerStatus(urlString: url) { (serverProductName, serverVersion, versionMajor, versionMinor, versionMicro, extendedSupport, errorCode, errorDescription) in
            print("=====QBeeSignIn toNextCloudTest errorCode:\(errorCode) =====")
        
            
            if (errorCode == 0) {
                print("=====QBeeSignIn toNextCloudTest errorCode:\(errorCode) =====")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.timerErrorNetworking.invalidate()
                self.toNextcloud()
//                if (_user.hidden && _password.hidden && versionMajor >= k_flow_version_available) {
//                    NSLog(@"===== CCLogin.m testUrl NCLoginWeb 187 =====");
//                    NCLoginWeb *activeLoginWeb = [[UIStoryboard storyboardWithName:@"CCLogin" bundle:nil] instantiateViewControllerWithIdentifier:@"NCLoginWeb"];
//                    activeLoginWeb.urlBase = self.baseUrl.text;
//
//                    [self.navigationController pushViewController:activeLoginWeb animated:true];
//                }
//
//                // NO Login Flow available
//                if (versionMajor < k_flow_version_available) {
//
//                    [self.loginTypeView setHidden:YES];
//
//                    _imageUser.hidden = NO;
//                    _user.hidden = NO;
//                    _imagePassword.hidden = NO;
//                    _password.hidden = NO;
//
//                    [_user becomeFirstResponder];
//                }
//
            } else {
//
                if (errorCode == NSURLErrorServerCertificateUntrusted) {
                    if (QBeeSignIn.toNextCloudTestCount > self.toNextCloudTestfuncCountMAX){
                        QBeeSignIn.toNextCloudTestCount = 0
                        return
                    }else{
                        print("===== QBeeSignIn.swift toNextCloudTest errorCode=NSURLErrorServerCertificateUntrusted 119 =====")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.timerErrorNetworking.invalidate()
                        NCNetworking.sharedInstance.wrtiteCertificate(directoryCertificate: CCUtility.getDirectoryCerificates())
                        
                        appDelegate.startTimerErrorNetworking()
                        self.toNextCloudTest()
                        QBeeSignIn.toNextCloudTestCount += 1
                    }
                } else {
                    print("===== QBeeSignIn.swift toNextCloudTest don't unstand errorCode 159 =====")
                    let alertController = UIAlertController(title:"_connection_error_", message:
                        errorDescription, preferredStyle:
                        UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated:true, completion: nil)
//                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"_connection_error_", nil) message:errorDescription preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"_ok_", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
//
//                    [alertController addAction:okAction];
//                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
            
        }
    }
    //MARK:-
    //MARK:切換到Nextcloud頁面
    func toNextcloud(){
        
        /*----------sorry my https------*/
        var bang = RemoteItRest.shared.RemoteItData["proxy"]!
        bang.insert(contentsOf: "s", at: bang.index(bang.startIndex,offsetBy: 4))
        print(bang)
        var url = bang
        let user = "admin"
        let password = "admin"
        /*-heyehyeheyheyheyheyehyheyeh------*/
        //var url="http://iottalk.cmoremap.com.tw:6325"
                //let user = "ccmaped@gmail.com"
                //let password = "maped1234"
                //let user="bibby"
                //let password="97497929"
                if url.substring(from: url.count-1, length: 1) == "/"{
                    url = url.substring(from: 0, length: url.count-1)!
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
}

