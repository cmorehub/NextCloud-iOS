//
//  Ethernet5.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import Foundation

class Ethernet5: UIViewController {
    var QBeeBoxMAC: String = ""
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var BindButton: UIButton!
    @IBOutlet weak var DeviceIDLabel: UILabel!
    @IBOutlet weak var DeviceStatusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        DeviceIDLabel.text = QBeeBoxMAC
        if !QBeeAPI.shared.QBeeBoxMAC.contains(QBeeBoxMAC){
            DeviceStatusLabel.text = "未綁定"
            BindButton.isHidden = false
            BackButton.isHidden = true
            print("=====")
            if !QBeeAPI.shared.QBeeUser.isEmpty{
                print(QBeeAPI.shared.QBeeUser)
            }

        }else{
            DeviceStatusLabel.text = "已綁定過此裝置了"
            BindButton.isHidden = true
            BackButton.isHidden = false
        }
    }
    @IBAction func BindButtonTouchUpInside(_ sender: Any) {
        QBeeAPI.shared.appAdd(mail: QBeeAPI.shared.QBeeUser["Account"]!, pwd: QBeeAPI.shared.QBeeUser["Password"]!, mac: QBeeBoxMAC, completionHandler: {( error,description)->() in
            if error == "0"{
                //Successful
                self.performSegue(withIdentifier: "SuccessfulBindQBeeBox", sender: self)
                Ethernet6.QBeeBoxMAC = self.QBeeBoxMAC
            }else{
                //false
                self.view.showToast(text: description)
                self.BindButton.isHidden = true
                self.BackButton.isHidden = false
            }
        })
    }
}
