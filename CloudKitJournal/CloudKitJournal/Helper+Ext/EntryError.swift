//
//  EntryError.swift
//  CloudKitJournal
//
//  Created by Myles Cashwell on 5/10/21.
//  Copyright © 2021 Zebadiah Watson. All rights reserved.
//

import Foundation

enum EntryError: LocalizedError {
    case unableToUnwrap
    case thrownError(Error)
    
    var errorDescription: String? {
        switch self {
        case.unableToUnwrap:
            return "Unable to reach the server."
        case .thrownError(let error):
            print("Error in \(#function)\(#line) : \(error.localizedDescription) \n---\n \(error)")
            return "That entry does not exist\nPlease check your spelling"
        }
    }
}
