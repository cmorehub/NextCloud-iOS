//
//  FileProviderExtension+NetworkingDelegate.swift
//  File Provider Extension
//
//  Created by Marino Faggiana on 02/11/2019.
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

import FileProvider
import NCCommunication

extension FileProviderExtension: NCNetworkingDelegate {

    func uploadComplete(fileName: String, serverUrl: String, ocId: String?, etag: String?, date: NSDate?, size: Int64, description: String?, error: Error?, statusCode: Int) {
                
        guard let ocIdTemp = description else { return }
        guard let metadata = NCManageDatabase.sharedInstance.getMetadata(predicate: NSPredicate(format: "ocId == %@", ocIdTemp)) else { return }
        
        let url = URL(fileURLWithPath: CCUtility.getDirectoryProviderStorageOcId(ocIdTemp, fileNameView: fileName))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.outstandingSessionTasks.removeValue(forKey: url)
        }
        outstandingOcIdTemp[ocIdTemp] = ocId
        
        if error == nil && statusCode >= 200 && statusCode < 300 {
            
            guard let parentItemIdentifier = fileProviderUtility.sharedInstance.getParentItemIdentifier(metadata: metadata, homeServerUrl: fileProviderData.sharedInstance.homeServerUrl) else {
                return
            }
            var item = FileProviderItem(metadata: metadata, parentItemIdentifier: parentItemIdentifier)
            
            // New file
            if ocId != ocIdTemp {
                
                fileProviderData.sharedInstance.fileProviderSignalDeleteContainerItemIdentifier[item.itemIdentifier] = item.itemIdentifier
                fileProviderData.sharedInstance.fileProviderSignalDeleteWorkingSetItemIdentifier[item.itemIdentifier] = item.itemIdentifier
                fileProviderData.sharedInstance.signalEnumerator(for: [parentItemIdentifier, .workingSet])
            }
            
            metadata.fileName = fileName
            metadata.serverUrl = serverUrl
            if let etag = etag { metadata.etag = etag }
            if let ocId = ocId { metadata.ocId = ocId }
            if let date = date { metadata.date = date }
            metadata.session = ""
            metadata.size = Double(size)
            metadata.status = Int(k_metadataStatusNormal)
                  
            guard let metadataUpdated = NCManageDatabase.sharedInstance.addMetadata(metadata) else { return }
            _ = NCManageDatabase.sharedInstance.addLocalFile(metadata: metadataUpdated)
            
            // New file
            if ocId != ocIdTemp {
            
                NCManageDatabase.sharedInstance.deleteMetadata(predicate: NSPredicate(format: "ocId == %@", ocIdTemp))
                
                // File system
                let atPath = CCUtility.getDirectoryProviderStorageOcId(ocIdTemp)
                let toPath = CCUtility.getDirectoryProviderStorageOcId(ocId)
                CCUtility.copyFile(atPath: atPath, toPath: toPath)
            }
            
            // Signal update
            item = FileProviderItem(metadata: metadataUpdated, parentItemIdentifier: parentItemIdentifier)
            fileProviderData.sharedInstance.fileProviderSignalUpdateContainerItem[item.itemIdentifier] = item
            fileProviderData.sharedInstance.fileProviderSignalUpdateWorkingSetItem[item.itemIdentifier] = item
            fileProviderData.sharedInstance.signalEnumerator(for: [parentItemIdentifier, .workingSet])
            
        } else {
           
            // Error
            NCManageDatabase.sharedInstance.setMetadataSession("", sessionError: "", sessionSelector: "", sessionTaskIdentifier: 0, status: Int(k_metadataStatusUploadError), predicate: NSPredicate(format: "ocId == %@", ocIdTemp))
        }
    }
}
