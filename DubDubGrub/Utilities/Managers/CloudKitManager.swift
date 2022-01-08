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

    //Retrieved on launch of app instead of saved locally because icloud account can be signed out, causing issues
    var userRecord: CKRecord?
    var profileRecordID: CKRecord.ID?

    //Makes it so it can't be initialized anywhere else
    private init(){}
    
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
    
    func getCheckedInProfiles(for locationID: CKRecord.ID, completed: @escaping (Result<[DDGProfile], Error>) -> Void ){
        let reference = CKRecord.Reference(recordID: locationID, action: .none)
        let predicate = NSPredicate(format: "isCheckedIn == %@", reference)
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil else {
                print(error!.localizedDescription)
                completed(.failure(error!))
                return
            }
            //Convert [CKRecord] to [DDGProfile]
            let profiles = records.map{$0.convertToDDGProfile()}
            completed(.success(profiles))
        }
    }
    
    func getCheckedInProfilesDictionary(completed: @escaping (Result<[CKRecord.ID: [DDGProfile]], Error>) -> Void) {
        //Means they are checked in somewhere
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        //Instead of using convenience api we can use this so we can choose which properties to get back, not good for future proofing if need be
        let operation = CKQueryOperation(query: query)
        //operation.desiredKeys = [DDGProfile.kIsCheckedIn, DDGProfile.kAvatar]
        
        var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]
        operation.recordFetchedBlock = { record in
            //Build dictionary
            let profile = DDGProfile(record: record)
            
            //Gets location record because isCheckedIn is reference to location
            guard let locationReference = profile.isCheckedIn else { return }
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
            
        }
        
        operation.queryCompletionBlock = { cursor, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            //Handle cursor in later video
            completed(.success(checkedInProfiles))
        }
        
        //Do operation similar to Task.resume()
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func getCheckedInProfilesCount(completed: @escaping (Result<[CKRecord.ID: Int], Error>) -> Void) {
        //Means they are checked in somewhere
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)

        //Instead of using convenience api we can use this so we can choose which properties to get back, not good for future proofing if need be
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = [DDGProfile.kIsCheckedIn]
        
        var checkedInProfiles: [CKRecord.ID : Int] = [:]
        operation.recordFetchedBlock = { record in

            //Gets location record because isCheckedIn is reference to location
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { return }
            if let count = checkedInProfiles[locationReference.recordID] {
                //Not nil
                checkedInProfiles[locationReference.recordID] = count + 1
            } else {
                //If nil
                checkedInProfiles[locationReference.recordID] = 1
            }
        }
        
        operation.queryCompletionBlock = { cursor, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            //Handle cursor in later video
            completed(.success(checkedInProfiles))
        }
        //Do operation similar to Task.resume()
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func batchSave(records: [CKRecord], completed: @escaping (Result<[CKRecord], Error>) -> Void){
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
