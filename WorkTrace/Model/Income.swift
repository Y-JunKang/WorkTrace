//
//  Income.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/22.
//

import CoreData
import Foundation

struct Income: Identifiable {
    var id: UUID = UUID()
    var year: Int
    var month: Int
    var name: String = ""
    var money: Int = 0
    var templateId: UUID? = nil

    var info: String {
        return String(money) + "元"
    }
}
