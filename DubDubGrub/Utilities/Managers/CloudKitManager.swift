//
//  CloudKitManager.swift
//  DubDubGrub
//
//  Created by Noé Duran on 12/29/21.
//

import CloudKit

struct CloudKitManager {
    static func getLocations(completed: @escaping(Result<[DDGLocation], Error>) -> Void){
        //Sort by name, name is SORTABLE in CloudKit
        let sortDescriptor = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
        //Predicate set true to get every DDGLocation
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        //Network Call
        //Returns optional records or optional error
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            
            guard let records = records else { return }
            
            let locations = records.map{$0.convertToDDGLocation()}
//            var locations: [DDGLocation] = []
//
//            for record in records {
//                let location = DDGLocation(record: record)
//                locations.append(location)
//            }
            
            completed(.success(locations))
        }
    }
}
