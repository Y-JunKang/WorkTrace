//
//  TimePoint.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/7/8.
//

import Foundation

struct HourMinute: Hashable {
    var hour: Int
    var minute: Int

    init() {
        let now = Date.now
        hour = now.hour
        minute = now.minute
    }

    init(_ hour: Int, _ minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    init(totalMinte: Int) {
        hour = totalMinte / 60
        minute = totalMinte % 60
    }

    var totalMinute: Int {
        return hour * 60 + minute
    }

    var percent: Double {
        return Double(totalMinute) / (24 * 60)
    }
    
    var description: String {
        return String(format: "%02d:%02d", hour, minute)
    }
}

struct TimePoint: CustomStringConvertible, Equatable, Hashable {
  enum TimeType: Int {
    case start = 0
    case end
  }
  
  var id = UUID()
  var time: HourMinute
  var type: TimeType

    var description: String {
        return time.description
    }
  
  mutating func updateTime(_ time: HourMinute) {
    self.time = time
  }
}
