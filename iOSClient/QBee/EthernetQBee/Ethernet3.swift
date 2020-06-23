//
//  Ethernet3.swift
//  QBee
//
//  Created by 劉純源 on 2020/6/15.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import Foundation

class Ethernet3: UIViewController,NCLoginQRCodeDelegate {
    var QRCodeGetQBeeMAC: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func ButtonTouchUpInside(_ sender: Any) {
        let qrcode=NCLoginQRCode(delegate: self)
        qrcode.scan()
    }
    
    func dismissQRCode(_ value: String?, metadataType: String?) {
        if value != nil{
            print(value!)
            QRCodeGetQBeeMAC = value!
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear:\(QRCodeGetQBeeMAC)")
        if QRCodeGetQBeeMAC != "" {
            self.performSegue(withIdentifier: "SuccessfulGetMAC", sender: self)
        }
    }
    //MARK:-
    //MARK:掃QRCode獲得的MAC傳入到下一個畫面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dst = (segue.destination as! Ethernet5)
        dst.QBeeBoxMAC = QRCodeGetQBeeMAC
    }
    
    //MARK:-
    //MARK:被返回到此頁面時觸發
    @IBAction func Myback(segue: UIStoryboardSegue) {
        //print("Unwind to Root View Controller")
        QRCodeGetQBeeMAC = ""
    }
}


