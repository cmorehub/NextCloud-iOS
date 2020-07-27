//
//  RemoteItRest.swift
//  QBee
//
//  Created by 劉純源 on 2020/7/7.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import UIKit
import Foundation

class RemoteItRest:RemoteItConnect{
    
    public static let shared = RemoteItRest()
    var RemoteItData: [String:String] = ["apiKey":"","userToken":"","deviceaddress":"","hostip":"","proxy":"","connectionid":"","ProxyUrl":""]
    //MARK:-
    //MARK:User
    static let user = "ccmaped@gmail.com"
    static let password = "maped1234"
    static let apiKey = "QzlEQ0JDQzItNjYyMC00RjVCLUIwOTgtQkFBQkNCMzgxRUFG"
    //MARK:-
    //MARK:Remote It API
    func connect(user: String, password: String, apiKey: String, deviceAddress: String, callback: @escaping (URL?,String) -> Void) {
        self.RemoteItData.updateValue(apiKey, forKey: "apiKey")
        RemoteItQBeeAPI.shared.RemoteItLogin(user: user,password: password,apiKey: apiKey,completionHandler: {( error,description)->() in
            print("RR username:\(user) password:\(password)")
            if error == "0"{
                self.RemoteItData.updateValue(description, forKey: "userToken")
                RemoteItQBeeAPI.shared.RemoteItListingDevices(apiKey: apiKey,token: self.RemoteItData["userToken"]!,completionHandler: {( error,description)->() in
                           if error == "0"{
                                //do something
                                let UserDeviceAlias: String = QBeeAPI.shared.AccountBindQBee[deviceAddress]!
                                if let devicealias = description[UserDeviceAlias] as? NSArray{
                                    if devicealias[1] as! String == "active"{
                                        print("This device address is true and active")
                                        RemoteItQBeeAPI.shared.RemoteItConnectingToService(apiKey: apiKey,token: self.RemoteItData["userToken"]!,deviceaddress: devicealias[0] as! String,completionHandler: {( error,description,connectionid)->() in
                                            if error == "0"{
                                                self.RemoteItData.updateValue(description, forKey: "proxy")
                                                self.RemoteItData.updateValue(connectionid, forKey: "connectionid")
                                                print("===== Remote It ConnectingToService proxy : \(description) =====")
                                                callback(URL(string: description),"")
                                            }else{
                                                callback(nil,description)
                                                print("QBeeMain.swift RemiteItConnectingToService error")
                                                print("===== Remote It ConnectingToService description : \(description) =====")
                                                }
                                            })
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
        RemoteItQBeeAPI.shared.RemoteItDisconnect(apiKey: self.RemoteItData["apiKey"]!, token: self.RemoteItData["userToken"]!, deviceaddress: self.RemoteItData["deviceaddress"]!, connectionid: self.RemoteItData["connectionid"]!, completionHandler: {( error,description)->() in
            if error == "0"{
                print("===== Remote It Disconnection \(description)")
            }else{
                print("===== Remote It Error \(description)")
            }
        })
    }
    func listenUrlChange(listener: (URL) -> Void) {
        
    }
    
}
