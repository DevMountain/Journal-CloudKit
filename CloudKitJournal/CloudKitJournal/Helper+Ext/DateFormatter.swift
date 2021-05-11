//
//  DateFormatter.swift
//  CloudKitJournal
//
//  Created by Myles Cashwell on 5/10/21.
//  Copyright © 2021 Zebadiah Watson. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

extension Date {
    func formatToString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
}
