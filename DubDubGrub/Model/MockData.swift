//
//  MockData.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/2/21.
//

import CloudKit

struct MockData {
    static var location: CKRecord {
        let record = CKRecord(recordType: "DDGLocation")
        record[DDGLocation.kName]           = "Noe's Bar and Grill"
        record[DDGLocation.kAddress]        = "123 Main Street"
        record[DDGLocation.kDescription]    = "This is a really good place to eat some good food, i hope you come and enjoy the food here"
        record[DDGLocation.kWebsiteURL]     = "https://apple.com"
        record[DDGLocation.kLocation]       = CLLocation(latitude: 37.331516, longitude: -121.891054)
        record[DDGLocation.kPhoneNumber]    = "732-841-4761"
        
        
        return record
    }
}
