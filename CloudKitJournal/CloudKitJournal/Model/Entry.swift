//
//  Entry.swift
//  CloudKitJournal
//
//  Created by Junior Suarez-Leyva on 5/11/20.
//  Copyright © 2020 Zebadiah Watson. All rights reserved.
//

import Foundation
import CloudKit

struct EntryStrings {
    static let recordTypeKey = "Entry"
    static let titleKey = "title"
    static let bodyKey = "body"
    static let timestampKey = "timestamp"
    
}

class Entry {
    
    let title: String
    let body: String
    let timestamp: Date
    let ckRecordID: CKRecord.ID
    
    init(title: String, body: String, timestamp: Date = Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.ckRecordID = ckRecordID
    }
}

extension Entry {
    
    convenience init?(ckRecord: CKRecord) {
        guard let title = ckRecord[EntryStrings.titleKey] as? String,
            let body = ckRecord[EntryStrings.bodyKey] as? String,
            let timestamp = ckRecord[EntryStrings.timestampKey] as? Date else { return nil }
        self.init(title: title, body: body, timestamp: timestamp)
    }
}

extension CKRecord {
    
    convenience init(entry: Entry) {
        self.init(recordType: EntryStrings.recordTypeKey, recordID: entry.ckRecordID)
        
        self.setValuesForKeys([
            EntryStrings.titleKey : entry.title,
            EntryStrings.bodyKey : entry.body,
            EntryStrings.timestampKey : entry.timestamp
            
        ])
    }
}
