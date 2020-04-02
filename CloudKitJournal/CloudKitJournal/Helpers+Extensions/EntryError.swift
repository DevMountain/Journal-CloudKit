//
//  EntryError.swift
//  CloudKitJournal
//
//  Created by Zebadiah Watson on 3/26/20.
//  Copyright © 2020 Zebadiah Watson. All rights reserved.
//

import Foundation

    /**
    In this helper we are creating an enum to handle errors we get during our network calls
    */

enum EntryError: LocalizedError {
    case ckError(Error)
    case couldNotUnwrap
}
