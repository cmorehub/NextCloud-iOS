//
//  NCCreateFormUploadDocuments.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 14/11/18.
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

import Foundation
import NCCommunication

// MARK: -

class NCCreateFormUploadDocuments: XLFormViewController, NCSelectDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var editorId = ""
    var creatorId = ""
    var typeTemplate = ""
    var serverUrl = ""
    var fileNameFolder = ""
    var fileName = ""
    var fileNameExtension = ""
    var titleForm = ""
    var listOfTemplate = [NCEditorTemplates]()
    var selectTemplate: NCEditorTemplates?
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeigth: NSLayoutConstraint!
    
    // Layout
    let numItems = 2
    let sectionInsets: CGFloat = 10
    let highLabelName: CGFloat = 20
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if serverUrl == CCUtility.getHomeServerUrlActiveUrl(appDelegate.activeUrl) {
            fileNameFolder = "/"
        } else {
            fileNameFolder = (serverUrl as NSString).lastPathComponent
        }
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
                
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("_cancel_", comment: ""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancel))
        let saveButton : UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("_save_", comment: ""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(save))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // title 
        self.title = titleForm
      
        // Theming view
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeTheming), name: NSNotification.Name(rawValue: "changeTheming"), object: nil)
        changeTheming()
        
        // load the templates available
        getTemplate()
    }
    
    @objc func changeTheming() {
        appDelegate.changeTheming(self, tableView: tableView, collectionView: collectionView, form: false)
        initializeForm()
    }
    
    // MARK: - Tableview (XLForm)

    func initializeForm() {
        
        let form : XLFormDescriptor = XLFormDescriptor(title: NSLocalizedString("_upload_photos_videos_", comment: "")) as XLFormDescriptor
        form.rowNavigationOptions = XLFormRowNavigationOptions.stopDisableRow
        
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        // Section: Destination Folder
        
        section = XLFormSectionDescriptor.formSection(withTitle: NSLocalizedString("_save_path_", comment: "").uppercased())
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: "ButtonDestinationFolder", rowType: XLFormRowDescriptorTypeButton, title: fileNameFolder)
        row.action.formSelector = #selector(changeDestinationFolder(_:))
        row.value = fileNameFolder
        row.cellConfig["backgroundColor"] = NCBrandColor.sharedInstance.backgroundForm

        row.cellConfig["imageView.image"] = CCGraphics.changeThemingColorImage(UIImage(named: "folder")!, width: 50, height: 50, color: NCBrandColor.sharedInstance.brandElement) as UIImage
        
        row.cellConfig["textLabel.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textLabel.textColor"] = NCBrandColor.sharedInstance.textView

        section.addFormRow(row)
        
        // Section: File Name
        
        section = XLFormSectionDescriptor.formSection(withTitle: NSLocalizedString("_filename_", comment: "").uppercased())
        form.addFormSection(section)
        
        row = XLFormRowDescriptor(tag: "fileName", rowType: XLFormRowDescriptorTypeAccount, title: NSLocalizedString("_filename_", comment: ""))
        row.value = fileName
        row.cellConfig["backgroundColor"] = NCBrandColor.sharedInstance.backgroundForm
        
        row.cellConfig["textField.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["textField.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textField.textColor"] = NCBrandColor.sharedInstance.textView
        
        row.cellConfig["textLabel.textAlignment"] = NSTextAlignment.right.rawValue
        row.cellConfig["textLabel.font"] = UIFont.systemFont(ofSize: 15.0)
        row.cellConfig["textLabel.textColor"] = NCBrandColor.sharedInstance.textView
        
        section.addFormRow(row)
        
        self.form = form
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 13.0)
        header.textLabel?.textColor = .gray
        header.tintColor = NCBrandColor.sharedInstance.backgroundForm
    }

    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfTemplate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemWidth: CGFloat = (collectionView.frame.width - (sectionInsets * 4) - CGFloat(numItems)) / CGFloat(numItems)
        let itemHeight: CGFloat = itemWidth + highLabelName
        
        collectionViewHeigth.constant = itemHeight + sectionInsets
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let template = listOfTemplate[indexPath.row]
        
        // image
        let imagePreview = cell.viewWithTag(100) as! UIImageView
        if template.preview != "" {
            let fileNameLocalPath = CCUtility.getDirectoryUserData() + "/" + template.name + ".png"
            if FileManager.default.fileExists(atPath: fileNameLocalPath) {
                let imageURL = URL(fileURLWithPath: fileNameLocalPath)
                if let image = UIImage(contentsOfFile: imageURL.path) {
                    imagePreview.image = image
                }
            } else {
                getImageFromTemplate(name: template.name, preview: template.preview, indexPath: indexPath)
            }
        }
        
        // name
        let name = cell.viewWithTag(200) as! UILabel
        name.text = template.name
        name.textColor = NCBrandColor.sharedInstance.backgroundView
        
        // select
        let imageSelect = cell.viewWithTag(300) as! UIImageView
        if selectTemplate != nil && selectTemplate?.name == template.name {
            cell.backgroundColor = NCBrandColor.sharedInstance.textView
            imageSelect.image = UIImage(named: "plus100")
            imageSelect.isHidden = false
        } else {
            cell.backgroundColor = NCBrandColor.sharedInstance.backgroundView
            imageSelect.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let template = listOfTemplate[indexPath.row]
        
        selectTemplate = template
        fileNameExtension = template.ext
        
        collectionView.reloadData()
    }
    
    // MARK: - Action
    
    func dismissSelect(serverUrl: String?, metadata: tableMetadata?, type: String) {
        
        guard let serverUrl = serverUrl else {
            return
        }
        
        self.serverUrl = serverUrl
        if serverUrl == CCUtility.getHomeServerUrlActiveUrl(appDelegate.activeUrl) {
            fileNameFolder = "/"
        } else {
            fileNameFolder = (serverUrl as NSString).lastPathComponent
        }
        
        let buttonDestinationFolder : XLFormRowDescriptor  = self.form.formRow(withTag: "ButtonDestinationFolder")!
        buttonDestinationFolder.title = fileNameFolder
        
        self.tableView.reloadData()
    }
    
    @objc func changeDestinationFolder(_ sender: XLFormRowDescriptor) {
        
        self.deselectFormRow(sender)
        
        let storyboard = UIStoryboard(name: "NCSelect", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let viewController = navigationController.topViewController as! NCSelect
        
        viewController.delegate = self
        viewController.hideButtonCreateFolder = false
        viewController.includeDirectoryE2EEncryption = false
        viewController.includeImages = false
        viewController.layoutViewSelect = k_layout_view_move
        viewController.selectFile = false
        viewController.titleButtonDone = NSLocalizedString("_select_", comment: "")
        viewController.type = ""

        navigationController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func save() {
        
        guard let selectTemplate = self.selectTemplate else {
            return
        }
        let rowFileName : XLFormRowDescriptor  = self.form.formRow(withTag: "fileName")!
        guard let fileNameForm = rowFileName.value else {
            return
        }
        if fileNameForm as! String == "" {
            return
        } else {
            
            fileName = (fileNameForm as! NSString).deletingPathExtension + "." + fileNameExtension
            fileName = CCUtility.returnFileNamePath(fromFileName: fileName, serverUrl: serverUrl, activeUrl: appDelegate.activeUrl)
        }
            
        if self.editorId == k_editor_text || self.editorId == k_editor_onlyoffice {
             
            var customUserAgent: String?
            
            if self.editorId == k_editor_onlyoffice {
                customUserAgent = NCUtility.sharedInstance.getCustomUserAgentOnlyOffice()
            }
            
            NCCommunication.sharedInstance.NCTextCreateFile(urlString: appDelegate.activeUrl, fileNamePath: fileName, editorId: editorId, creatorId: creatorId, templateId: selectTemplate.identifier, customUserAgent: customUserAgent, account: self.appDelegate.activeAccount) { (account, url, errorCode, errorMessage) in
                
                if errorCode == 0 && account == self.appDelegate.activeAccount {
                    
                    if url != nil && url!.count > 0 {
                        
                        var contentType = "text/markdown"
                        if let directEditingCreators = NCManageDatabase.sharedInstance.getDirectEditingCreators(account: self.appDelegate.activeAccount) {
                            for directEditingCreator in directEditingCreators {
                                if directEditingCreator.ext == self.fileNameExtension {
                                    contentType = directEditingCreator.mimetype
                                }
                            }
                        }
                        
                        self.dismiss(animated: true, completion: {
                            let metadata = CCUtility.createMetadata(withAccount: self.appDelegate.activeAccount, date: Date(), directory: false, ocId: CCUtility.createRandomString(12), serverUrl: self.serverUrl, fileName: (fileNameForm as! NSString).deletingPathExtension + "." + self.fileNameExtension, etag: "", size: 0, status: Double(k_metadataStatusNormal), url:url, contentType: contentType)
                            
                            self.appDelegate.activeMain.shouldPerformSegue(metadata, selector: "")
                        })
                    }
                    
                } else if errorCode != 0 {
                    NCContentPresenter.shared.messageNotification("_error_", description: errorMessage, delay: TimeInterval(k_dismissAfterSecond), type:NCContentPresenter.messageType.error, errorCode: errorCode)
                } else {
                   print("[LOG] It has been changed user during networking process, error.")
                }
            }
            
        }
        
        if self.editorId == k_editor_collabora {
            
            OCNetworking.sharedManager().createNewRichdocuments(withAccount: appDelegate.activeAccount, fileName: fileName, serverUrl: serverUrl, templateID: selectTemplate.identifier, completion: { (account, url, message, errorCode) in
                       
                if errorCode == 0 && account == self.appDelegate.activeAccount {
                   
                   if url != nil && url!.count > 0 {
                       
                       self.dismiss(animated: true, completion: {
                           let metadata = CCUtility.createMetadata(withAccount: self.appDelegate.activeAccount, date: Date(), directory: false, ocId: CCUtility.createRandomString(12), serverUrl: self.serverUrl, fileName: (fileNameForm as! NSString).deletingPathExtension + "." + self.fileNameExtension, etag: "", size: 0, status: Double(k_metadataStatusNormal), url:url, contentType: "")
                           
                           self.appDelegate.activeMain.shouldPerformSegue(metadata, selector: "")
                       })
                   }
                    
                } else if errorCode != 0 {
                    NCContentPresenter.shared.messageNotification("_error_", description: message, delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: errorCode)
                } else {
                   print("[LOG] It has been changed user during networking process, error.")
                }
            })
        }
    }
    
    @objc func cancel() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: NC API
    
    func getTemplate() {
     
        indicator.color = NCBrandColor.sharedInstance.brand
        indicator.startAnimating()
        
        if self.editorId == k_editor_text || self.editorId == k_editor_onlyoffice {
            
            fileNameExtension = "md"            
            var customUserAgent: String?
                       
            if self.editorId == k_editor_onlyoffice {
                customUserAgent = NCUtility.sharedInstance.getCustomUserAgentOnlyOffice()
            }
            
            NCCommunication.sharedInstance.NCTextGetListOfTemplates(urlString: appDelegate.activeUrl, customUserAgent: customUserAgent, account: appDelegate.activeAccount) { (account, templates, errorCode, errorMessage) in
                
                self.indicator.stopAnimating()
                
                if errorCode == 0 && account == self.appDelegate.activeAccount {
                    
                    for template in templates {
                        
                        let temp = NCEditorTemplates()
                                               
                        temp.identifier = template.identifier
                        temp.ext = template.ext
                        temp.name = template.name
                        temp.preview = template.preview
                                               
                        self.listOfTemplate.append(temp)
                                               
                        // default: template empty
                        if temp.preview == "" {
                            self.selectTemplate = temp
                            self.fileNameExtension = template.ext
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                        }
                    }
                    
                    // NOT ALIGNED getTemplatesRichdocuments
                    if templates.count == 0 {
                        let temp = NCEditorTemplates()
                        
                        temp.identifier = ""
                        if self.editorId == k_editor_text {
                            temp.ext = "md"
                        } else if self.editorId == k_editor_onlyoffice && self.typeTemplate == k_template_document {
                            temp.ext = "docx"
                        } else if self.editorId == k_editor_onlyoffice && self.typeTemplate == k_template_spreadsheet {
                            temp.ext = "xlsx"
                        } else if self.editorId == k_editor_onlyoffice && self.typeTemplate == k_template_presentation {
                            temp.ext = "pptx"
                        }
                        temp.name = "Empty"
                        temp.preview = ""
                                                                      
                        self.listOfTemplate.append(temp)
                        
                        self.selectTemplate = temp
                        self.fileNameExtension = temp.ext
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                    
                    self.collectionView.reloadData()
                                        
                } else if errorCode != 0 {
                    NCContentPresenter.shared.messageNotification("_error_", description: errorMessage, delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: errorCode)
                } else {
                    print("[LOG] It has been changed user during networking process, error.")
                }
            }
            
        }
        
        if self.editorId == k_editor_collabora  {
                        
            OCNetworking.sharedManager().getTemplatesRichdocuments(withAccount: appDelegate.activeAccount, typeTemplate: typeTemplate, completion: { (account, templates, message, errorCode) in
                
                self.indicator.stopAnimating()

                if errorCode == 0 && account == self.appDelegate.activeAccount {
                    
                    for template in templates as! [NCRichDocumentTemplate] {
                        
                        let temp = NCEditorTemplates()
                        temp.identifier = "\(template.templateID)"
                        temp.delete = template.delete
                        temp.ext = template.extension
                        temp.name = template.name
                        temp.preview = template.preview
                        temp.type = template.type
                        
                        self.listOfTemplate.append(temp)
                        
                        // default: template empty
                        if temp.preview == "" {
                            self.selectTemplate = temp
                            self.fileNameExtension = temp.ext
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                        }
                    }
                    
                    self.collectionView.reloadData()
                    
                } else if errorCode != 0 {
                    NCContentPresenter.shared.messageNotification("_error_", description: message, delay: TimeInterval(k_dismissAfterSecond), type: NCContentPresenter.messageType.error, errorCode: errorCode)
                } else {
                    print("[LOG] It has been changed user during networking process, error.")
                }
            })
        }
    }
    
    func getImageFromTemplate(name: String, preview: String, indexPath: IndexPath) {
        
        let fileNameLocalPath = CCUtility.getDirectoryUserData() + "/" + name + ".png"

        OCNetworking.sharedManager().download(withAccount: appDelegate.activeAccount, url: preview, fileNameLocalPath: fileNameLocalPath, encode:true, completion: { (account, message, errorCode) in
            
            if errorCode == 0 && account == self.appDelegate.activeAccount {
                self.collectionView.reloadItems(at: [indexPath])
            } else if errorCode != 0 {
                print("\(errorCode)")
            } else {
                print("[LOG] It has been changed user during networking process, error.")
            }
        })
    }
}
