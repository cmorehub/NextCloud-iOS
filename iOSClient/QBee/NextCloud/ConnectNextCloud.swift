//
//  ConnectNextCloud.swift
//  QBee
//
//  Created by 劉純源 on 2020/8/7.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import Foundation
import NCCommunication

class ConnectNextCloud
{
    let viewController : UIViewController
    var toNextCloudTestCount: Int = 0
    let toNextCloudTestfuncCountMAX = 10
    var url : String = ""
    
    init(viewController : UIViewController, url:String)
    {
        self.viewController = viewController
        
        if (url.contains("://")) {
            //have ://
            self.url = "https" + url.suffix(from: url.firstIndex(of: ":")!)
        }else{
            self.url = "https://" + url
        }
        print("===========\(self.url)======")
    }
    func toNextCloudTest(){
        
        NCCommunication.sharedInstance.getServerStatus(urlString: url) { (serverProductName, serverVersion, versionMajor, versionMinor, versionMicro, extendedSupport, errorCode, errorDescription) in
            print("=====QBeeSignIn toNextCloudTest errorCode:\(errorCode) =====")
            if (errorCode == 0) {
                print("=====QBeeSignIn toNextCloudTest errorCode:\(errorCode) =====")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.timerErrorNetworking.invalidate()
                self.toNextcloud()
            } else {
                if (errorCode == NSURLErrorServerCertificateUntrusted) {
                    if (self.toNextCloudTestCount > self.toNextCloudTestfuncCountMAX){
                        
                        print("===== QBeeSignIn.swift toNextCloudTest don't unstand errorCode 159 =====")
                        let alertController = UIAlertController(title:"Server Certificate Untrusted", message:
                          "error", preferredStyle:UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                        }
                        alertController.addAction(okAction)
                        self.viewController.present(alertController, animated:true, completion: nil)
                                               
                    }else{
                        print("===== QBeeSignIn.swift toNextCloudTest errorCode=NSURLErrorServerCertificateUntrusted 119 =====")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.timerErrorNetworking.invalidate()
                        NCNetworking.sharedInstance.wrtiteCertificate(directoryCertificate: CCUtility.getDirectoryCerificates())
                        
                        appDelegate.startTimerErrorNetworking()
                        self.toNextCloudTest()
                        self.toNextCloudTestCount += 1
                    }
                } else {
                    print("===== QBeeSignIn.swift toNextCloudTest error unknow errorCode 159 =====")
                    let alertController = UIAlertController(title:"_connection_error_", message:
                      "error", preferredStyle:UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                    }
                    alertController.addAction(okAction)
                    self.viewController.present(alertController, animated:true, completion: nil)
                }
            }
        }
    }
    //MARK:-
    //MARK:切換到Nextcloud頁面
    func toNextcloud(){
        let oc=OCNetworking.sharedManager()
        oc?.getAppPassword(url, username: RemoteItConnectConstants.userNextCloud, password: RemoteItConnectConstants.passwordNextCloud, completion: { (token, message, errorCode) in
            if (errorCode == 0) {
                let account = String(format: "%@ %@", RemoteItConnectConstants.userNextCloud,self.url)
                if NCManageDatabase.sharedInstance.getAccounts() == nil{
                    NCUtility.sharedInstance.removeAllSettings()
                }
                CCUtility.setIntro(true)
                NCManageDatabase.sharedInstance.deleteAccount(account)
                NCManageDatabase.sharedInstance.addAccount(account, url: self.url, user: RemoteItConnectConstants.userNextCloud, password: token!)
                let tableAccount = NCManageDatabase.sharedInstance.setAccountActive(account)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
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
                //if (errorCode != NSURLErrorServerCertificateUntrusted) {
                self.viewController.view.showToast(text: "error  code: \(errorCode), \(message ?? "")")

               // }
            }
        })
    }
}
