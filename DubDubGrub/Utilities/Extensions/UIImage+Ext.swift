//
//  UIImage+Ext.swift
//  DubDubGrub
//
//  Created by Noé Duran on 1/3/22.
//

import CloudKit
import UIKit

extension UIImage {
    func convertToCKAsset() -> CKAsset? {
        //Get our app's base document directory url
        guard let urlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Document Directory url came back nil")
            return nil
        }
    
        //Append custom identifier to url
        let fileURL = urlPath.appendingPathComponent("selectedAvatarImage")
        
        //Write image data to location address points to
        guard let imageData = jpegData(compressionQuality: 0.25) else {
            return nil
        }
        
        //Create CKAsset with that fileURL
        do {
            //Write data to address
            try imageData.write(to: fileURL)
            return CKAsset(fileURL: fileURL)
        } catch {
            return nil
        }
    }
}
