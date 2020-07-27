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

        print("QQQQQQviewDidLoad")
    }
    @IBAction func ButtonTouchUpInside(_ sender: Any) {
        let qrcode=NCLoginQRCode(delegate: self)
        qrcode.scan()
    }
    
    func dismissQRCode(_ value: String?, metadataType: String?) {
        if value != nil{
            print("QQQQQQdismissQRCode" + value!)
            QRCodeGetQBeeMAC = value!

            let alertController = UIAlertController(title:"Successful QRCode Scan", message:
              "device address = \(QRCodeGetQBeeMAC)", preferredStyle:
                UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                self.performSegue(withIdentifier: "SuccessfulGetMAC", sender: self)
            }
            
            alertController.addAction(okAction)

            self.present(alertController, animated:true, completion: nil)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        print("QQQQQQviewDidAppear:\(QRCodeGetQBeeMAC)")
        if QRCodeGetQBeeMAC != "" {

            print("QQQQQQQRCodeGetQBeeMAC != :\(QRCodeGetQBeeMAC)")
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


