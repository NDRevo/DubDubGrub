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
    let container = CKContainer.default()

    //Makes it so it can't be initialized anywhere else
    private init(){}
    
    //Fired at launch
//    func getUserRecord(){
//        //Get our UserRecord ID from Container
//        CKContainer.default().fetchUserRecordID{ recordID, error in
//            guard let recordID = recordID, error == nil else {
//                print(error!.localizedDescription)
//                return
//            }
//
//            //Get User record from Public Database
//            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { userRecord, error in
//                guard let userRecord = userRecord, error == nil else {
//                    print(error!.localizedDescription)
//                    return
//                }
//                self.userRecord = userRecord
//
//                //Set profileRecordID at launch
//                if let profileReference = userRecord["userProfile"] as? CKRecord.Reference {
//                    self.profileRecordID = profileReference.recordID
//                }
//            }
//        }
//    }
    
    //async allows us to use async system. throws forces use to handle errors
    func getUserRecord() async throws {
        let recordID = try await container.userRecordID()
        let record = try await container.publicCloudDatabase.record(for: recordID)
        userRecord = record
        
        if let profileReference = record["userProfile"] as? CKRecord.Reference {
            profileRecordID = profileReference.recordID
       }
    }

//    func getLocations(completed: @escaping(Result<[DDGLocation], Error>) -> Void){
//        //Sort by name, name is SORTABLE in CloudKit
//        let sortDescriptor = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
//        //Predicate set true to get every DDGLocation
//        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
//        query.sortDescriptors = [sortDescriptor]
//
//        //Network Call
//        //Returns optional records or optional error
//        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
//            guard let records = records, error == nil else {
//                completed(.failure(error!))
//                return
//            }
//
//            let locations = records.map(DDGLocation.init)
////            var locations: [DDGLocation] = []
////
////            for record in records {
////                let location = DDGLocation(record: record)
////                locations.append(location)
////            }
//
//            completed(.success(locations))
//        }
//    }
    
    //Return array of locations
    func getLocations() async throws -> [DDGLocation]{
        //Sort by name, name is SORTABLE in CloudKit
        let sortDescriptor = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
        //Predicate set true to get every DDGLocation
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        //Not using cursor
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _ , result in try? result.get()}
        return records.map(DDGLocation.init)
            
    }

    
//    func getCheckedInProfiles(for locationID: CKRecord.ID, completed: @escaping (Result<[DDGProfile], Error>) -> Void ){
//        let reference = CKRecord.Reference(recordID: locationID, action: .none)
//        let predicate = NSPredicate(format: "isCheckedIn == %@", reference)
//        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
//
//        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
//            guard let records = records, error == nil else {
//                completed(.failure(error!))
//                return
//            }
//            //Convert [CKRecord] to [DDGProfile]
//            let profiles = records.map(DDGProfile.init)
//            completed(.success(profiles))
//        }
//    }
    
    func getCheckedInProfiles(for locationID: CKRecord.ID) async throws -> [DDGProfile] {
        let reference = CKRecord.Reference(recordID: locationID, action: .none)
        let predicate = NSPredicate(format: "isCheckedIn == %@", reference)
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
        
        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query)
        //Because try is optional, any error that we retrieve will be nil instead, compactMap filters out nil
        let records = matchResults.compactMap { _, result in
            try? result.get()
        }
    
        return records.map(DDGProfile.init)
    }
    
    
//    func getCheckedInProfilesDictionary(completed: @escaping (Result<[CKRecord.ID: [DDGProfile]], Error>) -> Void) {
//        print("✅ Network call")
//        //Means they are checked in somewhere
//        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
//        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
//        //Instead of using convenience api we can use this so we can choose which properties to get back, not good for future proofing if need be
//        let operation = CKQueryOperation(query: query)
//        //operation.resultsLimit = 1
//        //operation.desiredKeys = [DDGProfile.kIsCheckedIn, DDGProfile.kAvatar]
//
//        var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]
//        operation.recordFetchedBlock = { record in
//           let profile = DDGProfile(record: record)
//
//            //Gets location record because isCheckedIn is reference to location
//            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { return }
//            checkedInProfiles[locationReference.recordID, default: []].append(profile)
//
//        }
//
//        operation.queryCompletionBlock = { cursor, error in
//            //if cursor is not nil, there are more profiles/records
//            guard error == nil else {
//                completed(.failure(error!))
//                return
//            }
//
//            if let cursor = cursor {
//                print("1️⃣  Cursor not nil = \(cursor)")
//                print("🏘  Current dictionary - \(checkedInProfiles)")
//                self.continueWithCheckedInProfilesDict(cursor: cursor, dictionary: checkedInProfiles) { result in
//                    switch result {
//
//                    case .success(let profiles):
//                        print("😊1️⃣  Initial success Dictionary -  \(profiles)")
//                        completed(.success(profiles))
//                    case .failure(let error):
//                        print("❌1️⃣  Initial error -  \(error)")
//                        completed(.failure(error))
//                    }
//                }
//            } else {
//                completed(.success(checkedInProfiles))
//            }
//        }
//
//        //Do operation similar to Task.resume()
//        CKContainer.default().publicCloudDatabase.add(operation)
//    }
    
//    func continueWithCheckedInProfilesDict(cursor: CKQueryOperation.Cursor,
//                                           dictionary: [CKRecord.ID : [DDGProfile]],
//                                           completed: @escaping (Result<[CKRecord.ID: [DDGProfile]], Error>) -> Void){
//        var checkedInProfiles = dictionary
//        let operation = CKQueryOperation(cursor: cursor)
//        //operation.resultsLimit = 1
//
//        operation.recordFetchedBlock = { record in
//            let profile = DDGProfile(record: record)
//            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { return }
//            checkedInProfiles[locationReference.recordID, default: []].append(profile)
//        }
//
//        operation.queryCompletionBlock = { cursor, error in
//            guard error == nil else {
//                completed(.failure(error!))
//                return
//            }
//
//            if let cursor = cursor {
//                print("🅾️  Cursor not nil = \(cursor)")
//                print("📚  Current dictionary - \(checkedInProfiles)")
//                self.continueWithCheckedInProfilesDict(cursor: cursor, dictionary: checkedInProfiles) { result in
//                    switch result {
//                        case .success(let profiles):
//                        print("😊  Recursive success Dictionary -  \(profiles)")
//                            completed(.success(profiles))
//                        case .failure(let error):
//                        print("❌  Recursive error -  \(error)")
//                            completed(.failure(error))
//                    }
//                }
//            } else {
//                completed(.success(checkedInProfiles))
//            }
//        }
//        CKContainer.default().publicCloudDatabase.add(operation)
//    }
    
    func getCheckedInProfilesDictionary() async throws -> [CKRecord.ID: [DDGProfile]] {
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)

        var checkedInProfiles: [CKRecord.ID : [DDGProfile]] = [:]
        
        
        let (matchResults, cursor) = try await container.publicCloudDatabase.records(matching: query)
        let records = matchResults.compactMap { _, result in
            try? result.get()
        }
        
        for record in records {
            let profile = DDGProfile(record: record)

            //Gets location record because isCheckedIn is reference to location
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { continue }
            checkedInProfiles[locationReference.recordID, default: []].append(profile)

        }
        
        //If nil, no more profiles to go through thus returning checkeedInProfiles
        guard let cursor = cursor else {
            return checkedInProfiles
        }
        
        do {
            return try await continueWithCheckedInProfilesDict(cursor: cursor, dictionary: checkedInProfiles)
        }  catch {
            throw error
        }
    }
    
    private func continueWithCheckedInProfilesDict(cursor: CKQueryOperation.Cursor, dictionary: [CKRecord.ID : [DDGProfile]]) async throws -> [CKRecord.ID: [DDGProfile]] {
        
        var checkedInProfiles = dictionary
        
        let (matchResults, cursor) = try await container.publicCloudDatabase.records(continuingMatchFrom: cursor)
        let records = matchResults.compactMap { _, result in
            try? result.get()
        }
        
        for record in records {
            let profile = DDGProfile(record: record)
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { continue }
            checkedInProfiles[locationReference.recordID, default: []].append(profile)
        }

        guard let cursor = cursor else {
            return checkedInProfiles
        }
        
        do {
            return try await continueWithCheckedInProfilesDict(cursor: cursor, dictionary: checkedInProfiles)
        }  catch {
            throw error
        }

    }
    
//    func getCheckedInProfilesCount(completed: @escaping (Result<[CKRecord.ID: Int], Error>) -> Void) {
//        //Means they are checked in somewhere
//        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
//        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)
//
//        //Instead of using convenience api we can use this so we can choose which properties to get back, not good for future proofing if need be
//        let operation = CKQueryOperation(query: query)
//        operation.desiredKeys = [DDGProfile.kIsCheckedIn]
//
//        var checkedInProfiles: [CKRecord.ID : Int] = [:]
//        operation.recordFetchedBlock = { record in
//
//            //Gets location record because isCheckedIn is reference to location
//            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { return }
//            if let count = checkedInProfiles[locationReference.recordID] {
//                //Not nil
//                checkedInProfiles[locationReference.recordID] = count + 1
//            } else {
//                //If nil
//                checkedInProfiles[locationReference.recordID] = 1
//            }
//        }
//
//        operation.queryCompletionBlock = { cursor, error in
//            guard error == nil else {
//                completed(.failure(error!))
//                return
//            }
//            //Handle cursor in later video
//            completed(.success(checkedInProfiles))
//        }
//        //Do operation similar to Task.resume()
//        CKContainer.default().publicCloudDatabase.add(operation)
//    }
    
    func getCheckedInProfilesCount() async throws -> [CKRecord.ID: Int] {
        //Means they are checked in somewhere
        let predicate = NSPredicate(format: "isCheckedInNilCheck == 1")
        let query = CKQuery(recordType: RecordType.profile, predicate: predicate)

        let (matchResults, _) = try await container.publicCloudDatabase.records(matching: query, desiredKeys: [DDGProfile.kIsCheckedIn])
        let records = matchResults.compactMap { _, result in
            try? result.get()
        }

        var checkedInProfiles: [CKRecord.ID : Int] = [:]

        for record in records {
            //Gets location record because isCheckedIn is reference to location
            guard let locationReference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference else { continue }
            if let count = checkedInProfiles[locationReference.recordID] {
                //Not nil
                checkedInProfiles[locationReference.recordID] = count + 1
            } else {
                //If nil
                checkedInProfiles[locationReference.recordID] = 1
            }
        }

        return checkedInProfiles
    }
    
//    func batchSave(records: [CKRecord], completed: @escaping (Result<[CKRecord], Error>) -> Void){
//        //Create CKOPeration to save our User & Profile Records, batch save
//        let operation = CKModifyRecordsOperation(recordsToSave: records)
//        operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
//            guard let savedRecords = savedRecords, error == nil else {
//                completed(.failure(error!))
//                return
//            }
//
//            completed(.success(savedRecords))
//        }
//        //Add to database
//        CKContainer.default().publicCloudDatabase.add(operation)
//    }
    
    func batchSave(records: [CKRecord]) async throws -> [CKRecord]{
        let (savedResult, _) = try await container.publicCloudDatabase.modifyRecords(saving: records, deleting: [])
        return savedResult.compactMap { _, result in try? result.get() }
    }
    
    func save(record: CKRecord) async throws -> CKRecord{
        return try await container.publicCloudDatabase.save(record)
    }
    
    func fetchRecord(with id: CKRecord.ID) async throws -> CKRecord {
        return try await container.publicCloudDatabase.record(for: id)
    }
}
