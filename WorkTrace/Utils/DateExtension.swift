//
//  DateExtension.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import Foundation

extension Date {
    init?(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil) {
        guard let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) else {
            return nil
        }

        self = date
    }

    func year() -> Int {
        return Calendar.current.component(.year, from: self)
    }

    func month() -> Int {
        return Calendar.current.component(.month, from: self)
    }

    func day() -> Int {
        return Calendar.current.component(.day, from: self)
    }

    func minute() -> Int {
        return Calendar.current.component(.minute, from: self)
    }

    func hour() -> Int {
        return Calendar.current.component(.hour, from: self)
    }

    func formatString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    var debugDescription: String {
        return formatString("yyyy-MM-dd HH:mm")
    }
}
