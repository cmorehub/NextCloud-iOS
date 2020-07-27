//
//  RemoteItQBeeAPI.swift
//  QBee
//
//  Created by 劉純源 on 2020/7/1.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import UIKit
import Foundation

class RemoteItQBeeAPI{
    public static let shared = RemoteItQBeeAPI()
    //MARK:-
    //MARK:Remote it API Url
    let RemoteItLoginUrl = URL(string: "https://api.remot3.it/apv/v27/user/login")
    let RemoteItListingDevicesUrl = URL(string: "https://api.remot3.it/apv/v27/device/list/all")
    let RemoteItConnectingToServiceUrl = URL(string: "https://api.remot3.it/apv/v27/device/connect")
    let RemoteItDisconnectUrl = URL(string: "https://api.remot3.it/apv/v27/device/connect/stop")
    //MARK:-
    //MARK:Remote it POST
    //MARK:Login
    func RemoteItLogin(user: String,password: String,apiKey: String,completionHandler:@escaping(_ error:String, _ description:String)->Void) {
        print("RIQA username:\(user) password:\(password)")
        let parameters = "{ \"username\":\"\(user)\",\"password\":\"\(password)\" }"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: RemoteItLoginUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.addValue(apiKey, forHTTPHeaderField: "developerkey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    completionHandler("-1","===== RemoteItQBeeAPI.swift RemoteItLogin Error:" + error!.localizedDescription + " =====")
                    return
                }
                guard let data = data else {
                    print(String(describing: error))
                    completionHandler("-1", "===== RemoteItQBeeAPI.swift RemoteItLogin Error: data error =====")
                    return
                }
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                        if let status = json["status"] as? String {
                            if status == "true"{
                                if let token = json["token"] as? String {
                                    completionHandler("0",token)
                                }else{
                                    completionHandler("-1","===== RemoteItQBeeAPI.swift RemoteItLogin Error: This Json Data not have token =====")
                                }
                            }else if status == "false"{
                                if let reason = json["reason"] as? String {
                                    completionHandler("1","===== RemoteItQBeeAPI.swift RemoteItLogin \(reason)")
                                }
                            }else{
                                completionHandler("-1","===== RemoteItQBeeAPI.swift RemoteItLogin Error: Something has Error! =====")
                            }
                        }else{
                            completionHandler("-1","===== RemoteItQBeeAPI.swift RemoteItLogin Error: This Json Data not have status =====")
                        }
                    }else{
                        completionHandler("-1","===== RemoteItQBeeAPI.swift RemoteItLogin Error: Couldn't decode JSON data! =====")
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    completionHandler("-1","===== RemoteItQBeeAPI.swift RemoteItLogin Failed to load: \(error.localizedDescription) =====")
                }
            }
        }
        dataTask.resume()
    }
    //MARK:-
    //MARK:Remote it GET
    //MARK:Listing Devices
    //JSON devices must get !!devicesaddress,devicelastip  , devicestate!!
    /* func RemoteItListingDevices(apiKey: String,token: String, completionHandler:@escaping(_ error:String, _ description:String, _ devicelastip:String, _ devicestate:String)->Void) {
        var request = URLRequest(url: RemoteItListingDevicesUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.addValue(apiKey, forHTTPHeaderField: "developerkey")
        request.addValue(token, forHTTPHeaderField: "token")
        request.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    completionHandler("-1", "===== RemoteItListingDevices Error: " + error!.localizedDescription + " =====","","")
                    return
                }
                guard let data = data else {
                    print(String(describing: error))
                    completionHandler("-1", "===== RemoteListingDevices Error: data error =====","","")
                    return
                }
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                        if let status = json["status"] as? String {
                            if status == "true"{
                                if let devices = json["devices"] as? NSArray{
                                    let datas = devices as! [NSDictionary]
                                    for data in datas{
                                        if let deviceaddress = data["deviceaddress"] as? String, let devicelastip = data["devicelastip"] as? String, let devicestate = data["devicestate"] as? String {
                                            print("deviceaddress = \(deviceaddress)")
                                            completionHandler("0",deviceaddress,devicelastip,devicestate)
                                        }else{
                                            completionHandler("-1","Error:Parse deviceaddress or devicelastip or devicestate JSON data Error","","")
                                        }
                                    }
                                }
                            }else if status == "false"{
                                if let reason = json["reason"] as? String {
                                    completionHandler("1",reason,"","")
                                }
                            }else{
                                completionHandler(status,"Error: Something has Error!.","","")
                            }
                        }
                    }else{
                        completionHandler("-1","Error: Couldn't decode JSON data!","","")
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    completionHandler("-1","Failed to load: \(error.localizedDescription)","","")
                }
            }
        }
        dataTask.resume()
    }*/
    //MARK:Level 2.0
    func RemoteItListingDevices(apiKey: String,token: String, completionHandler:@escaping(_ error:String, _ description:NSDictionary)->Void) {
        var request = URLRequest(url: RemoteItListingDevicesUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.addValue(apiKey, forHTTPHeaderField: "developerkey")
        request.addValue(token, forHTTPHeaderField: "token")
        request.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    completionHandler("-1", ["deviceaddress":"===== RemoteItListingDevices Error: " + error!.localizedDescription + " ====="])
                    return
                }
                guard let data = data else {
                    print(String(describing: error))
                    completionHandler("-1", ["deviceaddress":"===== RemoteListingDevices Error: data error ====="])
                    return
                }
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                        if let status = json["status"] as? String {
                            if status == "true"{
                                if let devices = json["devices"] as? NSArray{
                                    if devices.count > 0{
                                        let datas = devices as! [NSDictionary]
                                        var deviceDictionray: [String : [String]]=[:]
                                        var jsonDataState = false
                                        for data in datas{
                                            if let devicealias = data["devicealias"] as? String,let deviceaddress = data["deviceaddress"] as? String, let devicestate = data["devicestate"] as? String {
                                                
                                                print("deviceaddress = \(deviceaddress)")
                                                deviceDictionray.updateValue([deviceaddress, devicestate], forKey: devicealias)
                                                jsonDataState = true
                                            }else{
                                                completionHandler("-1",["deviceaddress":"Error:Parse deviceaddress or devicelastip or devicestate JSON data Error"])
                                                jsonDataState = false
                                                break
                                            }
                                        }

                                        if jsonDataState {
                                            completionHandler("0",deviceDictionray as NSDictionary)
                                        }
                                    }else{
                                          completionHandler("-1",["deviceaddress":"Error:No Devices"])
                                    }
                                }else{
                                    completionHandler("-1",["deviceaddress":"Error:Parse deviceaddress or devicelastip or devicestate JSON data Error"])
                                }
                            }else if status == "false"{
                                if let reason = json["reason"] as? String {
                                    completionHandler("1",["deviceaddress":reason])
                                }
                            }else{
                                completionHandler(status,["deviceaddress":"Error: Something has Error!."])
                            }
                        }
                    }else{
                        completionHandler("-1",["deviceaddress":"Error: Couldn't decode JSON data!"])
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    completionHandler("-1",["deviceaddress":"Failed to load: \(error.localizedDescription)"])
                }
            }
        }
        dataTask.resume()
    }
    //MARK:-
    //MARK:Remote it POST
    //MARK:Connecting to Service using the API
    func RemoteItConnectingToService(apiKey: String, token: String, deviceaddress: String,completionHandler:@escaping(_ error:String, _ description:String, _ connectionId:String)->Void) {
        let parameters = "{\"wait\":\"true\",\"deviceaddress\":\"\(deviceaddress)\"}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: RemoteItConnectingToServiceUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.addValue(apiKey, forHTTPHeaderField: "developerkey")
        request.addValue(token, forHTTPHeaderField: "token")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    completionHandler("-1", "===== RemoteItConnectingToService Error: " + error!.localizedDescription + " =====","")
                    return
                }
                guard let data = data else {
                    print(String(describing: error))
                    completionHandler("-1", "===== RemoteItConnectingToService Error: data error =====","")
                    return
                }
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                        if let status = json["status"] as? String {
                            if status == "true"{
                                if let connection = json["connection"] as? NSDictionary,let proxy = connection["proxy"] as? String,let connectionid = json["connectionid"] as? String{
                                    completionHandler("0",proxy,connectionid)
                                }else{
                                    completionHandler("false","Parse Json Error","")
                                }
                            }else if status == "false"{
                                if let reason = json["reason"] as? String {
                                    completionHandler("1",reason,"")
                                }
                            }else{
                                completionHandler(status,"Error: Something has Error!.","")
                            }
                        }else{
                            completionHandler("-1","Parse Status Json Error","")
                        }
                    }else{
                        completionHandler("-1","Error: Couldn't decode JSON data!","")
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    completionHandler("-1","Failed to load: \(error.localizedDescription)","")
                }
            }
        }
        dataTask.resume()
    }
    //MARK:-
    //MARK:Remote it POST
    //MARK:Connecting to Service using the API
    func RemoteItDisconnect(apiKey: String, token: String, deviceaddress: String,connectionid: String,completionHandler:@escaping(_ error:String, _ description:String)->Void) {
        let parameters = "{\"deviceaddress\":\"\(deviceaddress)\",\"connectionid\":\"\(connectionid)\"}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: RemoteItDisconnectUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.addValue(apiKey, forHTTPHeaderField: "developerkey")
        request.addValue(token, forHTTPHeaderField: "token")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    completionHandler("-1", "===== RemoteItConnectingToService Error: " + error!.localizedDescription + " =====")
                    return
                }
                guard let data = data else {
                    print(String(describing: error))
                    completionHandler("-1", "===== RemoteItConnectingToService Error: data error =====")
                    return
                }
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // try to read out a string array
                        if let status = json["status"] as? String {
                            if status == "true"{
                                completionHandler("0","Successful")
                            }else if status == "false"{
                                if let reason = json["reason"] as? String {
                                    completionHandler("1",reason)
                                }
                            }else{
                                completionHandler(status,"Error: Something has Error!.")
                            }
                        }
                    }else{
                        completionHandler("-1","Error: Couldn't decode JSON data!")
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    completionHandler("-1","Failed to load: \(error.localizedDescription)")
                }
            }
        }
        dataTask.resume()
    }
//MARK:-
//MARK:END
}

