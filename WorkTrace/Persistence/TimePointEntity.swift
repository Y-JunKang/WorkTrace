//
//  TimePointEntity.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/7/5.
//

import Foundation
import CoreData

extension TimePointEntity {
    convenience init(year: Int, month: Int, day: Int, timepoint: TimePoint) {
        self.init(context: Persistence.shared.container.viewContext, year: year, month: month, day: day, timepoint: timepoint)
    }
    
    convenience init(context: NSManagedObjectContext, year: Int, month: Int, day: Int, timepoint: TimePoint) {
        self.init(context: context)
        self.id = timepoint.id
        self.type = Int32(timepoint.type.rawValue)
        self.year = Int32(year)
        self.month = Int32(month)
        self.day = Int32(day)
        self.hour = Int32(timepoint.time.hour)
        self.minute = Int32(timepoint.time.minute)
    }
    
    var timePoint: TimePoint {
      get {
        switch type {
        case 0:
          return TimePoint(id: id ?? UUID(), time: HourMinute(Int(hour), Int(minute)), type: .start)
        default:
          return TimePoint(id: id ?? UUID(), time: HourMinute(Int(hour), Int(minute)), type: .end)
        }
      }
      
      set {
        self.type = Int32(newValue.type.rawValue)
        self.hour = Int32(newValue.time.hour)
        self.minute = Int32(newValue.time.minute)
      }
    }
    
    var totalMinute: Int {
        return Int(year) * 365 * 30 * 24 * 60 + Int(month) * 30 * 24 * 60 + Int(day) * 24 * 60 + Int(hour) * 60 + Int(minute)
    }
}
