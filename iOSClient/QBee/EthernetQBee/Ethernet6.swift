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
    var QBeeBoxMAC: String = ""
    var url : String = ""
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
                    
                    ///tien 要判斷Ethernet6.QBeeBoxMAC有沒有在QBeeAPI.shared.AccountBindQBee這個資料裡
                    //有的話做底下，沒有的話跳Ethernet3
                    if QBeeAPI.shared.AccountBindQBee[self.QBeeBoxMAC] != nil {
                        RemoteItP2P.shared.connect(user: RemoteItConnectConstants.user, password: RemoteItConnectConstants.password, apiKey: RemoteItConnectConstants.apiKey, deviceAddress: self.QBeeBoxMAC ) { (url, description) in
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
                                RemoteItRest.shared.connect(user:RemoteItConnectConstants.user, password: RemoteItConnectConstants.password, apiKey: RemoteItConnectConstants.apiKey,deviceAddress: self.QBeeBoxMAC) { (url,description) in
                                     if let url = url{
                                         print(url)
                                         self.url = url.absoluteString
                                         self.connectButton.isHidden = false
                                         self.RefushButton.isHidden = true
                                         self.connectButton.isEnabled = true
                                         self.RefushButton.isEnabled = false
                                         self.PleaseWaitLabel.isHidden = true
                                         ConnectNextCloud(viewController: self, url: url.absoluteString).toNextCloudTest()
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
                            
                        }
                    }else {
                        self.performSegue(withIdentifier: "AccountNoQBeeMAC", sender: self)
                    }
                    
                }
        })
    }
    @IBAction func RefushButton(_ sender: Any) {
        myfunc()
    }
    @IBAction func ButtonTouchUpInside(_ sender: Any) {
        ConnectNextCloud(viewController: self, url: self.url).toNextCloudTest()
        
    }
    

}
