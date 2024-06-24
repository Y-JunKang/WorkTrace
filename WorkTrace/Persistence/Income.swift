//
//  Income.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/22.
//

import Foundation

class Income: Identifiable {
    var id: UUID
    var year: Int
    var month: Int
    var name: String
    var money: Int
    var isFixed: Bool

    convenience init(year: Int, month: Int) {
        self.init(year: year, month: month, name: "", money: 0, isFixed: false)
    }

    init(year: Int, month: Int, name: String, money: Int, isFixed: Bool) {
        id = UUID()
        self.year = year
        self.month = month
        self.name = name
        self.money = money
        self.isFixed = isFixed
    }

    var info: String {
        return String(money) + "元"
    }
}
