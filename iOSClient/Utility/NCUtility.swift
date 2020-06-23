//
//  NCUtility.swift
//  Nextcloud
//
//  Created by Marino Faggiana on 25/06/18.
//  Copyright © 2018 Marino Faggiana. All rights reserved.
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
import SVGKit
import KTVHTTPCache
import ZIPFoundation
import Sheeeeeeeeet
import NCCommunication
import CommonCrypto

class NCUtility: NSObject {
    @objc static let sharedInstance: NCUtility = {
        let instance = NCUtility()
        return instance
    }()
    
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    let cache = NSCache<NSString, UIImage>()
    struct bundleDirectoryType {
        var error: Bool = false
        var bundleDirectory: String = ""
        var immPath: String = ""
    }
    
    @objc func createFileName(_ fileName: String, serverUrl: String, account: String) -> String {
        
        var resultFileName = fileName
        var exitLoop = false
            
            while exitLoop == false {
                
                if NCManageDatabase.sharedInstance.getMetadata(predicate: NSPredicate(format: "fileNameView == %@ AND serverUrl == %@ AND account == %@", resultFileName, serverUrl, account)) != nil {
                    
                    var name = NSString(string: resultFileName).deletingPathExtension
                    let ext = NSString(string: resultFileName).pathExtension
                    let characters = Array(name)
                    
                    if characters.count < 2 {
                        if ext == "" {
                            resultFileName = name + " " + "1"
                        } else {
                            resultFileName = name + " " + "1" + "." + ext
                        }
                    } else {
                        let space = characters[characters.count-2]
                        let numChar = characters[characters.count-1]
                        var num = Int(String(numChar))
                        if (space == " " && num != nil) {
                            name = String(name.dropLast())
                            num = num! + 1
                            if ext == "" {
                                resultFileName = name + "\(num!)"
                            } else {
                                resultFileName = name + "\(num!)" + "." + ext
                            }
                        } else {
                            if ext == "" {
                                resultFileName = name + " " + "1"
                            } else {
                                resultFileName = name + " " + "1" + "." + ext
                            }
                        }
                    }
                    
                } else {
                    exitLoop = true
                }
        }
        
        return resultFileName
    }
    
    @objc func isEncryptedMetadata(_ metadata: tableMetadata) -> Bool {
        
        if metadata.fileName != metadata.fileNameView && metadata.fileName.count == 32 && metadata.fileName.contains(".") == false {
            return true
        }
        
        return false
    }
    
    @objc func getFileSize(asset: PHAsset) -> Int64 {
        
        let resources = PHAssetResource.assetResources(for: asset)
        
        if let resource = resources.first {
            if resource.responds(to: #selector(NSDictionary.fileSize)) {
                let unsignedInt64 = resource.value(forKey: "fileSize") as! CLong
                return Int64(bitPattern: UInt64(unsignedInt64))
            }
        }
        
        return 0
    }
    
    @objc func getScreenWidthForPreview() -> CGFloat {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width * 0.75
        
        return screenWidth
    }
    
    @objc func getScreenHeightForPreview() -> CGFloat {
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.height * 0.75
        
        return screenWidth
    }
    
    @objc func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: (CGRect(x: 0, y: 0, width: newWidth, height: newHeight)))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func cellBlurEffect(with frame: CGRect) -> UIView {
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.backgroundColor = NCBrandColor.sharedInstance.brand.withAlphaComponent(0.2)
        
        return blurEffectView
    }
    
    func setLayoutForView(key: String, layout: String, sort: String, ascending: Bool, groupBy: String, directoryOnTop: Bool) {
        
        let string =  layout + "|" + sort + "|" + "\(ascending)" + "|" + groupBy + "|" + "\(directoryOnTop)"
        
        UICKeyChainStore.setString(string, forKey: key, service: k_serviceShareKeyChain)
    }
    
    func getLayoutForView(key: String) -> (String, String, Bool, String, Bool) {
        
        guard let string = UICKeyChainStore.string(forKey: key, service: k_serviceShareKeyChain) else {
            return (k_layout_list, "fileName", true, "none", true)
        }

        let array = string.components(separatedBy: "|")
        if array.count == 5 {
            let sort = NSString(string: array[2])
            let directoryOnTop = NSString(string: array[4])

            return (array[0], array[1], sort.boolValue, array[3], directoryOnTop.boolValue)
        }
        
        return (k_layout_list, "fileName", true, "none", true)
    }
    
    
    func convertSVGtoPNGWriteToUserData(svgUrlString: String, fileName: String?, width: CGFloat?, rewrite: Bool, account: String, closure: @escaping (String?) -> ()) {
        
        var fileNamePNG = ""
        
        guard let svgUrlString = svgUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return closure(nil)
        }
        guard let iconURL = URL(string: svgUrlString) else {
            return closure(nil)
        }
        
        if fileName == nil {
            fileNamePNG = iconURL.deletingPathExtension().lastPathComponent + ".png"
        } else {
            fileNamePNG = fileName!
        }
        
        let imageNamePath = CCUtility.getDirectoryUserData() + "/" + fileNamePNG
        
        if !FileManager.default.fileExists(atPath: imageNamePath) || rewrite == true {
            
            NCCommunication.sharedInstance.downloadContent(urlString: iconURL.absoluteString, account: account) { (account, data, errorCode, errorMessage) in
               
                if errorCode == 0 && data != nil {
                
                    if let image = UIImage.init(data: data!) {
                        
                        var newImage: UIImage = image
                        
                        if width != nil {
                            
                            let ratio = image.size.height / image.size.width
                            let newSize = CGSize(width: width!, height: width! * ratio)
                            
                            let renderFormat = UIGraphicsImageRendererFormat.default()
                            renderFormat.opaque = false
                            let renderer = UIGraphicsImageRenderer(size: CGSize(width: newSize.width, height: newSize.height), format: renderFormat)
                            newImage = renderer.image {
                                (context) in
                                image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
                            }
                        }
                        
                        guard let pngImageData = newImage.pngData() else {
                            return closure(nil)
                        }
                        
                        CCUtility.write(pngImageData, fileNamePath: imageNamePath)
                        
                        return closure(imageNamePath)
                        
                    } else {
                        
                        guard let svgImage: SVGKImage = SVGKImage(data: data) else {
                            return closure(nil)
                        }
                            
                        if width != nil {
                            let scale = svgImage.size.height / svgImage.size.width
                            svgImage.size = CGSize(width: width!, height: width! * scale)
                        }
                            
                        guard let image: UIImage = svgImage.uiImage else {
                            return closure(nil)
                        }
                        guard let pngImageData = image.pngData() else {
                            return closure(nil)
                        }
                            
                        CCUtility.write(pngImageData, fileNamePath: imageNamePath)
                            
                        return closure(imageNamePath)
                    }
                } else {
                    return closure(nil)
                }
            }
            
        } else {
            return closure(imageNamePath)
        }
    }
    
    @objc func startActivityIndicator(view: UIView?, bottom: CGFloat) {
    
        guard let view = view else { return }
        
        activityIndicator.color = NCBrandColor.sharedInstance.brand
        activityIndicator.hidesWhenStopped = true
            
        view.addSubview(activityIndicator)
            
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        view.addConstraint(horizontalConstraint)
        
        var verticalConstant: CGFloat = 0
        if bottom > 0 {
            verticalConstant = (view.frame.size.height / 2) - bottom
        }
        
        let verticalConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: verticalConstant)
        view.addConstraint(verticalConstraint)

        activityIndicator.startAnimating()
    }
    
    @objc func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    @objc func isSimulatorOrTestFlight() -> Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path else {
            return false
        }
        return path.contains("CoreSimulator") || path.contains("sandboxReceipt")
    }
    
    @objc func isEditImage(_ fileName: NSString) -> String? {
        switch fileName.pathExtension.uppercased() {
        case "PNG":
            return "PNG";
        case "JPG":
            return "JPG";
        case "JPEG":
            return "JPG"
        default:
            return nil
        }
    }
    
    @objc func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00:00"
        }
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let min = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
        let hour = Int(seconds / 3600)
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    @objc func blink(cell: AnyObject?) {
        DispatchQueue.main.async {
            if let cell = cell as? UITableViewCell {
                cell.backgroundColor = NCBrandColor.sharedInstance.brand.withAlphaComponent(0.3)
                UIView.animate(withDuration: 2) {
                    cell.backgroundColor = .clear
                }
            } else if let cell = cell as? UICollectionViewCell {
                cell.backgroundColor = NCBrandColor.sharedInstance.brand.withAlphaComponent(0.3)
                UIView.animate(withDuration: 2) {
                    cell.backgroundColor = .clear
                }
            }
        }
    }
    
    @objc func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor) -> UIFont {
        
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = [NSAttributedString.Key: Any]()
        
        let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension
        
        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont
            
            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
            
            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        
        return UIFont(descriptor: fontDescriptor, size: bestFontSize)
    }
    
    @objc func isRichDocument(_ metadata: tableMetadata) -> Bool {
        
        guard let mimeType = CCUtility.getMimeType(metadata.fileNameView) else {
            return false
        }
        guard let richdocumentsMimetypes = NCManageDatabase.sharedInstance.getRichdocumentsMimetypes(account: metadata.account) else {
            return false
        }
        
        if richdocumentsMimetypes.count > 0 && mimeType.components(separatedBy: ".").count > 2 {
            
            let mimeTypeArray = mimeType.components(separatedBy: ".")
            let mimeType = mimeTypeArray[mimeTypeArray.count - 2] + "." + mimeTypeArray[mimeTypeArray.count - 1]
            
            for richdocumentMimetype: String in richdocumentsMimetypes {
                if richdocumentMimetype.contains(mimeType) {
                    return true
                }
            }
        }
        
        return false
    }
    
    @objc func isDirectEditing(_ metadata: tableMetadata) -> String? {
        
        if NCBrandBeta.shared.directEditing == false {
            return nil
        }
        
        guard let results = NCManageDatabase.sharedInstance.getDirectEditingEditors(account: metadata.account) else {
            return nil
        }
        
        for result: tableDirectEditingEditors in results {
            for mimetype in result.mimetypes {
                if mimetype == metadata.contentType {
                    return result.editor
                }
            }
            for mimetype in result.optionalMimetypes {
                if mimetype == metadata.contentType {
                    return result.editor
                }
            }
        }
        
        return nil
    }
    
    @objc func removeAllSettings() {
        
        URLCache.shared.memoryCapacity = 0
        URLCache.shared.diskCapacity = 0
        KTVHTTPCache.cacheDeleteAllCaches()
        
        NCManageDatabase.sharedInstance.clearDatabase(account: nil, removeAccount: true)
        
        CCUtility.emptyGroupDirectoryProviderStorage()
        CCUtility.emptyGroupLibraryDirectory()
        
        CCUtility.emptyDocumentsDirectory()
        CCUtility.emptyTemporaryDirectory()
        
        CCUtility.createDirectoryStandard()
        
        CCUtility.deleteAllChainStore()
    }
    
    @objc func createAvatar(fileNameSource: String, fileNameSourceAvatar: String) -> UIImage? {
        
        guard let imageSource = UIImage(contentsOfFile: fileNameSource) else { return nil }
        let size = Int(k_avatar_size)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        imageSource.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0)
        let avatarImageView = CCAvatar.init(image: image, borderColor: .lightGray, borderWidth: 0.5)
        //avatarImageView?.alpha = alpha
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        avatarImageView?.layer.render(in: context)
        guard let imageAvatar = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        guard let data = imageAvatar.pngData() else {
            return nil
        }
        do {
            try data.write(to: NSURL(fileURLWithPath: fileNameSourceAvatar) as URL, options: .atomic)
        } catch { }
        
        return imageAvatar
    }
    
    func loadImage(ocId: String, fileNameView: String, completion: @escaping (UIImage?) -> Void) {
        
        if let image = cache.object(forKey: ocId as NSString) {
            completion(image)
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            let loadedImage = UIImage(contentsOfFile: CCUtility.getDirectoryProviderStorageIconOcId(ocId, fileNameView: fileNameView))
            
            DispatchQueue.main.async {
                
                if let loadedImage = loadedImage {
                    self?.cache.setObject(loadedImage, forKey: ocId as NSString)
                }
                completion(loadedImage)
            }
        }
    }
    
    @objc func UIColorFromRGB(rgbValue: UInt32) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    @objc func RGBFromUIColor(uicolorValue: UIColor) -> UInt32 {
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0

        if uicolorValue.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {

            var colorAsUInt : UInt32 = 0

            colorAsUInt += UInt32(red * 255.0) << 16 +
                           UInt32(green * 255.0) << 8 +
                           UInt32(blue * 255.0)

            return colorAsUInt
        }
        
        return 0
    }
    
    @objc func IMUnzip(metadata: tableMetadata) -> Bool {
        
        // bak
        let atPathBak = CCUtility.getDirectoryProviderStorageOcId(metadata.ocId) + "/" + metadata.fileNameView
        let toPathBak = (CCUtility.getDirectoryProviderStorageOcId(metadata.ocId) + "/" + metadata.fileNameView as NSString).deletingPathExtension + ".bak"
        CCUtility.copyFile(atPath: atPathBak, toPath: toPathBak)
        
        let source = URL(fileURLWithPath: CCUtility.getDirectoryProviderStorageOcId(metadata.ocId, fileNameView: metadata.fileNameView))
        let destination = URL(fileURLWithPath: CCUtility.getDirectoryProviderStorageOcId(metadata.ocId))
        let removeAtPath = (CCUtility.getDirectoryProviderStorageOcId(metadata.ocId) + "/" + metadata.fileNameView as NSString).deletingPathExtension
        
        try? FileManager.default.removeItem(atPath: removeAtPath)
        try? FileManager().unzipItem(at: source, to: destination)
        
        let bundleDirectory = NCUtility.sharedInstance.IMGetBundleDirectory(metadata: metadata)
        if bundleDirectory.error {
            return false
        }
        
        if let fileHandle = FileHandle(forReadingAtPath: bundleDirectory.immPath) {
            //                        let dataFormat = fileHandle.readData(ofLength: 1)
            //                        if dataFormat.starts(with: [0x01]) {
            //                            appDelegate.messageNotification("_error_", description: "File format binary error, library imagemeter not present. 🤷‍♂️", visible: true, delay: TimeInterval(k_dismissAfterSecond), type: TWMessageBarMessageType.error, errorCode: errorCode)
            //                            return;
            //                        }
            let dataZip = fileHandle.readData(ofLength: 4)
            if dataZip.starts(with: [0x50, 0x4b, 0x03, 0x04]) {
                try? FileManager().unzipItem(at: NSURL(fileURLWithPath: bundleDirectory.immPath) as URL, to: NSURL(fileURLWithPath: bundleDirectory.bundleDirectory) as URL)
            }
            fileHandle.closeFile()
        }
        
        return true
    }
    
    func IMGetBundleDirectory(metadata: tableMetadata) -> bundleDirectoryType {
        
        var error = true
        var bundleDirectory = ""
        var immPath = ""
        
        let source = URL(fileURLWithPath: CCUtility.getDirectoryProviderStorageOcId(metadata.ocId, fileNameView: metadata.fileNameView))
        
        if let archive = Archive(url: source, accessMode: .read) {
            archive.forEach({ (entry) in
                let pathComponents = (entry.path as NSString).pathComponents
                if pathComponents.count == 2 && (pathComponents.last! as NSString).pathExtension.lowercased() == "imm" {
                    error = false
                    bundleDirectory = CCUtility.getDirectoryProviderStorageOcId(metadata.ocId) + "/" + pathComponents.first!
                    immPath = CCUtility.getDirectoryProviderStorageOcId(metadata.ocId) + "/" + entry.path
                }
            })
        }
        
        return bundleDirectoryType(error: error, bundleDirectory: bundleDirectory, immPath: immPath)
    }
    
    func IMIsChange(metadata: tableMetadata, fileNameZipUrl: URL) -> Bool {
        
        let backFile = (CCUtility.getDirectoryProviderStorageOcId(metadata.ocId) + "/" + metadata.fileNameView as NSString).deletingPathExtension + ".bak"
        
        if let md5imiFile = self.md5File(url: fileNameZipUrl) {
            if let md5backfile = self.md5File(url: URL(fileURLWithPath: backFile)) {
                if md5imiFile == md5backfile {
                    return false
                } else {
                    return true
                }
            }
        }
        
        return true
    }
    
    @objc func permissionsContainsString(_ metadataPermissions: String, permissions: String) -> Bool {
        
        for char in permissions {
            if metadataPermissions.contains(char) == false {
                return false
            }
        }
        return true
    }
    
    @objc func getCustomUserAgentOnlyOffice() -> String {
        
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "Mozilla/5.0 (iPad) Nextcloud-iOS/\(appVersion)"
        }else{
            return "Mozilla/5.0 (iPhone) Mobile Nextcloud-iOS/\(appVersion)"
        }
    }
    
    func md5File(url: URL) -> Data? {

        let bufferSize = 1024 * 1024

        do {
            // Open file for reading:
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }

            // Create and initialize MD5 context:
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)

            // Read up to `bufferSize` bytes, until EOF is reached, and update MD5 context:
            while autoreleasepool(invoking: {
                let data = file.readData(ofLength: bufferSize)
                if data.count > 0 {
                    data.withUnsafeBytes {
                        _ = CC_MD5_Update(&context, $0.baseAddress, numericCast(data.count))
                    }
                    return true // Continue
                } else {
                    return false // End of file
                }
            }) { }

            // Compute the MD5 digest:
            var digest: [UInt8] = Array(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            _ = CC_MD5_Final(&digest, &context)

            return Data(digest)

        } catch {
            print("Cannot open file:", error.localizedDescription)
            return nil
        }
    }
}

