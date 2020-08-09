//
//  RemoteItP2P.swift
//  QBee
//
//  Created by 劉純源 on 2020/8/4.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import Foundation
import UIKit
import Remoteit

class RemoteItP2P:RemoteItConnect{
    
    var p2pManager: P2PManager = P2PManager()
    let options: [String: NSObject] = [:]
    var escapeingCallback : ((URL?,String) -> Void)!
    public static let shared = RemoteItP2P()
    var deviceID : String = ""
    
    private init()
    {
        print("============init==============")
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(self.p2pSignedIn), name: NSNotification.Name(rawValue: "kYoicsServerConnectionSucceededNotification"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.p2pConnectionSucceeded), name: NSNotification.Name(rawValue: "p2pConnectionSucceeded"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.p2pConnectionFailed), name: NSNotification.Name(rawValue: "p2pConnectionFailed"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.p2pSignedOut), name: NSNotification.Name(rawValue: "p2pSignedOut"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.p2pSignedFailed), name: NSNotification.Name(rawValue: "p2pSignedFailed"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.p2pSignedFailed), name: NSNotification.Name(rawValue: "kYoicsServerConnectionFailedNotification"), object: nil)
        }
                
    }
        
    @objc func p2pSignedIn(notification: NSNotification) {
        print("=====RemoteitP2P p2pSignedIn =====")
//        RemoteItP2P.sharedP2P.p2pSignOut()
        DispatchQueue.main.async {
            self.p2pManager.connectDevice(deviceID: self.deviceID, options: self.options)
        }
    }
    @objc func p2pSignedFailed(notification: NSNotification) {
        print("=====RemoteitP2P p2pSignedFailed =====")
        if let callback = escapeingCallback
        {
            callback(nil,"RemoteIt SigninFailed")
        }
    }
    @objc func p2pSignedOut(notification: NSNotification) {
        print("=====RemoteitP2P p2pSignedOut =====")
        let dict = notification.object as? [String: NSObject]
        let userName = dict?["userName"] as? String ?? ""
        print("===== \(userName) signed out")
    }
    @objc func p2pConnectionSucceeded(notification: NSNotification) {
        print("=====RemoteitP2P p2pConnectionSucceeded =====")
        let dict = notification.object as? [String: NSObject]
        let deviceAddress = dict?["deviceAddress"] as? String ?? ""
        let url = dict?["url"] as? String ?? ""
        print("\(deviceAddress) connected to \(url)")
        //RemoteItP2P.p2purl = url
        if let callback = escapeingCallback
        {
            print("=====RemoteitP2P url  \(url)=====")
            callback(URL(string: url),"")
        }
        print("===== conection Succeeded =====")
        //RemoteItP2P.callback(URL(string: RemoteItP2P.p2purl),"")
    }
    @objc func p2pConnectionFailed(notification: NSNotification) {
        print("=====RemoteitP2P p2pConnectionFailed =====")
        let dict = notification.object as? [String: NSObject]
        let deviceAddress = dict?["deviceAddress"] as? String ?? ""
        let reason = dict?["reason"] as? String ?? ""
        print("\(deviceAddress) connected failed. Reason: \(reason)")
        if let callback = escapeingCallback
        {
            callback(nil,"\(deviceAddress) connected failed. Reason: \(reason)")
        }
        
    }
    func connect(user: String, password: String, apiKey: String, deviceAddress: String, callback: @escaping (URL?,String) -> Void) {
        escapeingCallback = callback
        RemoteItQBeeAPI.shared.RemoteItLogin(user: user,password: password,apiKey: apiKey,completionHandler: {( error,description)->() in
            print("RR username:\(user) password:\(password)")
            if error == "0"{
                
                RemoteItQBeeAPI.shared.RemoteItListingDevices(apiKey: apiKey,token: description,completionHandler: {( error,description)->() in
                           if error == "0"{
                                //do something
                                let UserDeviceAlias: String = QBeeAPI.shared.AccountBindQBee[deviceAddress]!
                                if let devicealias = description[UserDeviceAlias] as? NSArray{
                                    if devicealias[1] as! String == "active"{
                                        print("This device address is true and active")
                                        //---------------------------------------------
                                        self.deviceID = devicealias[0] as! String
                                        print("login")
                                        do {
                                            try self.p2pManager.signInWithPassword(userName: RemoteItConnectConstants.user , password: RemoteItConnectConstants.password, options: self.options)
                                           
                                        } catch P2PManager.P2PManagerError.invalid_username_password(let reason) {
                                            callback(nil,reason)
                                            print(reason)
                                        } catch P2PManager.P2PManagerError.already_signed_in(let reason) {
                                            callback(nil,reason)
                                            print(reason)
                                        } catch {
                                            callback(nil,"Unexpected error: \(error).")
                                            print("Unexpected error: \(error).")
                                        }
                                        
                                       
                                              //  self.RemoteItData.updateValue(RemoteItP2P.p2purl, forKey: "proxy")
                                                //callback(URL(string: RemoteItP2P.p2purl),"")
                                      
                                        //-----------------------------------------------
                                        
                                        
                                        
                                    }else{// not active
                                        callback(nil,"請將您的QBee開機")
                                    }
                                }else{
                                    //The deviceAddress has not in the RemoteItListingDevice
                                    callback(nil,"您的NextCloud尚未綁定,請將NextCloud開機")
                                }
                            }else{
                                callback(nil,description["deviceaddress"] as! String)
                                print("QBeeMain.swift RemiteItListingDevices error")
                                print("===== Remote It Listing Devices description : \(description) =====")
                            }
                        })
                }else{
                    callback(nil,"")
                    print("QBeeMain.swift RemiteItLogin error")
                    print("===== Remote It Login description : \(description) =====")
                }
            })
    }
    
    
    func disconnect() {
        p2pManager.disconnectDevice(deviceID: deviceID)
        
    }
    func listenUrlChange(listener: (URL) -> Void) {
        
    }
    

    func p2pSignOut(){
        print("signout")
        p2pManager.signOut()
    }
}
