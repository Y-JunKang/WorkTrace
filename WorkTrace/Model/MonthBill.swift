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
            partialResult + Double(workday.totalWorkMinutes / 60)
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
        return year == Date.now.year && month == Date.now.month
    }

    var isWorkingNow: Bool {
        if let day = workdays.first {
            return day.isWorkingNow
        }

        return false
    }

    var hasRecord: Bool {
        return workdays.count != 0 || incomes.count != 0
    }

    func startWork() {
        let now = Date.now
        let timePoint = TimePoint(time: .init(), type: .start)
        if var workday = workdays.first, workday.isToday() {
            workday.editTimePoint(timePoint)
            workdays[0] = workday
        } else {
            var workday = WorkDay(year: now.year, month: now.month, day: now.day)
            workday.editTimePoint(timePoint)
            workdays.insert(workday, at: 0)
        }
    }

    func finishWork() {
        let now = Date.now
      let entity = TimePointEntity(year: year, month: month, day: now.day, timepoint: .init(time: HourMinute(), type: .end))
        if var workday = workdays.first, workday.isToday() {
            workday.editTimePoint(entity.timePoint)
            workdays[0] = workday
        } else {
            var workday = WorkDay(year: now.year, month: now.month, day: now.day)
            workday.editTimePoint(entity.timePoint)
            workdays.insert(workday, at: 0)
        }
        Persistence.shared.save()
    }

    func findWorkDayIdx(day: Int) -> Int? {
        return workdays.firstIndex { workday in
            workday.day == day
        }
    }
  
    func addWorkDay(_ workday: WorkDay) -> Int {
        workdays.append(workday)
        workdays.sort { d0, d1 in
          d0.day > d1.day
        }
      
      return workdays.firstIndex { day in
        workday.year == day.year && workday.month == day.month && workday.day == day.day
      }!
    }

    func editIncome(_ income: Income) {
      let idx = incomes.firstIndex { i in
          i.id == income.id
      }

      if let idx = idx {
          incomes[idx] = income
      } else {
        incomes.append(income);
        incomes.sort { i0, i1 in
            i0.money > i1.money
        }
      }
      
      let entity = Persistence.shared.incomeEntitys.first { entity in
          entity.id == income.id
      }
      
      if let entity = entity {
          entity.name = income.name
          entity.money = Int32(income.money)
      } else {
          _ = IncomeEntity(income: income)
      }
      Persistence.shared.save()
    }
  
  func deleteIncome(_ uuid: UUID) {
    incomes.removeAll { income in
      income.id == uuid
    }
    
    Persistence.shared.deleteIncome(uuid)
  }
}
