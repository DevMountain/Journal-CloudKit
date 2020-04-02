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
    
    // MARK: - Singleton
    static let sharedInstance = EntryController()
    
    // MARK: - Source of Truth
    var entries: [Entry] = []
    
    // MARK: Property
    /// property used to access the privateCloudDatabase of the default container
    let privateDB = CKContainer.default().privateCloudDatabase

    // MARK: - C.R.U.D. Methods
    
    /**
     Creating an Entry object and then using our 'save' function to save it to CloudKit
     
     - Parameters:
        - title: String value for the Entry objects title property
        - body: String value for the Entry objects body property
        - completion: escaping completion block for the method
        - result: results returned in the completion block, an optional Entry object or a specifc EntryError used for debugging.
     */
    
    func createEntry(with title: String, body: String, completion: @escaping (_ result: Result<Entry?, EntryError>) -> Void) {
        /// initialize a new Entry with the title and body value passed in as a parameter
        let newEntry = Entry(title: title, body: body)
        /// call our save method and pass in the newEntry and completion as a parameter
        save(entry: newEntry, completion: completion)
    }

    /**
     Save the Entry object to CloudKit
     
     - Parameters:
        - entry: Entry object created in our createEntry function
        - completion: Escaping completion block for the method
        - result: results returned in the completion block, an optional Entry object or a specifc EntryError used for debugging.
     */
    
    func save(entry: Entry, completion: @escaping (_ result: Result<Entry?, EntryError>) -> Void) {
        /// Initialize a CKRecord from the Entry object passed in from our parameters
        let entryRecord = CKRecord(entry: entry)
        /// call the save method from the privateDatabase
        privateDB.save(entryRecord) { (record, error) in
            /// handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
                return
            }
            /// Unwrap the CKRecord that was saved
            guard let record = record,
                /// re-create the same Entry object from that record that we know was successfully saved
            let savedEntry = Entry(ckRecord: record)
                else { completion(.failure(.couldNotUnwrap)); return }
            print("new Entry saved successfully")
            /// add the Entry to our local Source of Truth
            self.entries.insert(savedEntry, at: 0)
            /// complete successfully with newly saved Entry object
            completion(.success(savedEntry))
        }
    }
    
    /**
     Fetches all Entry objects stored in the CKContainer's privateDataBase
     
     - Parameters:
        - completion: Escaping completion block for the method
        - result: results returned in the completion block, an optional array of Entry objects or a specifc EntryError used for debugging.
     */
    
    func fetchEntriesWith(completion: @escaping (_ result: Result<[Entry]?,EntryError>) -> Void) {
        /// create the predicate needed fot eh paramaters of our query
        let predicate = NSPredicate(value: true)
        /// create the queary needed for the perform(query) method
        let query = CKQuery(recordType: EntryConstants.recordTypeKey, predicate: predicate)
        /// call the perform method from on the privateDatabase
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            /// handle the optional error
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.ckError(error)))
            }
            /// unwrap the successfully fetched CKRecord objects
            guard let records = records else { completion(.failure(.couldNotUnwrap)); return }
            print("Successfully fetched all Entries")
            /// map through the found records and apply the Entry(ckRecord: ) convenience initializer method as the transform paramater
            let entries = records.compactMap({ Entry(ckRecord: $0) })
            /// set our local Source of Truth to the value of the returned Entry objects
            self.entries = entries
            /// complete successfully with our new array of Entry objects
            completion(.success(entries))
        }
    }
    
}// End of Class
