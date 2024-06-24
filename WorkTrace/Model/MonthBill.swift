//
//  MonthBill.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import Foundation

class MonthBill: Identifiable {
    var year: Int
    var month: Int
    @Published var workdays: [WorkDay]
    @Published var incomes: [Income]

    init(year: Int, month: Int, days: [WorkDay], incomes: [Income]) {
        self.year = year
        self.month = month
        workdays = days
        self.incomes = incomes
    }

    var dateDescription: String {
        return String(format: "%d年%d月", year, month)
    }

    var totalWorkHours: Double {
        return workdays.reduce(0) { partialResult, workday in
            partialResult + Double(workday.totalWorkSeconds / (60 * 60))
        }
    }

    var totalIncome: Int {
        return incomes.reduce(0) { partialResult, income in
            partialResult + income.money
        }
    }

    var avgIncome: Int {
        if totalWorkHours == 0 {
            return 0
        }
        return Int(Double(totalIncome) / totalWorkHours)
    }

    var isCurrentMonth: Bool {
        return year == Date.now.year() && month == Date.now.month()
    }

    var isWorkingNow: Bool {
        if let day = workdays.last {
            return day.isWorkingNow
        }

        return false
    }

    var hasRecord: Bool {
        return workdays.count != 0 || incomes.count != 0
    }

    func startWork() {
        let now = Date.now
        if var workday = workdays.first, workday.isToday() {
            workday.timePoints.append(.start(date: now))
            workdays[0] = workday
        } else {
            var workday = WorkDay(year: now.year(), month: now.month(), day: now.day())
            workday.timePoints.append(.start(date: now))
            workdays.insert(workday, at: 0)
        }
    }

    func finishWork() {
        let now = Date.now
        if var workday = workdays.first, workday.isToday() {
            workday.timePoints.append(.end(date: now))
            workdays[0] = workday
        } else {
            var workday = WorkDay(year: now.year(), month: now.month(), day: now.day())
            workday.timePoints.append(.end(date: now))
            workdays.insert(workday, at: 0)
        }
    }

    func findWorkDay(day: Int) -> WorkDay {
        let workday = workdays.first { workday in
            workday.day == day
        }

        return workday ?? WorkDay(year: year, month: month, day: day)
    }
}
