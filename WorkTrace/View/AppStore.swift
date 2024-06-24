//
//  AppStore.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/6/30.
//

import Foundation

class AppStore {
    static let debug = AppStore(isDebug: true)

    static let inst = AppStore(isDebug: true)

    var bills: [MonthBill]

    init(isDebug: Bool) {
        // load from db
        var incomes: [Income] = []
        var days: [WorkDay] = []
        if isDebug {
            incomes = [
                Income(year: 2024, month: 4, name: "工资", money: 8000, isFixed: true),
                Income(year: 2024, month: 4, name: "副业", money: 7000, isFixed: false),
                Income(year: 2024, month: 5, name: "工资", money: 5000, isFixed: true),
                Income(year: 2024, month: 5, name: "副业", money: 2000, isFixed: false),
                Income(year: 2024, month: 6, name: "工资", money: 5000, isFixed: true),
                Income(year: 2024, month: 6, name: "副业", money: 4000, isFixed: false),
            ]

            days = [
                WorkDay(year: 2024, month: 4, day: 14, timePoints: [
                    .start(date: Date(year: 2024, month: 4, day: 14, hour: 9)!),
                    .end(date: Date(year: 2024, month: 4, day: 14, hour: 12)!),
                ]),
                WorkDay(year: 2024, month: 4, day: 17, timePoints: [
                    .start(date: Date(year: 2024, month: 4, day: 17, hour: 9)!),
                    .end(date: Date(year: 2024, month: 4, day: 17, hour: 12)!),
                    .start(date: Date(year: 2024, month: 4, day: 17, hour: 15)!),
                    .end(date: Date(year: 2024, month: 4, day: 17, hour: 22)!),
                ]),
                WorkDay(year: 2024, month: 4, day: 18, timePoints: [
                    .start(date: Date(year: 2024, month: 4, day: 18, hour: 9)!),
                    .end(date: Date(year: 2024, month: 4, day: 18, hour: 20)!),
                ]),
                WorkDay(year: 2024, month: 5, day: 14, timePoints: [
                    .start(date: Date(year: 2024, month: 5, day: 14, hour: 9)!),
                    .end(date: Date(year: 2024, month: 5, day: 14, hour: 12)!),
                ]),
                WorkDay(year: 2024, month: 5, day: 17, timePoints: [
                    .start(date: Date(year: 2024, month: 5, day: 17, hour: 9)!),
                    .end(date: Date(year: 2024, month: 5, day: 17, hour: 12)!),
                    .start(date: Date(year: 2024, month: 5, day: 17, hour: 15)!),
                    .end(date: Date(year: 2024, month: 5, day: 17, hour: 22)!),
                ]),
                WorkDay(year: 2024, month: 6, day: 18, timePoints: [
                    .start(date: Date(year: 2024, month: 6, day: 18, hour: 9)!),
                    .end(date: Date(year: 2024, month: 6, day: 18, hour: 20)!),
                ]),
                WorkDay(year: 2024, month: 6, day: 21, timePoints: [
                    .start(date: Date(year: 2024, month: 6, day: 21, hour: 9)!),
                    .end(date: Date(year: 2024, month: 6, day: 21, hour: 20)!),
                ]),
                WorkDay(year: 2024, month: 6, day: 14, timePoints: [
                    .start(date: Date(year: 2024, month: 6, day: 14, hour: 9)!),
                    .end(date: Date(year: 2024, month: 6, day: 14, hour: 12)!),
                ]),
                WorkDay(year: 2024, month: 6, day: 17, timePoints: [
                    .start(date: Date(year: 2024, month: 6, day: 17, hour: 9)!),
                    .end(date: Date(year: 2024, month: 6, day: 17, hour: 12)!),
                    .start(date: Date(year: 2024, month: 6, day: 17, hour: 15)!),
                    .end(date: Date(year: 2024, month: 6, day: 17, hour: 22)!),
                ]),
                WorkDay(year: 2024, month: 6, day: 22, timePoints: [
                    .start(date: Date(year: 2024, month: 6, day: 22, hour: 9)!),
                    .end(date: Date(year: 2024, month: 6, day: 22, hour: 20)!),
                ])]
        }

        let firstDay = WorkDay(year: 2024, month: 2, day: 11, timePoints: [
            .start(date: Date(year: 2024, month: 6, day: 22, hour: 9)!),
            .end(date: Date(year: 2024, month: 6, day: 22, hour: 20)!),
        ])
        bills = []
        var currentYear = firstDay.year
        var currentMonth = firstDay.month
        repeat {
            bills.append(MonthBill(year: currentYear, month: currentMonth, days: [], incomes: []))
            currentMonth = currentMonth + 1
            if currentMonth > 12 {
                currentMonth = currentMonth - 12
                currentYear = currentYear + 1
            }
        } while currentYear != Date.now.year() || currentMonth != Date.now.month() + 1

        for income in incomes {
            for bill in bills {
                if bill.year == income.year && bill.month == income.month {
                    bill.incomes.append(income)
                    break
                }
            }
        }

        days.sort { day0, day1 in
            day0.day > day1.day
        }

        for day in days {
            for bill in bills {
                if bill.year == day.year && bill.month == day.month {
                    bill.workdays.append(day)
                    break
                }
            }
        }
    }

    func findBill(year: Int, month: Int) -> MonthBill {
        let bill = bills.first { bill in
            bill.year == year && bill.month == month
        }

        return bill ?? MonthBill(year: year, month: month, days: [], incomes: [])
    }
}
