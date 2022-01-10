//
//  DDGLocation.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/2/21.
//

import CloudKit
import UIKit

struct DDGLocation:Identifiable {
    
    static let kName        = "name"
    static let kAddress     = "address"
    static let kPhoneNumber = "phoneNumber"
    static let kDescription = "description"
    static let kWebsiteURL  = "websiteURL"
    static let kLocation    = "location"
    static let kSquareAsset = "squareAsset"
    static let kBannerAsset = "bannerAsset"
    
    let id: CKRecord.ID
    
    let name: String
    let address: String
    let phoneNumber: String
    let description: String
    let websiteURL: String
    let location: CLLocation
    let squareAsset: CKAsset!
    let bannerAsset: CKAsset!
    
    
    init(record: CKRecord){
        id = record.recordID
        
        //Dont know what type you'll get back thus optional
        name        = record[DDGLocation.kName] as? String ?? "N/A"
        address     = record[DDGLocation.kAddress] as? String ?? "N/A"
        phoneNumber = record[DDGLocation.kPhoneNumber] as? String ?? "N/A"
        description = record[DDGLocation.kDescription] as? String ?? "N/A"
        websiteURL  = record[DDGLocation.kWebsiteURL] as? String ?? "N/A"
        location    = record[DDGLocation.kLocation] as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
        squareAsset = record[DDGLocation.kSquareAsset] as? CKAsset
        bannerAsset = record[DDGLocation.kBannerAsset] as? CKAsset
    }
    
    var squareImage: UIImage {
        guard let asset = squareAsset else {
            return PlaceholderImage.square
        }
        return asset.convertToUIImage(in: .square)
    }

    var bannerImage: UIImage {
        guard let asset = bannerAsset else {
            return PlaceholderImage.banner
        }
        return asset.convertToUIImage(in: .banner)
    }
}
