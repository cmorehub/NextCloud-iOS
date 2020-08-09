//
//  RemoteltConnect.swift
//  QBee
//
//  Created by 劉純源 on 2020/7/7.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import UIKit
import Foundation

//static let user = "ccmaped@gmail.com"
//static let password = "maped1234"
//static let apiKey = "QzlEQ0JDQzItNjYyMC00RjVCLUIwOTgtQkFBQkNCMzgxRUFG"

struct RemoteItConnectConstants {
    static let userNextCloud = "admin"
    static let passwordNextCloud = "admin"
    static let user = "ccmaped@gmail.com"
    static let password = "maped1234"
    static let apiKey = "QzlEQ0JDQzItNjYyMC00RjVCLUIwOTgtQkFBQkNCMzgxRUFG"
}
protocol RemoteItConnect {
    
    func connect(user: String,password: String,apiKey: String,deviceAddress: String,callback:@escaping(_ url:URL?, _ description:String)->Void)
    func disconnect()
    func listenUrlChange(listener:(_ url:URL) -> Void)
}
