//
//  FixedIncome.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import Foundation

class FixedIncome: Identifiable {
    var name: String
    var money: Int

    init(name: String, money: Int) {
        self.name = name
        self.money = money
    }
}
