//
//  CloudKitManager.swift
//  DubDubGrub
//
//  Created by Noé Duran on 12/29/21.
//

import CloudKit

//Needs to be singleton instead of struct because we need to save user record
//Singleton is like global variable, but can be hard to debug
final class CloudKitManager {

    static let shared = CloudKitManager()

    //Makes it so it can't be initialized anywhere else
    private init(){}

    //Retrieved on launch of app instead of saved locally because icloud account can be signed out, causing issues
    var userRecord: CKRecord?
    var profileRecordID: CKRecord.ID?
    
    //Fired at launch,
    func getUserRecord(){
        //Get our UserRecord ID from Container
        CKContainer.default().fetchUserRecordID{ recordID, error in
            guard let recordID = recordID, error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            //Get User record from Public Database
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
                guard let userRecord = userRecord, error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                self.userRecord = userRecord
                
                //Set profileRecordID at launch
                if let profileReference = userRecord["userProfile"] as? CKRecord.Reference {
                    self.profileRecordID = profileReference.recordID
                }
            }
        }
    }

    func getLocations(completed: @escaping(Result<[DDGLocation], Error>) -> Void){
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
    
    func batchSave(records: [CKRecord], completed: @escaping (Result<[CKRecord], Error>) ->Void){
        
        //Create CKOPeration to save our User & Profile Records, batch save
        let operation = CKModifyRecordsOperation(recordsToSave: records)
        operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
            guard let savedRecords = savedRecords, error == nil else {
                completed(.failure(error!))
                return
            }
            completed(.success(savedRecords))
        }
        //Add to database
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func save(record: CKRecord, completed: @escaping (Result<CKRecord, Error>) -> Void){
        CKContainer.default().publicCloudDatabase.save(record) { record, error in
            guard let record = record, error == nil else {
                print(error!.localizedDescription)
                completed(.failure(error!))
                return
            }
            completed(.success(record))
        }
    }
    
    func fetchRecord(with id: CKRecord.ID, completed: @escaping(Result<CKRecord, Error>) -> Void) {
        //Fetch profile record
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: id) { record, error in
            guard let record = record, error == nil else {
                print(error!.localizedDescription)
                completed(.failure(error!))
                return
            }
            completed(.success(record))
        }
    }
}
