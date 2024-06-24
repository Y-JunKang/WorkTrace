//
//  FixedIncome.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import Foundation

struct IncomeTemplate: Identifiable {
    var id: UUID = UUID()
    var name: String
    var money: Int
    var startYear: Int = Date.now.year
    var startMonth: Int = Date.now.month
    var createDate: Date = Date.now
    
    
    var startTimeDescription: String {
        return String(format: "%d年%02d月", startYear, startMonth)
    }
}
