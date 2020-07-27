//
//  Ethernet6.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import Foundation
import NCCommunication

class Ethernet6: UIViewController {
    private static var toNextCloudTestCount = 0
    let toNextCloudTestfuncCountMAX = 9//重複9次
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var RefushButton: UIButton!
    @IBOutlet weak var PleaseWaitLabel: UILabel!
    static var QBeeBoxMAC: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        connectButton.isHidden = true
        RefushButton.isHidden = true
        PleaseWaitLabel.isHidden = false
        myfunc()
    }
    func myfunc(){
        QBeeAPI.shared.login(mail: QBeeAPI.shared.QBeeUser["Account"]!, pwd: QBeeAPI.shared.QBeeUser["Password"]!, completionHandler: {( error,description)->() in
                if error == "0"{
                    RemoteItRest.shared.connect(user: RemoteItRest.user, password: RemoteItRest.password, apiKey: RemoteItRest.apiKey,deviceAddress: Ethernet6.QBeeBoxMAC) { (url,description) in
                        if let url = url{
                            print(url)
                            self.connectButton.isHidden = false
                            self.RefushButton.isHidden = true
                            self.connectButton.isEnabled = true
                            self.RefushButton.isEnabled = false
                            self.PleaseWaitLabel.isHidden = true
                            //RemoteItRest.shared.disconnect()
                        }else{
                            print("No Url Error Code: \(description)")
                            self.view.showToast(text: description)
                            self.connectButton.isHidden = true
                            self.RefushButton.isHidden = false
                            self.connectButton.isEnabled = false
                            self.RefushButton.isEnabled = true
                            self.PleaseWaitLabel.isHidden = true
                        }
                    }
                }
        })
    }
    @IBAction func RefushButton(_ sender: Any) {
        myfunc()
    }
    @IBAction func ButtonTouchUpInside(_ sender: Any) {
        toNextCloudTest()
    }
    func toNextCloudTest(){
        var bang = RemoteItRest.shared.RemoteItData["proxy"]!
        //bang.insert(contentsOf: "s", at: bang.index(bang.startIndex,offsetBy: 4))
        if (bang.range(of:"://") != nil) {
            //have ://
            bang = "https" + bang.suffix(from: bang.firstIndex(of: ":")!)
        }else{
            bang = "https://" + bang
        }
        print(bang)
        let url = bang
        NCCommunication.sharedInstance.getServerStatus(urlString: url) { (serverProductName, serverVersion, versionMajor, versionMinor, versionMicro, extendedSupport, errorCode, errorDescription) in
            print("=====QBeeSignIn toNextCloudTest errorCode:\(errorCode) =====")
            if (errorCode == 0) {
                print("=====QBeeSignIn toNextCloudTest errorCode:\(errorCode) =====")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.timerErrorNetworking.invalidate()
                self.toNextcloud()
        } else {
            if (errorCode == NSURLErrorServerCertificateUntrusted) {
                if (Ethernet6.toNextCloudTestCount > self.toNextCloudTestfuncCountMAX){
                    Ethernet6.toNextCloudTestCount = 0
                    return
                }else{
                    print("===== QBeeSignIn.swift toNextCloudTest errorCode=NSURLErrorServerCertificateUntrusted 119 =====")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.timerErrorNetworking.invalidate()
                    NCNetworking.sharedInstance.wrtiteCertificate(directoryCertificate: CCUtility.getDirectoryCerificates())
                    
                    appDelegate.startTimerErrorNetworking()
                    self.toNextCloudTest()
                    Ethernet6.toNextCloudTestCount += 1
                }
            } else {
                print("===== QBeeSignIn.swift toNextCloudTest don't unstand errorCode 159 =====")
                let alertController = UIAlertController(title:"_connection_error_", message:
                  "error", preferredStyle:
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
            if NCManageDatabase.sharedInstance.getAccounts() == nil{
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
        else{
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
