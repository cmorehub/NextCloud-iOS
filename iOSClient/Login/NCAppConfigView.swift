//
//  NCAppConfigView.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 18/09/2019.
//  Copyright © 2019 Marino Faggiana. All rights reserved.
//
//  Author Marino Faggiana <marino.faggiana@nextcloud.com>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

class NCAppConfigView: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    private var serverUrl: String?
    private var username: String?
    private var password: String?
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = NCBrandColor.sharedInstance.brand
        titleLabel.textColor = NCBrandColor.sharedInstance.brandText
        
        titleLabel.text = NSLocalizedString("_appconfig_view_title_", comment: "")
        
        if let serverConfig = UserDefaults.standard.dictionary(forKey: NCBrandConfiguration.sharedInstance.configuration_bundleId) {
            serverUrl = serverConfig[NCBrandConfiguration.sharedInstance.configuration_serverUrl] as? String
            username = serverConfig[NCBrandConfiguration.sharedInstance.configuration_username] as? String
            password = serverConfig[NCBrandConfiguration.sharedInstance.configuration_password] as? String
        } else {
            serverUrl = UserDefaults.standard.string(forKey: NCBrandConfiguration.sharedInstance.configuration_serverUrl)
            username = UserDefaults.standard.string(forKey: NCBrandConfiguration.sharedInstance.configuration_username)
            password = UserDefaults.standard.string(forKey: NCBrandConfiguration.sharedInstance.configuration_password)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Stop timer error network
        appDelegate.timerErrorNetworking.invalidate()
        
        guard let serverUrl = self.serverUrl else {
            NCContentPresenter.shared.messageNotification("_error_", description: "User Default, serverUrl not found", delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: 0)
            return
        }
        guard let username = self.username else {
            NCContentPresenter.shared.messageNotification("_error_", description: "User Default, username not found", delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: 0)
            return
        }
        guard let password = self.password else {
            NCContentPresenter.shared.messageNotification("_error_", description: "User Default, password not found", delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: 0)
            return
        }
        
        OCNetworking.sharedManager()?.getAppPassword(serverUrl, username: username, password: password, completion: { (token, message, errorCode) in
            DispatchQueue.main.async {
                if errorCode == 0 {
                    let account: String = "\(username) \(serverUrl)"
                    
                    // NO account found, clear
                    if NCManageDatabase.sharedInstance.getAccounts() == nil { NCUtility.sharedInstance.removeAllSettings() }
                    
                    // Add new account
                    NCManageDatabase.sharedInstance.deleteAccount(account)
                    NCManageDatabase.sharedInstance.addAccount(account, url: serverUrl, user: username, password: token!)
                    
                    guard let tableAccount = NCManageDatabase.sharedInstance.setAccountActive(account) else {
                        NCContentPresenter.shared.messageNotification("_error_", description: "setAccountActive error", delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: 0)
                        self.dismiss(animated: true, completion: nil)
                        return
                    }
                    
                    self.appDelegate.settingActiveAccount(account, activeUrl: serverUrl, activeUser: username, activeUserID: tableAccount.userID, activePassword: token!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "initializeMain"), object: nil, userInfo: nil)
                    
                    self.dismiss(animated: true) {}
                } else {
                    NCContentPresenter.shared.messageNotification("_error_", description: message, delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: errorCode)
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Start timer error network
        appDelegate.startTimerErrorNetworking()
    }
}
