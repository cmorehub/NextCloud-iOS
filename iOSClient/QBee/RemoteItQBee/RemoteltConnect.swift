//
//  RemoteltConnect.swift
//  QBee
//
//  Created by 劉純源 on 2020/7/7.
//  Copyright © 2020 Marino Faggiana. All rights reserved.
//

import UIKit
import Foundation

protocol RemoteItConnect {
    func connect(user: String,password: String,apiKey: String,deviceAddress: String,callback:@escaping(_ url:URL?, _ description:String)->Void)
    func disconnect()
    func listenUrlChange(listener:(_ url:URL) -> Void)
}
