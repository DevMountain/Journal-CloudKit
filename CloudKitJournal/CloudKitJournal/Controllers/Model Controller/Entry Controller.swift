//
//  Entry Controller.swift
//  CloudKitJournal
//
//  Created by Junior Suarez-Leyva on 5/11/20.
//  Copyright © 2020 Zebadiah Watson. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    static let sharedInstance = EntryController()
    
    var entries: [Entry] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //MARK: - CRUD
    
    //MARK: - Create
    func createEntryWith(title: String, body: String, completion: @escaping(_ result: Result<Entry?, EntryError>) -> Void) {
        
        let newEntry = Entry(title: title, body: body)
        save(with: newEntry, completion: completion)
        
    }
    
    
    
    //MARK: - Save
    func save(with entry: Entry, completion: @escaping (_ result:Result<Entry?, EntryError>) -> Void) {
       
        let entryRecord = CKRecord(entry: entry)
        privateDB.save(entryRecord) { (record, error) in
            if let error = error {
                return completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                let savedEntry = Entry(ckRecord: record) else { return completion (.failure(.couldNotUnwrap)) }
            print("Save Entry Successfully")
            self.entries.insert(savedEntry, at: 0)
            completion(.success(savedEntry))
        }
        
    }
    
   
    //MARK: - Read(Fetch)
    func fetchEntriesWith(completion: @escaping (_ result: Result<[Entry]?, EntryError>) -> Void) {
        
        let fetchAllEntriesPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EntryStrings.recordTypeKey, predicate: fetchAllEntriesPredicate)
        privateDB.perform(query, inZoneWith: nil) { (record, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            guard let records = record else { return completion(.failure(.couldNotUnwrap)) }
            
            print("fetched all Entries successfully")
            let entries = records.compactMap({ Entry(ckRecord: $0) })
            self.entries = entries
            completion(.success(entries))
        }
    }
}
