//
//  RSDateConverter.swift
//  RSSchool_FinalTask
//
//  Created by Kirill on 2.11.21.
//

import Foundation

func getStringFromDate(date: Date) -> String {
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "MMM d, yyyy"
    return outputFormatter.string(from: date)
}

func getDateFromString(string: String) -> Date {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss Z"
    guard let date = inputFormatter.date(from: string) else { return Date() }
    return date
}
