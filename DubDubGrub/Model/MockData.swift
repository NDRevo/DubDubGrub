//
//  MockData.swift
//  DubDubGrub
//
//  Created by Noe Duran on 7/2/21.
//

import CloudKit

struct MockData {
    static var location: CKRecord {
        let record = CKRecord(recordType: RecordType.location)
        record[DDGLocation.kName]           = "Noe's Bar and Grill"
        record[DDGLocation.kAddress]        = "123 Main Street"
        record[DDGLocation.kDescription]    = "This is a really good place to eat some good food, i hope you come and enjoy the food here"
        record[DDGLocation.kWebsiteURL]     = "https://apple.com"
        record[DDGLocation.kLocation]       = CLLocation(latitude: 37.331516, longitude: -121.891054)
        record[DDGLocation.kPhoneNumber]    = "732-841-4761"
        
        
        return record
    }
    
    static var chipotle: CKRecord {
        let record                          = CKRecord(recordType: RecordType.location,
                                                       recordID: CKRecord.ID(recordName: "54ED5F40-5801-D924-3DC8-CBE329CFBEEE"))
        record[DDGLocation.kName]           = "Chipotle"
        record[DDGLocation.kAddress]        = "1 S Market St Ste 40"
        record[DDGLocation.kDescription]    = "Our local San Jose One South Market Chipotle Mexican Grill is cultivating a better world by serving responsibly sourced, classically-cooked, real food."
        record[DDGLocation.kWebsiteURL]     = "https://locations.chipotle.com/ca/san-jose/1-s-market-st"
        record[DDGLocation.kLocation]       = CLLocation(latitude: 37.334967, longitude: -121.892566)
        record[DDGLocation.kPhoneNumber]    = "408-938-0919"
        
        return record
    }
    
    static var profile: CKRecord {
        let profile = CKRecord(recordType: RecordType.profile)
        profile[DDGProfile.kFirstName]      = "Noe"
        profile[DDGProfile.kLastName]       = "Duran"
        profile[DDGProfile.kCompanyName]    = "MechSpaceCo"
        profile[DDGProfile.kBio]            = "This is my bio! I build keyboards!"
    
        return profile
    }
}
