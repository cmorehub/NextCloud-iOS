//
//  CCMore.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 03/04/17.
//  Copyright © 2017 Marino Faggiana. All rights reserved.
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


import UIKit

class CCMore: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var themingBackground: UIImageView!
    @IBOutlet weak var disclosureIndicator: UIImageView!
    @IBOutlet weak var themingAvatar: UIImageView!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelQuota: UILabel!
    @IBOutlet weak var labelQuotaExternalSite: UILabel!
    @IBOutlet weak var progressQuota: UIProgressView!
    @IBOutlet weak var viewQuota: UIView!

    var functionMenu = [OCExternalSites]()
    var externalSiteMenu = [OCExternalSites]()
    var settingsMenu = [OCExternalSites]()
    var quotaMenu = [OCExternalSites]()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var listExternalSite: [tableExternalSites]?
    var tabAccount : tableAccount?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        appDelegate.activeMore = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = NSLocalizedString("_more_", comment: "")
        
        // create tap gesture recognizer
        let tapQuota = UITapGestureRecognizer(target: self, action: #selector(tapLabelQuotaExternalSite))
        labelQuotaExternalSite.isUserInteractionEnabled = true
        labelQuotaExternalSite.addGestureRecognizer(tapQuota)
        
        let tapImageLogo = UITapGestureRecognizer(target: self, action: #selector(tapImageLogoManageAccount))
        themingBackground.isUserInteractionEnabled = true
        themingBackground.addGestureRecognizer(tapImageLogo)
        
        // Notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeUserProfile), name: NSNotification.Name(rawValue: "changeUserProfile"), object: nil)
        
        // Theming view
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeTheming), name: NSNotification.Name(rawValue: "changeTheming"), object: nil)
        changeTheming()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Clear
        functionMenu.removeAll()
        externalSiteMenu.removeAll()
        settingsMenu.removeAll()
        quotaMenu.removeAll()
        labelQuotaExternalSite.text = ""
        
        var item = OCExternalSites.init()

        // ITEM : Transfer
        item = OCExternalSites.init()
        item.name = "_transfers_"
        item.icon = "load"
        item.url = "segueTransfers"
        functionMenu.append(item)
        
        // ITEM : Activity
        item = OCExternalSites.init()
        item.name = "_activity_"
        item.icon = "activity"
        item.url = "segueActivity"
        functionMenu.append(item)
        
        // ITEM : Shares
        item = OCExternalSites.init()
        item.name = "_list_shares_"
        item.icon = "share"
        item.url = "segueShares"
        functionMenu.append(item)

        // ITEM : Offline
        item = OCExternalSites.init()
        item.name = "_manage_file_offline_"
        item.icon = "offline"
        item.url = "segueOffline"
        functionMenu.append(item)
        
        // ITEM : Scan
        if #available(iOS 11.0, *) {
            item = OCExternalSites.init()
            item.name = "_scanned_images_"
            item.icon = "scan"
            item.url = "openStoryboardScan"
            functionMenu.append(item)
        }
        
        // ITEM : Trash
        let capabilities = NCManageDatabase.sharedInstance.getCapabilites(account: appDelegate.activeAccount)
        if capabilities != nil && capabilities!.versionMajor >= Int(k_trash_version_available) {
            
            item = OCExternalSites.init()
            item.name = "_trash_view_"
            item.icon = "trash"
            item.url = "segueTrash"
            functionMenu.append(item)
        }
        
        // ITEM : External
        if NCBrandOptions.sharedInstance.disable_more_external_site == false {
        
            listExternalSite = NCManageDatabase.sharedInstance.getAllExternalSites(account: appDelegate.activeAccount)
            
            if listExternalSite != nil {
                
                for table in listExternalSite! {
            
                    item = OCExternalSites.init()
            
                    item.name = table.name
                    item.url = table.url
                    item.icon = table.icon
            
                    if (table.type == "link") {
                        item.icon = "world"
                        externalSiteMenu.append(item)
                    }
                    if (table.type == "settings") {
                        item.icon = "settings"
                        settingsMenu.append(item)
                    }
                    if (table.type == "quota") {
                        quotaMenu.append(item)
                    }
                }
            }
        }
        
        // ITEM : Settings
        item = OCExternalSites.init()
        item.name = "_settings_"
        item.icon = "settings"
        item.url = "segueSettings"
        settingsMenu.append(item)
        
        if (quotaMenu.count > 0) {
            
            let item = quotaMenu[0]
            labelQuotaExternalSite.text = item.name
        }
        
        changeUserProfile()
        tableView.reloadData()
    }
    
    @objc func changeTheming() {
        
        appDelegate.changeTheming(self, tableView: tableView, collectionView: nil, form: false)

        self.view.backgroundColor = NCBrandColor.sharedInstance.brand
        viewQuota.backgroundColor = NCBrandColor.sharedInstance.backgroundView;
        progressQuota.progressTintColor = NCBrandColor.sharedInstance.brandElement
        themingBackground.backgroundColor = NCBrandColor.sharedInstance.backgroundView;
            
        labelUsername.textColor = NCBrandColor.sharedInstance.textView
        
        disclosureIndicator.image = CCGraphics.changeThemingColorImage(disclosureIndicator.image, width: 48, height: 52, color: NCBrandColor.sharedInstance.textView)
    }
    
    @objc func changeUserProfile() {
     
        let fileNamePath = CCUtility.getDirectoryUserData() + "/" + CCUtility.getStringUser(appDelegate.activeUser, activeUrl: appDelegate.activeUrl) + "-" + appDelegate.activeUser + ".png"
        var quota: String = ""
        
        if let themingAvatarFile = UIImage.init(contentsOfFile: fileNamePath) {
            themingAvatar.image = themingAvatarFile
        } else {
            themingAvatar.image = UIImage.init(named: "moreAvatar")
        }
        
        // Display Name user & Quota
        guard let tabAccount = NCManageDatabase.sharedInstance.getAccountActive() else {
            return
        }
        
        if tabAccount.displayName.isEmpty {
            labelUsername.text = tabAccount.user
        }
        else{
            labelUsername.text = tabAccount.displayName
        }
        
        // Shadow labelUsername TEST BLUR
        /*
        labelUsername.layer.shadowColor = UIColor.black.cgColor
        labelUsername.layer.shadowRadius = 4
        labelUsername.layer.shadowOpacity = 0.8
        labelUsername.layer.shadowOffset = CGSize(width: 0, height: 0)
        labelUsername.layer.masksToBounds = false
        */
        
        if (tabAccount.quotaRelative > 0) {
            progressQuota.progress = Float(tabAccount.quotaRelative) / 100
        } else {
            progressQuota.progress = 0
        }

        switch Double(tabAccount.quotaTotal) {
        case Double(k_quota_space_not_computed):
            quota = "0"
        case Double(k_quota_space_unknown):
            quota = NSLocalizedString("_quota_space_unknown_", comment: "")
        case Double(k_quota_space_unlimited):
            quota = NSLocalizedString("_quota_space_unlimited_", comment: "")
        default:
            quota = CCUtility.transformedSize(Double(tabAccount.quotaTotal))
        }
        
        let quotaUsed : String = CCUtility.transformedSize(Double(tabAccount.quotaUsed))
                
        labelQuota.text = String.localizedStringWithFormat(NSLocalizedString("_quota_using_", comment: ""), quotaUsed, quota)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if (externalSiteMenu.count == 0) {
            return 2
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0) {
            return 0.1
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var cont = 0
        
        // Menu Normal
        if (section == 0) {
            cont = functionMenu.count
        } else {
            switch (numberOfSections(in: tableView)) {
            case 2:
                // Menu Settings
                if (section == 1) {
                    cont = settingsMenu.count
                }
            case 3:
                // Menu External Site
                if (section == 1) {
                    cont = externalSiteMenu.count
                }
                // Menu Settings
                if (section == 2) {
                    cont = settingsMenu.count
                }
            default:
                cont = 0
            }
        }
        
        return cont
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CCCellMore
        var item: OCExternalSites = OCExternalSites.init()

        // change color selection and disclosure indicator
        let selectionColor : UIView = UIView.init()
        selectionColor.backgroundColor = NCBrandColor.sharedInstance.select
        cell.selectedBackgroundView = selectionColor
        cell.backgroundColor = NCBrandColor.sharedInstance.backgroundView;
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        // Menu Normal
        if (indexPath.section == 0) {
            
            item = functionMenu[indexPath.row]
            
        } else {
            
            // Menu External Site
            if (numberOfSections(in: tableView) == 3 && indexPath.section == 1) {
                
                item = externalSiteMenu[indexPath.row]
            }
            
            // Menu Settings
            if ((numberOfSections(in: tableView) == 2 && indexPath.section == 1) || (numberOfSections(in: tableView) == 3 && indexPath.section == 2)) {
                
                item = settingsMenu[indexPath.row]
            }
        }
        
        cell.imageIcon?.image = CCGraphics.changeThemingColorImage(UIImage.init(named: item.icon), width: 50, height: 50, color: NCBrandColor.sharedInstance.icon)
        cell.labelText?.text = NSLocalizedString(item.name, comment: "")
        cell.labelText.textColor = NCBrandColor.sharedInstance.textView
        
        return cell
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var item: OCExternalSites = OCExternalSites.init()
        
        // Menu Function
        if indexPath.section == 0 {
            item = functionMenu[indexPath.row]
        }
        
        // Menu External Site
        if (numberOfSections(in: tableView) == 3 && indexPath.section == 1) {
            item = externalSiteMenu[indexPath.row]
        }
        
        // Menu Settings
        if ((numberOfSections(in: tableView) == 2 && indexPath.section == 1) || (numberOfSections(in: tableView) == 3 && indexPath.section == 2)) {
            item = settingsMenu[indexPath.row]
        }
        
        // Action
        if item.url.contains("segue") && !item.url.contains("//") {
            
            self.navigationController?.performSegue(withIdentifier: item.url, sender: self)
        
        } else if item.url.contains("openStoryboard") && !item.url.contains("//") {
            
            let nameStoryboard =  item.url.replacingOccurrences(of: "openStoryboard", with: "")
            let storyboard = UIStoryboard(name: nameStoryboard, bundle: nil)
            let controller = storyboard.instantiateInitialViewController()! //instantiateViewController(withIdentifier: nameStoryboard)
            self.present(controller, animated: true, completion: nil)
            
        } else if item.url.contains("//") {
            
            if (self.splitViewController?.isCollapsed)! {
                
                let browserWebVC = UIStoryboard(name: "NCBrowserWeb", bundle: nil).instantiateInitialViewController() as! NCBrowserWeb
                browserWebVC.urlBase = item.url
                browserWebVC.isHiddenButtonExit = true
                
                self.navigationController?.pushViewController(browserWebVC, animated: true)
                self.navigationController?.navigationBar.isHidden = false
                
            } else {
                
                let browserWebVC = UIStoryboard(name: "NCBrowserWeb", bundle: nil).instantiateInitialViewController() as! NCBrowserWeb
                browserWebVC.urlBase = item.url

                self.present(browserWebVC, animated: true, completion: nil)
            }
            
        } else if item.url == "logout" {
            
            let alertController = UIAlertController(title: "", message: NSLocalizedString("_want_delete_", comment: ""), preferredStyle: .alert)
            
            let actionYes = UIAlertAction(title: NSLocalizedString("_yes_delete_", comment: ""), style: .default) { (action:UIAlertAction) in
                
                let manageAccount = CCManageAccount()
                manageAccount.delete(self.appDelegate.activeAccount)
                
                self.appDelegate.openLoginView(self, selector: Int(k_intro_login), openLoginWeb:false)
            }
            
            let actionNo = UIAlertAction(title: NSLocalizedString("_no_delete_", comment: ""), style: .default) { (action:UIAlertAction) in
                print("You've pressed No button");
            }
            
            alertController.addAction(actionYes)
            alertController.addAction(actionNo)
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    @objc func tapLabelQuotaExternalSite() {
        
        if (quotaMenu.count > 0) {
            
            let item = quotaMenu[0]
            
            if (self.splitViewController?.isCollapsed)! {
                
                let browserWebVC = UIStoryboard(name: "NCBrowserWeb", bundle: nil).instantiateInitialViewController() as! NCBrowserWeb
                browserWebVC.urlBase = item.url
                browserWebVC.isHiddenButtonExit = true
                
                self.navigationController?.pushViewController(browserWebVC, animated: true)
                self.navigationController?.navigationBar.isHidden = false
                
            } else {
                
                let browserWebVC = UIStoryboard(name: "NCBrowserWeb", bundle: nil).instantiateInitialViewController() as! NCBrowserWeb
                browserWebVC.urlBase = item.url
                
                self.present(browserWebVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func tapImageLogoManageAccount() {
        
        let controller = CCManageAccount.init()
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

class CCCellMore: UITableViewCell {
    
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var imageIcon: UIImageView!
}
