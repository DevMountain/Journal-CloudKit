//
//  EntryController.swift
//  CloudKitJournal
//
//  Created by Myles Cashwell on 5/10/21.
//  Copyright © 2021 Zebadiah Watson. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    //MARK: - Properties
    static let shared = EntryController()
    var entries: [Entry] = []
    var privateDB = CKContainer.default().privateCloudDatabase
    
    
    //MARK: - Functions
    func createEntryWith(title: String, body: String, completion: @escaping (Result<Entry?, EntryError>) -> Void) {
        let newEntry = Entry(title: title, body: body)
        
        save(entry: newEntry) { (result) in
            switch result {
            case .success(let createdEntry):
                guard let newEntry = createdEntry else { return }
                self.entries.append(newEntry)
                completion(.success(newEntry))
            case .failure(let error):
                completion(.failure(.thrownError(error)))
            }
        }
    }
    
    func save(entry: Entry, completion: @escaping (Result<Entry?, EntryError>) -> Void) {
        let entryToSave = entry
        let entryRecord = CKRecord(entry: entryToSave)
        
        privateDB.save(entryRecord) { (record, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
            guard let record = record,
               let savedEntry = Entry(ckRecord: record)
            else { return completion(.failure(.unableToUnwrap)) }
            
            print("Entry Saved Successfully")
            completion(.success(savedEntry))
        }
    }
    
    func fetchEntriesWith(completion: @escaping (Result<[Entry]?,EntryError>) -> Void) {
        let fetchPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EntryConstants.recordType, predicate: fetchPredicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
            guard let records = records else { return completion(.failure(.unableToUnwrap)) }
            
            let fetchedEntries = records.compactMap({ Entry(ckRecord: $0) })
            completion(.success(fetchedEntries))
        }
    }
}
