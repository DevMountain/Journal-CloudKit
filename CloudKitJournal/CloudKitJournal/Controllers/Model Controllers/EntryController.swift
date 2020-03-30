//
//  EntryController.swift
//  CloudKitJournal
//
//  Created by Zebadiah Watson on 3/26/20.
//  Copyright © 2020 Zebadiah Watson. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    // Properties
    static let sharedInstance = EntryController()
    
    var entries: [Entry] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase


    func createEntry(with title: String, body: String, completion: @escaping (_ result: Result<Entry?, EntryError>) -> Void) {
        let newEntry = Entry(title: title, body: body)
        save(entry: newEntry, completion: completion)
    }

    // C.R.U.D. Methods
    func save(entry: Entry, completion: @escaping (_ result: Result<Entry?, EntryError>) -> Void) {

        let entryRecord = CKRecord(entry: entry)

        privateDB.save(entryRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
                return
            }
            guard let record = record,
            let savedEntry = Entry(ckRecord: record)
                else { completion(.failure(.couldNotUnwrap)); return }
            print("new Entry saved successfully")
            self.entries.insert(savedEntry, at: 0)
            completion(.success(savedEntry))
        }
    }
    
    func fetchEntriesWith(completion: @escaping (_ result: Result<[Entry]?,EntryError>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: EntryConstants.recordTypeKey, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            guard let records = records else { completion(.failure(.couldNotUnwrap)); return }
            print("Successfully fetched all Entries")
            let entries = records.compactMap({ Entry(ckRecord: $0) })
            self.entries = entries
            completion(.success(entries))
        }
    }
    
}// End of Class
