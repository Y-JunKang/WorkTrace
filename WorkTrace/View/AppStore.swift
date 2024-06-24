//
//  AppStore.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/6/30.
//

import Foundation

class AppStore {
    static let preview: AppStore = {
        AppStore(isDebug: true)
    }()

    static let shared: AppStore = {
        AppStore(isDebug: false)
    }()

    var monthBills: [MonthBill] = []
    var templates: [IncomeTemplate] = []

    init(isDebug: Bool) {
        let persistence = isDebug ? Persistence.preview : Persistence.shared
        templates = persistence.incomeTemplateEntitys.map { $0.incomeTemplate }
        let incomes = persistence.incomeEntitys.map { $0.income }
        let timePointEntitys = persistence.timePointEntitys.sorted { t0, t1 in
            t0.totalMinute > t1.totalMinute
        }

        let now = Date.now
        var firstYear = now.year, firstMonth = now.month
        if let entity = timePointEntitys.last {
            firstYear = Int(entity.year)
            firstMonth = Int(entity.month)
        }

        var currentYear = firstYear
        var currentMonth = firstMonth
        repeat {
            monthBills.append(MonthBill(year: currentYear, month: currentMonth, days: [], incomes: []))
            currentMonth = currentMonth + 1
            if currentMonth > 12 {
                currentMonth = currentMonth - 12
                currentYear = currentYear + 1
            }
        } while currentYear != Date.now.year || currentMonth != Date.now.month + 1

        for income in incomes {
            for bill in monthBills {
                if bill.year == income.year && bill.month == income.month {
                    bill.editIncome(income)
                    break
                }
            }
        }

        for bill in monthBills {
            var points: [Int32: [TimePoint]] = [:]
            for entity in timePointEntitys {
                if bill.year == entity.year && bill.month == entity.month {
                    if points.keys.contains(entity.day) {
                        points[entity.day]?.append(entity.timePoint)
                    } else {
                        points[entity.day] = [entity.timePoint]
                    }
                }
            }

            points.sorted { p0, p1 in
                p0.key > p1.key
            }.map { (day: Int32, points: [TimePoint]) in
                WorkDay(year: bill.year, month: bill.month, day: Int(day), timePoints: points)
            }.forEach { workday in
                bill.workdays.append(workday)
            }
        }

        print("")
    }

    func findBill(year: Int, month: Int) -> MonthBill {
        let bill = monthBills.first { bill in
            bill.year == year && bill.month == month
        }

        guard let bill = bill else {
            let newBill = MonthBill(year: year, month: month, days: [], incomes: [])
            monthBills.append(newBill)
            return newBill
        }
        return bill
    }

    func editTemplate(_ template: IncomeTemplate) {
        let idx = templates.firstIndex { i in
            i.id == template.id
        }

        if let idx = idx {
            templates[idx] = template
        } else {
            templates.append(template)
            templates.sort { i0, i1 in
                i0.money > i1.money
            }
        }

        let entity = Persistence.shared.incomeTemplateEntitys.first { entity in
            entity.id == template.id
        }

        if let entity = entity {
            entity.name = template.name
            entity.money = Int32(template.money)
            entity.startYear = Int32(template.startYear)
            entity.startMonth = Int32(template.startMonth)
        } else {
            _ = IncomeTemplateEntity(incomeTemplate: template)
        }
        Persistence.shared.save()
    }

    func deleteTemplate(_ uuid: UUID) {
        templates.removeAll { template in
            template.id == uuid
        }

        Persistence.shared.deleteIncomeTemplate(uuid)
    }
}
