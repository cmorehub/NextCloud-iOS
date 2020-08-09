//
//  myTestClass.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/12.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//
import UIKit
import Foundation


//此Class為註冊新帳戶與添加QBee
class QBeeAPI{
    struct GetJsonAPIResponseStruct: Decodable {
        var result: String
        var error: String
    }
    struct loginStruct: Decodable {
        var result: String
        var error: String
    }

    public static let shared = QBeeAPI()
    //var QBeeBoxMAC  = NSMutableSet()//QBee MAC
    //static var QBeeUserBoxMAC = ""
    var QBeeUser: [String:String] = ["Account":"","Password":""]
    var AccountBindQBee: [String:String] = [:] // to askey QBee Login
    let RegisterUrl = URL(string: "http://askeyqb.com/askey_macbind.php")
 
    //register: 1.Email check
    func mailCheck(mail: String,completionHandler:@escaping(_ error:String, _ description:String)->Void) {
        var request = URLRequest(url: RegisterUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpBody = "type=mailcheck&mail=\(mail)".data(using: .utf8)
        request.httpMethod = "POST"

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data,response,error) in
            DispatchQueue.main.async {
                
                if error != nil {
                    print(error!)
                    completionHandler("-1", error!.localizedDescription)
                    return
                }
                guard let JsonData = try?JSONDecoder().decode(GetJsonAPIResponseStruct.self,from: data!) else{
                    completionHandler("-1", "Error: Couldn't decode JSON data!")
                    return
                }
                completionHandler(JsonData.result, String(JsonData.error))
            }
        }
        dataTask.resume()
    }
    //register: 2.Code check
    func codeCheck(mail:String,code:String,completionHandler:@escaping(_ error:String, _ description:String)->Void) {
        var request = URLRequest(url: RegisterUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpBody = ("type=codecheck&mail=" + mail + "&code=" + code).data(using: .utf8)
        request.httpMethod = "POST"

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data,response,error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    completionHandler("-1", error!.localizedDescription)
                    return
                }
                guard let JsonData = try?JSONDecoder().decode(GetJsonAPIResponseStruct.self,from: data!) else{
                    completionHandler("-1", "Error: Couldn't decode JSON data!")
                    print("Error: Couldn't decode JSON data!")
                    return
                }
                completionHandler(JsonData.result, String(JsonData.error))
            }
        }
        dataTask.resume()
    }
    //register: 3.register
    func register(mail:String,pwd:String,completionHandler:@escaping(_ error:String, _ description:String)->Void) {
        var request = URLRequest(url: RegisterUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpBody = ("type=register&mail=" + mail + "&pwd=" + pwd).data(using: .utf8)
        request.httpMethod = "POST"

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data,response,error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    return
                }
                guard let JsonData = try?JSONDecoder().decode(GetJsonAPIResponseStruct.self,from: data!) else{
                    print("Error: Couldn't decode JSON data!")
                    return
                }
                completionHandler(JsonData.result, String(JsonData.error))
            }
        }
        dataTask.resume()
    }

    func appAdd(mail:String,pwd:String,mac:String,completionHandler:@escaping(_ error:String, _ description:String)->Void) {
        var request = URLRequest(url: RegisterUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpBody = ("type=app_add&mail=" + mail + "&pwd=" + pwd + "&mac=" + mac).data(using: .utf8)
        request.httpMethod = "POST"

        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data,response,error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error!)
                    return
                }
                guard let JsonData = try?JSONDecoder().decode(GetJsonAPIResponseStruct.self,from: data!) else{
                    print("Error: Couldn't decode JSON data!")
                    return
                }
                completionHandler(JsonData.result, String(JsonData.error))
            }
        }
        dataTask.resume()
    }

    func login(mail:String,pwd:String,completionHandler:@escaping(_ error:String, _ description:NSArray)->Void) {
        var request = URLRequest(url: RegisterUrl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpBody = ("type=login&mail=" + mail + "&pwd=" + pwd).data(using: .utf8)
        request.httpMethod = "POST"
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { (data,response,error) in
            DispatchQueue.main.async {

                if error != nil {
                    print(error!)
                    completionHandler("-1",[error!.localizedDescription])
                
                    return
                }
                do {
                    // make sure this JSON is in the format we expect
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        // try to read out a string array
                        if let result = json["result"] as? String {
                            if result == "0"{
                                if let error = json["error"] as? NSArray {
                                    
                                    if error.count>0 {
                                        let datas = error as! [NSDictionary]
                                        for data in datas{
                                            
                                            print(data["mac"] as! String)
                                            
                                            if let remote = data["remote"] as? String{
                                                print(remote)
                                                QBeeAPI.shared.AccountBindQBee[data["mac"] as! String] = remote
                                            }else{
                                                print("NULL")
                                            }
                                        }
                                    }
                                    
                                    completionHandler(result,error)
                                    
                                }
                            }else{
                                if let error = json["error"] as? String {
                                    completionHandler(result,[error])
                                }
                                
                            }
                        }
                    }
                    else
                    {

                        completionHandler("-1",["Error: Couldn't decode JSON data!"])
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                    completionHandler("-1",["Failed to load: \(error.localizedDescription)"])
                }
            }
        }
        dataTask.resume()
    }
}

//MARK:-
//MARK:Custom Toast
//MARK:PLEASE DON'T TOUCH THIS
extension UIView{

    func showToast(text: String){
        
        self.hideToast()
        let toastLb = UILabel()
        toastLb.numberOfLines = 0
        toastLb.lineBreakMode = .byWordWrapping
        toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLb.textColor = UIColor.white
        toastLb.layer.cornerRadius = 10.0
        toastLb.textAlignment = .center
        toastLb.font = UIFont.systemFont(ofSize: 15.0)
        toastLb.text = text
        toastLb.layer.masksToBounds = true
        toastLb.tag = 9999//tag：hideToast實用來判斷要remove哪個label
        
        let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
        var expectedSize = toastLb.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height
        if maxSize.width >= expectedSize.width{
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height{
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)
        toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2), y: self.bounds.height - expectedSize.height - 40 - 20, width: expectedSize.width + 20, height: expectedSize.height + 20)
        self.addSubview(toastLb)
        
        UIView.animate(withDuration: 1.5, delay: 1.5, animations: {
            toastLb.alpha = 0.0
        }) { (complete) in
            toastLb.removeFromSuperview()
        }
    }
    
    func hideToast(){
        for view in self.subviews{
            if view is UILabel , view.tag == 9999{
                view.removeFromSuperview()
            }
        }
    }
}
//MARK:-
//MARK:HIDE KEYBOARD 按下Return或是點擊其他地方隱藏鍵盤
extension QBeeSignIn: UITextFieldDelegate {
    //按下Return
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    //點擊其他地方
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension QBeeSignUp: UITextFieldDelegate {
    //按下Return
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    //點擊其他地方
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//extension QBeeVerifyYourAccount: UITextFieldDelegate {
//    //按下Return
//    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return true
//    }
//    //點擊其他地方
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//}

//MARK:-
//MARK:END
